#!/usr/bin/env python3
"""
Phone Sensor MQTT Injector - Injects phone sensor data INTO the CORE network

This script is a copy of core_mqtt_injector.py specifically for phone sensors.
It solves the problem of getting phone sensor data (from browser Device Motion API)
to flow as REAL network traffic inside CORE so it's visible in Wireshark.

Architecture:
    Phone Browser (Device Motion API) -> REST API -> This Injector -> vcmd/docker exec -> CORE Network

The injector uses vcmd or docker exec to run mosquitto_pub commands INSIDE a CORE
node's network namespace. This creates actual TCP/IP packets on the virtual network.

Usage:
    # Start the injector (runs alongside phone_web_ui.py)
    python3 phone_mqtt_injector.py --session 1 --broker-node mqtt-broker --broker-ip 10.0.1.10

    # Or auto-detect from running CORE session
    python3 phone_mqtt_injector.py --auto
"""

import argparse
import subprocess
import threading
import queue
import time
import json
import os
import signal
import sys
from typing import Optional, Tuple
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs


class PhoneMQTTInjector:
    """Injects phone sensor MQTT messages into CORE network using vcmd/docker exec"""

    def __init__(self, session_id: int, broker_node: str, broker_ip: str,
                 is_docker: bool = True, source_node: str = None,
                 docker_host: str = None):
        """
        Args:
            session_id: CORE session ID (e.g., 1)
            broker_node: Name of the MQTT broker node in CORE
            broker_ip: IP address of the MQTT broker inside CORE network
            is_docker: Whether broker_node is a Docker node (vs regular host)
            source_node: Optional - inject from this node instead of broker
            docker_host: Optional - Docker host container (e.g., 'core-novnc' for DinD)
        """
        self.session_id = session_id
        self.broker_node = broker_node
        self.broker_ip = broker_ip
        self.is_docker = is_docker
        self.source_node = source_node or broker_node
        self.docker_host = docker_host  # For Docker-in-Docker setup

        self.message_queue = queue.Queue()
        self.running = False
        self.message_count = 0
        self.worker_thread = None

        # Check if we have mosquitto_pub available
        self._check_dependencies()

    def _check_dependencies(self):
        """Verify required tools are available"""
        # Check for vcmd (CORE's command runner)
        vcmd_path = f"/tmp/pycore.{self.session_id}/{self.source_node}"
        if not self.is_docker and not os.path.exists(vcmd_path):
            print(f"[PHONE-INJECTOR] Warning: vcmd socket not found at {vcmd_path}")
            print(f"[PHONE-INJECTOR] Make sure CORE session {self.session_id} is running")

    def _execute_in_core(self, command: str, timeout: int = 5) -> Tuple[bool, str]:
        """Execute a command inside a CORE node's network namespace"""

        if self.is_docker:
            # For Docker nodes, use docker exec
            # The container name matches the node name
            if self.docker_host:
                # Docker-in-Docker: run docker exec inside the host container
                full_cmd = f"docker exec {self.docker_host} docker exec {self.source_node} {command}"
            else:
                full_cmd = f"docker exec {self.source_node} {command}"
        else:
            # For regular nodes, use vcmd
            vcmd_path = f"/tmp/pycore.{self.session_id}/{self.source_node}"
            full_cmd = f"vcmd -c {vcmd_path} -- {command}"

        try:
            result = subprocess.run(
                full_cmd,
                shell=True,
                capture_output=True,
                text=True,
                timeout=timeout
            )
            success = result.returncode == 0
            output = result.stdout if success else result.stderr
            return success, output.strip()
        except subprocess.TimeoutExpired:
            return False, "Command timed out"
        except Exception as e:
            return False, str(e)

    def publish(self, topic: str, payload: str, qos: int = 0) -> bool:
        """
        Publish an MQTT message from inside the CORE network.

        This uses mosquitto_pub executed inside a CORE node, so the
        TCP packets actually traverse the virtual network.
        """
        # Escape payload for shell
        escaped_payload = payload.replace("'", "'\"'\"'")

        # Build mosquitto_pub command
        cmd = f"mosquitto_pub -h {self.broker_ip} -p 1883 -t '{topic}' -m '{escaped_payload}' -q {qos}"

        success, output = self._execute_in_core(cmd)

        if success:
            self.message_count += 1
            if self.message_count % 10 == 0:
                print(f"[PHONE-INJECTOR] Published {self.message_count} phone sensor messages to CORE network")
        else:
            print(f"[PHONE-INJECTOR] Publish failed: {output}")

        return success

    def queue_message(self, topic: str, payload: dict):
        """Queue a message for async publishing"""
        self.message_queue.put((topic, json.dumps(payload)))

    def _worker_loop(self):
        """Background worker that processes the message queue"""
        while self.running:
            try:
                topic, payload = self.message_queue.get(timeout=0.5)
                self.publish(topic, payload)
                self.message_queue.task_done()
            except queue.Empty:
                continue
            except Exception as e:
                print(f"[PHONE-INJECTOR] Worker error: {e}")

    def start(self):
        """Start the background worker"""
        self.running = True
        self.worker_thread = threading.Thread(target=self._worker_loop, daemon=True)
        self.worker_thread.start()
        print(f"[PHONE-INJECTOR] Started - publishing phone sensor data to {self.broker_ip} via node '{self.source_node}'")

    def stop(self):
        """Stop the background worker"""
        self.running = False
        if self.worker_thread:
            self.worker_thread.join(timeout=2)
        print(f"[PHONE-INJECTOR] Stopped. Total phone sensor messages published: {self.message_count}")

    def test_connection(self) -> bool:
        """Test that we can reach the MQTT broker from inside CORE"""
        # Try a simple publish
        success = self.publish("core/sensors/phone-test", json.dumps({"test": True, "timestamp": time.time(), "device": "phone"}))
        if success:
            print(f"[PHONE-INJECTOR] Connection test successful - MQTT broker reachable at {self.broker_ip}")
        else:
            print(f"[PHONE-INJECTOR] Connection test FAILED - cannot reach {self.broker_ip}")
        return success


class PhoneInjectorHTTPHandler(BaseHTTPRequestHandler):
    """HTTP handler for receiving phone sensor data and injecting into CORE"""

    injector: PhoneMQTTInjector = None  # Set by server

    def log_message(self, format, *args):
        # Suppress default logging
        pass

    def do_POST(self):
        """Handle POST /inject - inject phone sensor data into CORE network"""
        parsed = urlparse(self.path)

        if parsed.path.startswith('/inject/'):
            # Extract sensor_id from path: /inject/{sensor_id}
            parts = parsed.path.split('/')
            sensor_id = parts[2] if len(parts) > 2 else 'unknown'

            # Only process phone sensors
            if not sensor_id.startswith('phone-'):
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Only phone sensors accepted'}).encode())
                return

            # Read body
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')

            try:
                data = json.loads(body)

                # Add timestamp if not present
                if 'timestamp' not in data:
                    data['timestamp'] = int(time.time() * 1000)

                # Mark as phone sensor data
                data['device'] = 'phone'

                # Queue for injection into CORE network
                topic = f"core/sensors/{sensor_id}/data"
                self.injector.queue_message(topic, data)

                # Return success
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()

                response = {
                    'status': 'queued',
                    'sensor_id': sensor_id,
                    'topic': topic,
                    'injected_to_core': True,
                    'device': 'phone'
                }
                self.wfile.write(json.dumps(response).encode())

            except json.JSONDecodeError as e:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        """Handle GET /status"""
        if self.path == '/status':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            status = {
                'running': self.injector.running if self.injector else False,
                'message_count': self.injector.message_count if self.injector else 0,
                'queue_size': self.injector.message_queue.qsize() if self.injector else 0,
                'broker_ip': self.injector.broker_ip if self.injector else None,
                'source_node': self.injector.source_node if self.injector else None,
                'sensor_type': 'phone'
            }
            self.wfile.write(json.dumps(status).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()


def find_core_session() -> Optional[int]:
    """Find running CORE session ID"""
    import glob
    sessions = glob.glob('/tmp/pycore.*')
    if sessions:
        # Extract session ID from path like /tmp/pycore.12345
        session_path = sessions[0]
        try:
            return int(session_path.split('.')[-1])
        except:
            pass
    return None


def find_mqtt_broker_node(session_id: int) -> Optional[Tuple[str, str, bool]]:
    """Find MQTT broker node in session. Returns (node_name, ip, is_docker)"""
    session_dir = f"/tmp/pycore.{session_id}"

    # Look for mqtt-broker node
    for name in ['mqtt-broker', 'broker', 'mosquitto']:
        node_path = os.path.join(session_dir, name)
        if os.path.exists(node_path):
            # Try to get IP from the node
            # For simplicity, assume standard IoT topology IP
            return (name, "10.0.1.10", True)

    return None


def main():
    parser = argparse.ArgumentParser(description="Phone Sensor MQTT Injector - Inject phone sensor data into CORE network")
    parser.add_argument("--session", type=int, help="CORE session ID")
    parser.add_argument("--broker-node", default="mqtt-broker", help="MQTT broker node name")
    parser.add_argument("--broker-ip", default="10.0.1.10", help="MQTT broker IP inside CORE")
    parser.add_argument("--source-node", help="Node to inject from (default: same as broker)")
    parser.add_argument("--port", type=int, default=8090, help="HTTP server port for receiving phone data")
    parser.add_argument("--no-docker", action="store_true", help="Broker is not a Docker node")
    parser.add_argument("--docker-host", default=None, help="Docker host container for DinD (e.g., 'core-novnc')")
    parser.add_argument("--auto", action="store_true", help="Auto-detect CORE session and broker")
    parser.add_argument("--test", action="store_true", help="Test connection and exit")

    args = parser.parse_args()

    # Auto-detect if requested
    session_id = args.session
    broker_node = args.broker_node
    broker_ip = args.broker_ip
    is_docker = not args.no_docker

    if args.auto:
        print("[PHONE-INJECTOR] Auto-detecting CORE session...")
        session_id = find_core_session()
        if not session_id:
            print("[PHONE-INJECTOR] ERROR: No CORE session found")
            sys.exit(1)
        print(f"[PHONE-INJECTOR] Found session: {session_id}")

        broker_info = find_mqtt_broker_node(session_id)
        if broker_info:
            broker_node, broker_ip, is_docker = broker_info
            print(f"[PHONE-INJECTOR] Found broker: {broker_node} @ {broker_ip}")

    if not session_id:
        print("[PHONE-INJECTOR] ERROR: No session ID provided. Use --session or --auto")
        sys.exit(1)

    # Create injector
    injector = PhoneMQTTInjector(
        session_id=session_id,
        broker_node=broker_node,
        broker_ip=broker_ip,
        is_docker=is_docker,
        source_node=args.source_node,
        docker_host=args.docker_host
    )

    # Test mode
    if args.test:
        print("[PHONE-INJECTOR] Testing connection...")
        success = injector.test_connection()
        sys.exit(0 if success else 1)

    # Start injector
    injector.start()

    # Test connection
    if not injector.test_connection():
        print("[PHONE-INJECTOR] Warning: Initial connection test failed")
        print("[PHONE-INJECTOR] Make sure CORE session is running and mqtt-broker node has mosquitto_pub")

    # Set up HTTP server
    PhoneInjectorHTTPHandler.injector = injector
    server = HTTPServer(('0.0.0.0', args.port), PhoneInjectorHTTPHandler)

    print(f"[PHONE-INJECTOR] HTTP server listening on port {args.port}")
    print(f"[PHONE-INJECTOR] Send phone sensor data to: POST http://localhost:{args.port}/inject/phone-{{sensor_id}}")
    print(f"[PHONE-INJECTOR] Data will be published to MQTT topic: core/sensors/phone-{{sensor_id}}/data")
    print(f"[PHONE-INJECTOR] The MQTT packets will be VISIBLE IN WIRESHARK on the CORE network!")

    # Handle signals
    def signal_handler(sig, frame):
        print("\n[PHONE-INJECTOR] Shutting down...")
        injector.stop()
        server.shutdown()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Run server
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        injector.stop()


if __name__ == "__main__":
    main()
