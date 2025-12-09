#!/usr/bin/env python3
"""
Phone Sensor Web UI - Standalone Flask server for phone sensor streaming

This is a SEPARATE server from web_ui.py specifically for phone sensors.
It does NOT modify the existing micro:bit system.

Features:
- /phone - Phone sensor page with QR code for mobile connection
- /phone-display - Display page for monitoring phone sensor data
- REST API for phone sensor data ingestion and retrieval
- Embedded MQTT injector for CORE network integration

Usage:
    python3 phone_web_ui.py --host 0.0.0.0 --port 8081
"""

from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import os
import sys
import json
import threading
import time
import queue
import subprocess
from pathlib import Path

# Add the core_mcp module to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# ============================================================================
# Phone Sensor Data Store
# ============================================================================

phone_sensor_store = {
    'sensors': {},      # sensor_id -> sensor config
    'readings': {},     # sensor_id -> list of recent readings (circular buffer)
}
MAX_SENSOR_READINGS = 1000  # Keep last 1000 readings per sensor

# Control commands queue (for sending commands back to phone if needed)
control_commands = {}  # sensor_id -> list of pending commands


# ============================================================================
# Embedded CORE Network MQTT Injector for Phone Sensors
# ============================================================================

class PhoneEmbeddedMQTTInjector:
    """
    Injects phone sensor MQTT messages into CORE network using docker exec.

    This creates REAL network traffic inside CORE (visible in Wireshark).
    Architecture: Phone Browser -> phone_web_ui -> this injector -> docker exec -> CORE Network
    """

    def __init__(self):
        self.session_id = None
        self.broker_node = None
        self.broker_ip = None
        self.source_node = None
        self.docker_host = 'core-novnc'  # Docker-in-Docker host

        self.message_queue = queue.Queue()
        self.running = False
        self.message_count = 0
        self.worker_thread = None
        self.last_error = None

    def configure(self, session_id: int, broker_node: str, broker_ip: str, source_node: str = None):
        """Configure the injector for a specific CORE topology"""
        self.session_id = session_id
        self.broker_node = broker_node
        self.broker_ip = broker_ip
        self.source_node = source_node or broker_node
        self.last_error = None
        print(f"[PHONE-INJECTOR] Configured: session={session_id}, broker={broker_node}@{broker_ip}, source={self.source_node}")

    def _execute_in_core(self, command: str, timeout: int = 5):
        """Execute a command inside a CORE node's network namespace"""
        # Docker-in-Docker: run docker exec inside the host container
        full_cmd = f"docker exec {self.docker_host} docker exec {self.source_node} {command}"

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
        """Publish an MQTT message from inside the CORE network"""
        if not self.broker_ip:
            self.last_error = "Injector not configured"
            return False

        # Escape payload for shell
        escaped_payload = payload.replace("'", "'\"'\"'")

        # Build mosquitto_pub command
        cmd = f"mosquitto_pub -h {self.broker_ip} -p 1883 -t '{topic}' -m '{escaped_payload}' -q {qos}"

        success, output = self._execute_in_core(cmd)

        if success:
            self.message_count += 1
            if self.message_count % 100 == 0:
                print(f"[PHONE-INJECTOR] Published {self.message_count} phone sensor messages to CORE network")
        else:
            self.last_error = output
            if self.message_count % 50 == 0:  # Don't spam logs
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
                self.last_error = str(e)
                print(f"[PHONE-INJECTOR] Worker error: {e}")

    def start(self):
        """Start the background worker"""
        if self.running:
            return
        self.running = True
        self.worker_thread = threading.Thread(target=self._worker_loop, daemon=True)
        self.worker_thread.start()
        print(f"[PHONE-INJECTOR] Started - publishing phone data to {self.broker_ip} via node '{self.source_node}'")

    def stop(self):
        """Stop the background worker"""
        self.running = False
        if self.worker_thread:
            self.worker_thread.join(timeout=2)
        print(f"[PHONE-INJECTOR] Stopped. Total messages published: {self.message_count}")

    def get_status(self):
        """Get injector status"""
        return {
            'running': self.running,
            'configured': self.broker_ip is not None,
            'message_count': self.message_count,
            'queue_size': self.message_queue.qsize(),
            'broker_ip': self.broker_ip,
            'source_node': self.source_node,
            'last_error': self.last_error,
            'sensor_type': 'phone'
        }


# Global phone injector instance
phone_injector = PhoneEmbeddedMQTTInjector()


# ============================================================================
# Routes - HTML Pages
# ============================================================================

@app.route('/')
def index():
    """Redirect to phone sensor page"""
    return render_template('phone_sensor.html')


@app.route('/phone')
def phone_sensor_page():
    """Phone sensor streaming page with QR code"""
    return render_template('phone_sensor.html')


@app.route('/phone-display')
def phone_display_page():
    """Phone sensor data display page"""
    return render_template('phone_display.html')


# ============================================================================
# Routes - Sensor Data API
# ============================================================================

@app.route('/api/sensors', methods=['GET'])
def get_all_sensors():
    """Get list of all connected phone sensors"""
    result = {
        'sensors': {},
        'count': 0
    }

    for sensor_id, sensor in phone_sensor_store['sensors'].items():
        # Only include phone sensors
        if sensor_id.startswith('phone-'):
            result['sensors'][sensor_id] = {
                'id': sensor_id,
                'type': sensor.get('type', 'phone'),
                'registered_at': sensor.get('registered_at'),
                'last_reading_at': sensor.get('last_reading_at'),
                'reading_count': len(phone_sensor_store['readings'].get(sensor_id, []))
            }

    result['count'] = len(result['sensors'])
    return jsonify(result)


@app.route('/api/sensors/<sensor_id>', methods=['GET'])
def get_sensor(sensor_id):
    """Get details for a specific phone sensor"""
    if sensor_id not in phone_sensor_store['sensors']:
        return jsonify({'error': 'Sensor not found'}), 404

    sensor = phone_sensor_store['sensors'][sensor_id]
    readings = phone_sensor_store['readings'].get(sensor_id, [])

    return jsonify({
        'sensor': sensor,
        'reading_count': len(readings),
        'latest_reading': readings[-1] if readings else None
    })


@app.route('/api/sensors/<sensor_id>/register', methods=['POST'])
def register_sensor(sensor_id):
    """Register a new phone sensor"""
    if not sensor_id.startswith('phone-'):
        return jsonify({'error': 'Sensor ID must start with phone-'}), 400

    data = request.get_json() or {}

    phone_sensor_store['sensors'][sensor_id] = {
        'id': sensor_id,
        'type': 'phone',
        'registered_at': time.time(),
        'last_reading_at': None,
        'config': data
    }

    if sensor_id not in phone_sensor_store['readings']:
        phone_sensor_store['readings'][sensor_id] = []

    print(f"[PHONE-WEB-UI] Registered phone sensor: {sensor_id}")

    return jsonify({
        'status': 'registered',
        'sensor_id': sensor_id
    })


@app.route('/api/sensors/<sensor_id>/data', methods=['POST'])
def receive_sensor_data(sensor_id):
    """Receive phone sensor data from the browser"""
    if not sensor_id.startswith('phone-'):
        return jsonify({'error': 'Only phone sensors accepted'}), 400

    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # Add timestamp if not present
    if 'timestamp' not in data:
        data['timestamp'] = int(time.time() * 1000)

    # Mark as phone sensor
    data['device'] = 'phone'

    # Auto-register sensor if not already registered
    if sensor_id not in phone_sensor_store['sensors']:
        phone_sensor_store['sensors'][sensor_id] = {
            'id': sensor_id,
            'type': 'phone',
            'registered_at': time.time(),
            'last_reading_at': None,
            'config': {}
        }
        phone_sensor_store['readings'][sensor_id] = []
        print(f"[PHONE-WEB-UI] Auto-registered phone sensor: {sensor_id}")

    # Update last reading time
    phone_sensor_store['sensors'][sensor_id]['last_reading_at'] = time.time()

    # Store reading (circular buffer)
    readings = phone_sensor_store['readings'][sensor_id]
    readings.append(data)
    if len(readings) > MAX_SENSOR_READINGS:
        readings.pop(0)

    return jsonify({
        'status': 'stored',
        'sensor_id': sensor_id,
        'reading_count': len(readings)
    })


@app.route('/api/sensors/<sensor_id>/readings', methods=['GET'])
def get_sensor_readings(sensor_id):
    """Get recent readings for a phone sensor"""
    if sensor_id not in phone_sensor_store['readings']:
        return jsonify({'error': 'Sensor not found'}), 404

    limit = request.args.get('limit', 100, type=int)
    readings = phone_sensor_store['readings'][sensor_id]

    return jsonify({
        'sensor_id': sensor_id,
        'readings': readings[-limit:],
        'total_count': len(readings)
    })


# ============================================================================
# Routes - CORE Network Injection API
# ============================================================================

@app.route('/api/inject/<sensor_id>', methods=['POST'])
def inject_to_core(sensor_id):
    """Inject phone sensor data into CORE network as real MQTT traffic"""
    if not sensor_id.startswith('phone-'):
        return jsonify({'error': 'Only phone sensors accepted'}), 400

    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # Add metadata
    if 'timestamp' not in data:
        data['timestamp'] = int(time.time() * 1000)
    data['device'] = 'phone'

    # Store locally first
    if sensor_id not in phone_sensor_store['sensors']:
        phone_sensor_store['sensors'][sensor_id] = {
            'id': sensor_id,
            'type': 'phone',
            'registered_at': time.time(),
            'last_reading_at': None,
            'config': {}
        }
        phone_sensor_store['readings'][sensor_id] = []

    phone_sensor_store['sensors'][sensor_id]['last_reading_at'] = time.time()
    readings = phone_sensor_store['readings'].setdefault(sensor_id, [])
    readings.append(data)
    if len(readings) > MAX_SENSOR_READINGS:
        readings.pop(0)

    # Queue for injection into CORE network
    if phone_injector.running:
        topic = f"core/sensors/{sensor_id}/data"
        phone_injector.queue_message(topic, data)
        injected = True
    else:
        injected = False

    return jsonify({
        'status': 'queued' if injected else 'stored_only',
        'sensor_id': sensor_id,
        'topic': f"core/sensors/{sensor_id}/data" if injected else None,
        'injected_to_core': injected
    })


@app.route('/api/inject/status', methods=['GET'])
def get_inject_status():
    """Get phone injector status"""
    return jsonify(phone_injector.get_status())


@app.route('/api/inject/configure', methods=['POST'])
def configure_injector():
    """Configure the phone MQTT injector for a CORE topology"""
    data = request.get_json() or {}

    session_id = data.get('session_id', 1)
    broker_node = data.get('broker_node', 'mqtt-broker')
    broker_ip = data.get('broker_ip', '10.0.1.10')
    source_node = data.get('source_node', broker_node)

    phone_injector.configure(session_id, broker_node, broker_ip, source_node)
    phone_injector.start()

    return jsonify({
        'status': 'configured',
        'session_id': session_id,
        'broker_node': broker_node,
        'broker_ip': broker_ip,
        'source_node': source_node
    })


# ============================================================================
# Routes - Control Commands (for bidirectional communication)
# ============================================================================

@app.route('/api/control/<sensor_id>', methods=['POST'])
def send_control_command(sensor_id):
    """Send a control command to a phone sensor"""
    data = request.get_json()
    if not data or 'command' not in data:
        return jsonify({'error': 'No command provided'}), 400

    if sensor_id not in control_commands:
        control_commands[sensor_id] = []

    control_commands[sensor_id].append({
        'command': data['command'],
        'timestamp': time.time(),
        'params': data.get('params', {})
    })

    return jsonify({
        'status': 'queued',
        'sensor_id': sensor_id,
        'command': data['command']
    })


@app.route('/api/control/<sensor_id>/pending', methods=['GET'])
def get_pending_commands(sensor_id):
    """Get pending control commands for a phone sensor"""
    commands = control_commands.pop(sensor_id, [])
    return jsonify({
        'sensor_id': sensor_id,
        'commands': commands
    })


# ============================================================================
# Routes - Health & Status
# ============================================================================

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'ok',
        'service': 'phone-sensor-web-ui',
        'sensors_count': len([s for s in phone_sensor_store['sensors'] if s.startswith('phone-')]),
        'injector_running': phone_injector.running
    })


# ============================================================================
# Main
# ============================================================================

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Phone Sensor Web UI Server")
    parser.add_argument("--host", default="0.0.0.0", help="Host to bind to")
    parser.add_argument("--port", type=int, default=8081, help="Port to listen on")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode")
    parser.add_argument("--auto-configure-injector", action="store_true",
                        help="Auto-configure MQTT injector with default settings")

    args = parser.parse_args()

    # Auto-configure injector if requested
    if args.auto_configure_injector:
        print("[PHONE-WEB-UI] Auto-configuring MQTT injector...")
        phone_injector.configure(
            session_id=1,
            broker_node='mqtt-broker',
            broker_ip='10.0.1.10',
            source_node='mqtt-broker'
        )
        phone_injector.start()

    print(f"""
========================================
   Phone Sensor Web UI Server
========================================

Server running at: http://{args.host}:{args.port}

Pages:
  /phone         - Phone sensor page (open on mobile)
  /phone-display - Display page (open on desktop)

API Endpoints:
  GET  /api/sensors                    - List connected phones
  POST /api/sensors/<id>/data          - Receive sensor data
  GET  /api/sensors/<id>/readings      - Get sensor readings
  POST /api/inject/<id>                - Inject to CORE network
  GET  /api/inject/status              - Injector status
  POST /api/inject/configure           - Configure injector

To use:
  1. Open /phone on your mobile device
  2. Grant sensor permissions
  3. Start streaming
  4. View data on /phone-display

========================================
""")

    app.run(host=args.host, port=args.port, debug=args.debug, threaded=True)


if __name__ == '__main__':
    main()
