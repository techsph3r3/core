#!/usr/bin/env python3
"""
MQTT Bridge for CORE Network Emulator

Bridges MQTT messages from the host broker to CORE network broker.
This solves the problem where physical devices (like micro:bit) publish
to localhost:1883, but CORE network nodes need data at 10.0.1.10:1883.

The bridge uses nsenter to access the CORE network namespace.

Usage:
    python3 mqtt_bridge.py --source localhost:1883 --dest 10.0.1.10:1883 --topic "core/sensors/#"
"""

import argparse
import subprocess
import threading
import time
import json
import os
import signal
import sys

# Try to import paho-mqtt
try:
    import paho.mqtt.client as mqtt
except ImportError:
    print("ERROR: paho-mqtt not installed. Run: pip install paho-mqtt")
    sys.exit(1)


class MQTTBridge:
    """Bridges MQTT messages between two brokers"""

    def __init__(self, source_host, source_port, dest_host, dest_port,
                 topics, use_nsenter=False, container_pid=None):
        self.source_host = source_host
        self.source_port = source_port
        self.dest_host = dest_host
        self.dest_port = dest_port
        self.topics = topics if isinstance(topics, list) else [topics]
        self.use_nsenter = use_nsenter
        self.container_pid = container_pid

        self.source_client = None
        self.dest_client = None
        self.running = False
        self.message_count = 0
        self.last_message_time = None

    def _create_source_client(self):
        """Create client for source (host) broker"""
        client = mqtt.Client(client_id="mqtt-bridge-source")
        client.on_connect = self._on_source_connect
        client.on_message = self._on_source_message
        client.on_disconnect = self._on_source_disconnect
        return client

    def _create_dest_client(self):
        """Create client for destination (CORE) broker"""
        client = mqtt.Client(client_id="mqtt-bridge-dest")
        client.on_connect = self._on_dest_connect
        client.on_disconnect = self._on_dest_disconnect
        return client

    def _on_source_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print(f"[BRIDGE] Connected to source broker {self.source_host}:{self.source_port}")
            for topic in self.topics:
                client.subscribe(topic)
                print(f"[BRIDGE] Subscribed to: {topic}")
        else:
            print(f"[BRIDGE] Source connection failed: {rc}")

    def _on_source_disconnect(self, client, userdata, rc):
        print(f"[BRIDGE] Disconnected from source broker")

    def _on_dest_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print(f"[BRIDGE] Connected to destination broker {self.dest_host}:{self.dest_port}")
        else:
            print(f"[BRIDGE] Destination connection failed: {rc}")

    def _on_dest_disconnect(self, client, userdata, rc):
        print(f"[BRIDGE] Disconnected from destination broker")

    def _on_source_message(self, client, userdata, msg):
        """Forward message from source to destination"""
        try:
            if self.dest_client and self.dest_client.is_connected():
                self.dest_client.publish(msg.topic, msg.payload, qos=msg.qos)
                self.message_count += 1
                self.last_message_time = time.time()

                # Log periodically
                if self.message_count % 10 == 0:
                    print(f"[BRIDGE] Forwarded {self.message_count} messages")

        except Exception as e:
            print(f"[BRIDGE] Error forwarding message: {e}")

    def _connect_via_nsenter(self):
        """
        For CORE network access, we need to use nsenter to enter the
        container's network namespace. This is tricky with MQTT since
        we need a persistent connection.

        Alternative approach: Use socat to create a TCP tunnel
        """
        if not self.container_pid:
            print("[BRIDGE] ERROR: No container PID provided for nsenter")
            return False

        # Create a socat tunnel from localhost:1884 to CORE broker
        # socat listens locally and uses nsenter to forward to container
        tunnel_port = 1884

        # Create wrapper script
        wrapper_script = f"/tmp/mqtt_ns_forward.sh"
        with open(wrapper_script, 'w') as f:
            f.write(f"#!/bin/sh\n")
            f.write(f"exec nsenter -n -t {self.container_pid} socat STDIO TCP:{self.dest_host}:{self.dest_port}\n")
        os.chmod(wrapper_script, 0o755)

        # Start socat tunnel in background
        cmd = f"socat TCP-LISTEN:{tunnel_port},fork,reuseaddr EXEC:{wrapper_script}"
        self.socat_proc = subprocess.Popen(cmd, shell=True)
        time.sleep(1)

        print(f"[BRIDGE] Created nsenter tunnel on localhost:{tunnel_port}")

        # Update destination to use tunnel
        self.dest_host = "localhost"
        self.dest_port = tunnel_port
        return True

    def start(self):
        """Start the bridge"""
        self.running = True

        # If using nsenter, set up tunnel first
        if self.use_nsenter:
            if not self._connect_via_nsenter():
                return False

        # Create clients
        self.source_client = self._create_source_client()
        self.dest_client = self._create_dest_client()

        # Connect to destination first
        try:
            print(f"[BRIDGE] Connecting to destination {self.dest_host}:{self.dest_port}...")
            self.dest_client.connect(self.dest_host, self.dest_port, 60)
            self.dest_client.loop_start()
            time.sleep(1)
        except Exception as e:
            print(f"[BRIDGE] Failed to connect to destination: {e}")
            return False

        # Connect to source
        try:
            print(f"[BRIDGE] Connecting to source {self.source_host}:{self.source_port}...")
            self.source_client.connect(self.source_host, self.source_port, 60)
            self.source_client.loop_start()
        except Exception as e:
            print(f"[BRIDGE] Failed to connect to source: {e}")
            self.dest_client.loop_stop()
            return False

        print("[BRIDGE] MQTT Bridge started successfully!")
        print(f"[BRIDGE] Forwarding: {self.source_host}:{self.source_port} -> {self.dest_host}:{self.dest_port}")
        print(f"[BRIDGE] Topics: {self.topics}")
        return True

    def stop(self):
        """Stop the bridge"""
        self.running = False

        if self.source_client:
            self.source_client.loop_stop()
            self.source_client.disconnect()

        if self.dest_client:
            self.dest_client.loop_stop()
            self.dest_client.disconnect()

        if hasattr(self, 'socat_proc') and self.socat_proc:
            self.socat_proc.terminate()

        print(f"[BRIDGE] Stopped. Total messages forwarded: {self.message_count}")

    def status(self):
        """Get bridge status"""
        return {
            "running": self.running,
            "source_connected": self.source_client.is_connected() if self.source_client else False,
            "dest_connected": self.dest_client.is_connected() if self.dest_client else False,
            "message_count": self.message_count,
            "last_message": self.last_message_time,
        }


def main():
    parser = argparse.ArgumentParser(description="MQTT Bridge for CORE Network")
    parser.add_argument("--source", default="localhost:1883",
                        help="Source broker (host:port)")
    parser.add_argument("--dest", default="10.0.1.10:1883",
                        help="Destination broker (host:port)")
    parser.add_argument("--topic", default="core/sensors/#",
                        help="Topic pattern to bridge")
    parser.add_argument("--nsenter-pid", type=int,
                        help="Container PID for nsenter (for CORE network access)")

    args = parser.parse_args()

    # Parse source
    source_parts = args.source.split(":")
    source_host = source_parts[0]
    source_port = int(source_parts[1]) if len(source_parts) > 1 else 1883

    # Parse dest
    dest_parts = args.dest.split(":")
    dest_host = dest_parts[0]
    dest_port = int(dest_parts[1]) if len(dest_parts) > 1 else 1883

    # Create bridge
    bridge = MQTTBridge(
        source_host=source_host,
        source_port=source_port,
        dest_host=dest_host,
        dest_port=dest_port,
        topics=args.topic,
        use_nsenter=args.nsenter_pid is not None,
        container_pid=args.nsenter_pid
    )

    # Handle signals
    def signal_handler(sig, frame):
        print("\n[BRIDGE] Shutting down...")
        bridge.stop()
        sys.exit(0)

    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # Start bridge
    if bridge.start():
        # Keep running
        while bridge.running:
            time.sleep(1)
    else:
        print("[BRIDGE] Failed to start")
        sys.exit(1)


if __name__ == "__main__":
    main()
