#!/usr/bin/env python3
"""
CORE MCP Topology Generator - Web UI
Provides a browser-based interface for generating network topologies using natural language
"""

# Gevent monkey-patching MUST be at the very top before any other imports
# This enables cooperative scheduling for proper WebSocket support
try:
    from gevent import monkey
    monkey.patch_all()
    GEVENT_AVAILABLE = True
except ImportError:
    GEVENT_AVAILABLE = False

from flask import Flask, render_template, request, jsonify, send_file, Response
from flask_cors import CORS
import os
import sys
import tempfile
import base64
import json
import copy
import threading
import time
from pathlib import Path
import openai

# WebSocket support for VNC proxy
# We use a custom middleware with gevent-websocket for compatibility with Werkzeug 3.x
try:
    import websocket as ws_client  # websocket-client library for backend VNC connections
    WEBSOCKET_AVAILABLE = True
except ImportError as e:
    WEBSOCKET_AVAILABLE = False
    ws_client = None
    print(f"Warning: websocket-client not available ({e}) - VNC proxy disabled")
    print("Install with: pip install websocket-client")

# Optional MQTT support
try:
    import paho.mqtt.client as mqtt
    MQTT_AVAILABLE = True
except ImportError:
    MQTT_AVAILABLE = False
    print("Warning: paho-mqtt not installed - MQTT features disabled. Install with: pip install paho-mqtt")

# Add the core_mcp module to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from core_mcp.topology_generator import TopologyGenerator, NodeConfig, LinkConfig
from core_mcp.appliance_registry import (
    APPLIANCE_REGISTRY,
    get_appliance,
    list_appliances,
    verify_all_appliances,
    check_appliance_ready,
    ApplianceCategory,
)

# OpenAI API key for vision and interpretation
# Checks multiple environment variable names for flexibility
OPENAI_API_KEY = (
    os.environ.get("MAKAU_API_LLM_OPENAI") or
    os.environ.get("OPENAI_API_KEY") or
    ""
)
if not OPENAI_API_KEY:
    print("Warning: No OpenAI API key found (checked MAKAU_API_LLM_OPENAI and OPENAI_API_KEY) - AI features will be disabled")
else:
    print("OpenAI API key loaded successfully")
openai.api_key = OPENAI_API_KEY

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# VNC WebSocket proxy middleware will be set up in main block
# We use a custom middleware approach for Werkzeug 3.x compatibility

# Store the current generator instance and interpretation state
current_generator = TopologyGenerator()
current_interpretation = None  # Stores the interpreted plan
last_deployed_template = None  # Stores the last deployed template for network info

# IoT Sensor Data Store - bridges physical sensors to CORE network nodes
sensor_data_store = {
    'sensors': {},  # sensor_id -> sensor config
    'readings': {},  # sensor_id -> list of recent readings (circular buffer)
    'bindings': {},  # sensor_id -> core_node_name (which CORE node receives this sensor's data)
}
MAX_SENSOR_READINGS = 1000  # Keep last 1000 readings per sensor

# MQTT Configuration
MQTT_CONFIG = {
    'broker_host': os.environ.get('MQTT_BROKER_HOST', 'localhost'),
    'broker_port': int(os.environ.get('MQTT_BROKER_PORT', 1883)),
    'websocket_port': int(os.environ.get('MQTT_WEBSOCKET_PORT', 9001)),
    'base_topic': 'core/sensors',
    'enabled': False,  # Will be set to True when connected
}

# Global MQTT client (will be initialized if broker is available)
mqtt_client = None
mqtt_connected = False


# ============================================================================
# Embedded CORE Network MQTT Injector
# Injects sensor data INTO the CORE network as real MQTT packets
# Auto-started when a topology with mqtt-broker is deployed
# ============================================================================

import queue
import subprocess

class EmbeddedMQTTInjector:
    """
    Injects MQTT messages into CORE network using docker exec.

    This creates REAL network traffic inside CORE (visible in Wireshark).
    Architecture: Browser -> web_ui -> this injector -> docker exec -> CORE Network
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
        print(f"[INJECTOR] Configured: session={session_id}, broker={broker_node}@{broker_ip}, source={self.source_node}")

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
                print(f"[INJECTOR] Published {self.message_count} messages to CORE network")
        else:
            self.last_error = output
            if self.message_count % 50 == 0:  # Don't spam logs
                print(f"[INJECTOR] Publish failed: {output}")

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
                print(f"[INJECTOR] Worker error: {e}")

    def start(self):
        """Start the background worker"""
        if self.running:
            return
        self.running = True
        self.worker_thread = threading.Thread(target=self._worker_loop, daemon=True)
        self.worker_thread.start()
        print(f"[INJECTOR] Started - publishing to {self.broker_ip} via node '{self.source_node}'")

    def stop(self):
        """Stop the background worker"""
        self.running = False
        if self.worker_thread:
            self.worker_thread.join(timeout=2)
        print(f"[INJECTOR] Stopped. Total messages published: {self.message_count}")

    def test_connection(self) -> bool:
        """Test that we can reach the MQTT broker from inside CORE"""
        success = self.publish("core/sensors/test", json.dumps({"test": True, "timestamp": time.time()}))
        if success:
            print(f"[INJECTOR] Connection test successful - MQTT broker reachable at {self.broker_ip}")
        else:
            print(f"[INJECTOR] Connection test FAILED - cannot reach {self.broker_ip}")
        return success

    def get_status(self) -> dict:
        """Get injector status"""
        return {
            'running': self.running,
            'configured': self.broker_ip is not None,
            'session_id': self.session_id,
            'broker_node': self.broker_node,
            'broker_ip': self.broker_ip,
            'source_node': self.source_node,
            'message_count': self.message_count,
            'queue_size': self.message_queue.qsize(),
            'last_error': self.last_error,
        }


# Global embedded injector instance
embedded_injector = EmbeddedMQTTInjector()


def auto_start_injector_for_topology(template: dict, session_id: int = 1):
    """
    Auto-start the MQTT injector if the topology contains an mqtt-broker node.
    Called after a topology is successfully deployed.
    """
    global embedded_injector

    # Find mqtt-broker node in the template
    mqtt_broker = None
    for node in template.get('nodes', []):
        if node.get('name') == 'mqtt-broker' or 'mqtt' in node.get('image', '').lower():
            mqtt_broker = node
            break

    if not mqtt_broker:
        print("[INJECTOR] No MQTT broker node found in topology - skipping auto-start")
        return False

    # Get the broker IP from the node or links
    broker_ip = mqtt_broker.get('ip')
    if not broker_ip:
        # Try to find IP from links
        for link in template.get('links', []):
            if isinstance(link, dict):
                if link.get('to') == mqtt_broker['name'] and link.get('ip2'):
                    broker_ip = link['ip2']
                    break
                elif link.get('from') == mqtt_broker['name'] and link.get('ip1'):
                    broker_ip = link['ip1']
                    break

    # If still no IP, try to query CORE for the node's IP
    if not broker_ip:
        print(f"[INJECTOR] No IP in template, querying CORE for node '{mqtt_broker['name']}'...")
        try:
            import subprocess
            # Query CORE for the node's IP address
            query_script = f'''
import json
from core.api.grpc import client
core = client.CoreGrpcClient()
core.connect()
session = core.get_session({session_id})
for node in session.nodes.values():
    if node.name == "{mqtt_broker['name']}":
        for iface in node.ifaces:
            if iface.ip4:
                print(iface.ip4.split("/")[0])
                break
        break
'''
            result = subprocess.run(
                f"docker exec core-novnc /opt/core/venv/bin/python3 -c '{query_script}'",
                shell=True, capture_output=True, text=True, timeout=10
            )
            if result.stdout.strip():
                broker_ip = result.stdout.strip()
                print(f"[INJECTOR] Found broker IP from CORE: {broker_ip}")
        except Exception as e:
            print(f"[INJECTOR] Failed to query CORE for IP: {e}")

    if not broker_ip:
        print(f"[INJECTOR] Could not determine IP for MQTT broker '{mqtt_broker['name']}'")
        return False

    # Configure and start the injector
    embedded_injector.configure(
        session_id=session_id,
        broker_node=mqtt_broker['name'],
        broker_ip=broker_ip,
        source_node=mqtt_broker['name']  # Inject from the broker node itself
    )

    # Start the background worker
    embedded_injector.start()

    # Test connection after a delay (broker needs time to start)
    def delayed_test():
        time.sleep(5)  # Wait for broker container to fully start
        embedded_injector.test_connection()

    test_thread = threading.Thread(target=delayed_test, daemon=True)
    test_thread.start()

    return True


def cleanup_docker_containers(node_names, container_host='core-novnc'):
    """
    Remove existing Docker containers that would conflict with new topology deployment.
    This handles the 'container name already in use' error by removing stale containers.

    Args:
        node_names: List of container names to clean up
        container_host: The Docker host container (default: core-novnc for DinD setup)

    Returns:
        dict with 'removed' and 'errors' lists
    """
    import subprocess

    result = {'removed': [], 'errors': [], 'skipped': []}

    # Protected containers that should never be removed
    protected = {'core-novnc', 'core-daemon'}

    for name in node_names:
        if name in protected:
            result['skipped'].append(f"{name} (protected)")
            continue

        try:
            # Check if container exists (running or stopped)
            check_cmd = f"docker exec {container_host} docker ps -a --filter name=^{name}$ --format '{{{{.Names}}}}'"
            check_result = subprocess.run(check_cmd, shell=True, capture_output=True, text=True, timeout=10)

            if check_result.stdout.strip() == name:
                # Container exists - stop and remove it
                stop_cmd = f"docker exec {container_host} docker rm -f {name}"
                rm_result = subprocess.run(stop_cmd, shell=True, capture_output=True, text=True, timeout=30)

                if rm_result.returncode == 0:
                    result['removed'].append(name)
                    print(f"Cleaned up existing container: {name}")
                else:
                    result['errors'].append(f"{name}: {rm_result.stderr.strip()}")
        except subprocess.TimeoutExpired:
            result['errors'].append(f"{name}: timeout")
        except Exception as e:
            result['errors'].append(f"{name}: {str(e)}")

    return result


def init_mqtt_client():
    """Initialize MQTT client connection to broker"""
    global mqtt_client, mqtt_connected

    if not MQTT_AVAILABLE:
        print("MQTT library not available")
        return False

    try:
        mqtt_client = mqtt.Client(client_id="core-web-ui", protocol=mqtt.MQTTv311)

        def on_connect(client, userdata, flags, rc):
            global mqtt_connected
            if rc == 0:
                mqtt_connected = True
                MQTT_CONFIG['enabled'] = True
                print(f"Connected to MQTT broker at {MQTT_CONFIG['broker_host']}:{MQTT_CONFIG['broker_port']}")
                # Subscribe to sensor commands (for bidirectional communication)
                client.subscribe(f"{MQTT_CONFIG['base_topic']}/+/command")
            else:
                print(f"Failed to connect to MQTT broker: {rc}")

        def on_disconnect(client, userdata, rc):
            global mqtt_connected
            mqtt_connected = False
            MQTT_CONFIG['enabled'] = False
            print("Disconnected from MQTT broker")

        def on_message(client, userdata, msg):
            # Handle incoming MQTT messages (commands to sensors)
            try:
                topic_parts = msg.topic.split('/')
                if len(topic_parts) >= 3 and topic_parts[-1] == 'command':
                    sensor_id = topic_parts[-2]
                    command = json.loads(msg.payload.decode())
                    print(f"Received command for sensor {sensor_id}: {command}")
                    # Store command for sensor to retrieve
                    if sensor_id in sensor_data_store['sensors']:
                        sensor_data_store['sensors'][sensor_id]['pending_command'] = command
            except Exception as e:
                print(f"Error processing MQTT message: {e}")

        mqtt_client.on_connect = on_connect
        mqtt_client.on_disconnect = on_disconnect
        mqtt_client.on_message = on_message

        # Try to connect (non-blocking)
        mqtt_client.connect_async(MQTT_CONFIG['broker_host'], MQTT_CONFIG['broker_port'], 60)
        mqtt_client.loop_start()
        return True

    except Exception as e:
        print(f"Failed to initialize MQTT client: {e}")
        return False


def publish_sensor_data(sensor_id: str, data: dict):
    """Publish sensor data to MQTT broker"""
    global mqtt_client, mqtt_connected

    if not mqtt_connected or mqtt_client is None:
        return False

    try:
        topic = f"{MQTT_CONFIG['base_topic']}/{sensor_id}/data"
        payload = json.dumps(data)
        mqtt_client.publish(topic, payload, qos=0)
        return True
    except Exception as e:
        print(f"Failed to publish to MQTT: {e}")
        return False


# Try to initialize MQTT on startup (will silently fail if broker not available)
threading.Thread(target=init_mqtt_client, daemon=True).start()

@app.route('/')
def index():
    """Redirect to dashboard"""
    return render_template('dashboard.html')

@app.route('/generator')
def generator():
    """Original topology generator interface"""
    return render_template('index.html')

@app.route('/dashboard')
def dashboard():
    """Main dashboard with tabs for Builder, CORE GUI, and VNC hosts"""
    return render_template('dashboard.html')

@app.route('/microbit')
def microbit():
    """Micro:bit WebSerial sensor interface with time-series graph"""
    return render_template('microbit.html')

@app.route('/sensor-display')
def sensor_display():
    """MQTT Sensor Display - shows real-time sensor data via MQTT subscription"""
    return render_template('sensor_display.html')


@app.route('/phone')
def phone_sensor_page():
    """Phone sensor streaming page - access from mobile device to stream accelerometer/gyroscope data"""
    return render_template('phone_sensor.html')


@app.route('/phone-display')
def phone_display_page():
    """Phone sensor data display page - monitor connected phone sensors"""
    return render_template('phone_display.html')

@app.route('/api/mqtt/status', methods=['GET'])
def mqtt_status():
    """Get MQTT connection status and configuration"""
    return jsonify({
        'available': MQTT_AVAILABLE,
        'connected': mqtt_connected,
        'config': {
            'broker_host': MQTT_CONFIG['broker_host'],
            'broker_port': MQTT_CONFIG['broker_port'],
            'websocket_port': MQTT_CONFIG['websocket_port'],
            'base_topic': MQTT_CONFIG['base_topic'],
        }
    })

@app.route('/api/mqtt/connect', methods=['POST'])
def mqtt_connect():
    """Manually trigger MQTT connection attempt"""
    data = request.get_json() or {}

    # Update config if provided
    if 'broker_host' in data:
        MQTT_CONFIG['broker_host'] = data['broker_host']
    if 'broker_port' in data:
        MQTT_CONFIG['broker_port'] = int(data['broker_port'])

    # Try to connect
    success = init_mqtt_client()
    return jsonify({
        'status': 'connecting' if success else 'failed',
        'config': MQTT_CONFIG,
    })

@app.route('/api/generate', methods=['POST'])
def generate_topology():
    """Generate topology from natural language description"""
    try:
        data = request.get_json()
        description = data.get('description', '')

        if not description:
            return jsonify({'error': 'Description is required'}), 400

        # Create new generator for this topology
        global current_generator
        current_generator = TopologyGenerator()

        # Generate from description
        result = current_generator.generate_from_description(description)

        # Get summary
        summary = current_generator.get_summary()

        return jsonify({
            'success': True,
            'result': result,
            'summary': summary,
            'nodes': len(current_generator.nodes),
            'links': len(current_generator.links)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/topology/current-xml', methods=['GET'])
def get_current_xml():
    """Get current topology XML as JSON (for AI builder context)"""
    try:
        if not current_generator or not current_generator.nodes:
            return jsonify({
                'success': False,
                'xml': None,
                'error': 'No topology deployed'
            })

        xml_content = current_generator.to_xml()
        return jsonify({
            'success': True,
            'xml': xml_content,
            'node_count': len(current_generator.nodes),
            'link_count': len(current_generator.links) if hasattr(current_generator, 'links') else 0
        })
    except Exception as e:
        return jsonify({'success': False, 'xml': None, 'error': str(e)}), 500

@app.route('/api/download/xml', methods=['GET'])
def download_xml():
    """Download generated topology as XML file"""
    try:
        xml_content = current_generator.to_xml()

        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml', delete=False) as f:
            f.write(xml_content)
            temp_path = f.name

        return send_file(
            temp_path,
            as_attachment=True,
            download_name='topology.xml',
            mimetype='application/xml'
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/download/python', methods=['GET'])
def download_python():
    """Download generated topology as Python script"""
    try:
        python_content = current_generator.to_python_script()

        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(python_content)
            temp_path = f.name

        return send_file(
            temp_path,
            as_attachment=True,
            download_name='topology.py',
            mimetype='text/x-python'
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/save', methods=['POST'])
def save_topology():
    """Save topology files to specified location"""
    try:
        data = request.get_json()
        filename = data.get('filename', 'topology')
        save_path = data.get('path', '/tmp')

        # Ensure filename has no extension
        filename = filename.replace('.xml', '').replace('.py', '')

        # Create directory if it doesn't exist
        Path(save_path).mkdir(parents=True, exist_ok=True)

        # Save XML
        xml_path = os.path.join(save_path, f"{filename}.xml")
        with open(xml_path, 'w') as f:
            f.write(current_generator.to_xml())

        # Save Python script
        py_path = os.path.join(save_path, f"{filename}.py")
        with open(py_path, 'w') as f:
            f.write(current_generator.to_python_script())

        return jsonify({
            'success': True,
            'xml_path': xml_path,
            'py_path': py_path
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/examples', methods=['GET'])
def get_examples():
    """Get example topology descriptions"""
    examples = [
        {
            'name': 'Basic Ring',
            'description': 'Create a ring with 5 routers',
            'category': 'Basic'
        },
        {
            'name': 'Star Network',
            'description': 'Create a star with a switch and 8 hosts',
            'category': 'Basic'
        },
        {
            'name': 'Router Chain',
            'description': 'Build a line with 4 routers',
            'category': 'Basic'
        },
        {
            'name': 'Wireless Mesh',
            'description': 'Create a wireless mesh with 6 MDR nodes',
            'category': 'Wireless'
        },
        {
            'name': 'Large Wireless Network',
            'description': 'Build a wireless mesh with 12 MDR nodes',
            'category': 'Wireless'
        },
        {
            'name': 'Docker Tailscale Mesh',
            'description': 'Create a tailscale mesh with 5 docker nodes',
            'category': 'Advanced'
        },
        {
            'name': 'Enterprise Network',
            'description': 'Create a star with a switch and 20 hosts',
            'category': 'Advanced'
        },
        {
            'name': 'Backbone Ring',
            'description': 'Build a ring with 10 routers',
            'category': 'Advanced'
        },
        {
            'name': 'Caldera Red Team Lab',
            'description': 'Create a caldera red team topology with 3 target machines',
            'category': 'Security'
        },
        {
            'name': 'Adversary Emulation Lab',
            'description': 'Create an adversary emulation lab with caldera server and 5 victims',
            'category': 'Security'
        },
        {
            'name': 'Nginx Web Farm',
            'description': 'Create a web server farm with 4 nginx servers',
            'category': 'Docker'
        },
        {
            'name': 'IT/OT Network with Firewall',
            'description': 'Create an IT/OT network with VyOS firewall separating IT workstations from OT devices including OpenPLC',
            'category': 'Industrial'
        },
        {
            'name': 'OT Network with IDS',
            'description': 'Create an OT network with Suricata IDS monitoring traffic to PLCs',
            'category': 'Industrial'
        },
        {
            'name': 'Load Balanced Web Farm',
            'description': 'Create a web farm with HAProxy load balancer and 3 nginx backend servers',
            'category': 'Docker'
        },
        {
            'name': 'VPN Gateway Network',
            'description': 'Create a network with WireGuard VPN gateway connecting remote users to internal servers',
            'category': 'Security'
        }
    ]

    return jsonify({'examples': examples})


# =============================================================================
# QUICK-START TEMPLATES
# =============================================================================

QUICK_START_TEMPLATES = {
    # -------------------------------------------------------------------------
    # BASIC TOPOLOGIES - Simple network shapes for learning (auto-assign IPs)
    # -------------------------------------------------------------------------
    'basic-3-hosts': {
        'id': 'basic-3-hosts',
        'name': '3 Hosts + Switch',
        'category': 'Basic',
        'icon': 'network',
        'description': 'Simplest network: 3 hosts connected to a switch',
        'complexity': 1,
        'auto_ip': True,  # Let CORE auto-assign IPs
        'networks': {
            'switch1': {'subnet': '10.0.0.0/24', 'gateway': '10.0.0.1'}
        },
        'nodes': [
            {'name': 'switch1', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'host1', 'type': 'host', 'x': 150, 'y': 350, 'ip': '10.0.0.10'},
            {'name': 'host2', 'type': 'host', 'x': 300, 'y': 350, 'ip': '10.0.0.11'},
            {'name': 'host3', 'type': 'host', 'x': 450, 'y': 350, 'ip': '10.0.0.12'},
        ],
        'links': [
            {'from': 'switch1', 'to': 'host1', 'ip2': '10.0.0.10'},
            {'from': 'switch1', 'to': 'host2', 'ip2': '10.0.0.11'},
            {'from': 'switch1', 'to': 'host3', 'ip2': '10.0.0.12'},
        ],
    },
    'basic-5-star': {
        'id': 'basic-5-star',
        'name': '5-Node Star',
        'category': 'Basic',
        'icon': 'star',
        'description': 'Star topology with central switch and 5 hosts',
        'complexity': 1,
        'auto_ip': True,
        'networks': {
            'switch1': {'subnet': '10.0.0.0/24', 'gateway': '10.0.0.1'}
        },
        'nodes': [
            {'name': 'switch1', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'host1', 'type': 'host', 'x': 150, 'y': 100, 'ip': '10.0.0.10'},
            {'name': 'host2', 'type': 'host', 'x': 450, 'y': 100, 'ip': '10.0.0.11'},
            {'name': 'host3', 'type': 'host', 'x': 100, 'y': 300, 'ip': '10.0.0.12'},
            {'name': 'host4', 'type': 'host', 'x': 500, 'y': 300, 'ip': '10.0.0.13'},
            {'name': 'host5', 'type': 'host', 'x': 300, 'y': 350, 'ip': '10.0.0.14'},
        ],
        'links': [
            {'from': 'switch1', 'to': 'host1', 'ip2': '10.0.0.10'},
            {'from': 'switch1', 'to': 'host2', 'ip2': '10.0.0.11'},
            {'from': 'switch1', 'to': 'host3', 'ip2': '10.0.0.12'},
            {'from': 'switch1', 'to': 'host4', 'ip2': '10.0.0.13'},
            {'from': 'switch1', 'to': 'host5', 'ip2': '10.0.0.14'},
        ],
    },
    'basic-5-ring': {
        'id': 'basic-5-ring',
        'name': '5-Router Ring',
        'category': 'Basic',
        'icon': 'ring',
        'description': 'Ring topology with 5 routers - classic backbone design',
        'complexity': 2,
        'auto_ip': False,
        'networks': {},  # Router-to-router links each get their own /30 subnet
        'nodes': [
            {'name': 'r1', 'type': 'router', 'x': 300, 'y': 100},
            {'name': 'r2', 'type': 'router', 'x': 450, 'y': 200},
            {'name': 'r3', 'type': 'router', 'x': 400, 'y': 350},
            {'name': 'r4', 'type': 'router', 'x': 200, 'y': 350},
            {'name': 'r5', 'type': 'router', 'x': 150, 'y': 200},
        ],
        'links': [
            {'from': 'r1', 'to': 'r2', 'ip1': '10.0.1.1', 'ip2': '10.0.1.2'},
            {'from': 'r2', 'to': 'r3', 'ip1': '10.0.2.1', 'ip2': '10.0.2.2'},
            {'from': 'r3', 'to': 'r4', 'ip1': '10.0.3.1', 'ip2': '10.0.3.2'},
            {'from': 'r4', 'to': 'r5', 'ip1': '10.0.4.1', 'ip2': '10.0.4.2'},
            {'from': 'r5', 'to': 'r1', 'ip1': '10.0.5.1', 'ip2': '10.0.5.2'},
        ],
    },
    'basic-line': {
        'id': 'basic-line',
        'name': '4-Router Chain',
        'category': 'Basic',
        'icon': 'line',
        'description': 'Linear chain of 4 routers',
        'complexity': 1,
        'auto_ip': False,
        'networks': {},
        'nodes': [
            {'name': 'r1', 'type': 'router', 'x': 100, 'y': 200},
            {'name': 'r2', 'type': 'router', 'x': 250, 'y': 200},
            {'name': 'r3', 'type': 'router', 'x': 400, 'y': 200},
            {'name': 'r4', 'type': 'router', 'x': 550, 'y': 200},
        ],
        'links': [
            {'from': 'r1', 'to': 'r2', 'ip1': '10.0.1.1', 'ip2': '10.0.1.2'},
            {'from': 'r2', 'to': 'r3', 'ip1': '10.0.2.1', 'ip2': '10.0.2.2'},
            {'from': 'r3', 'to': 'r4', 'ip1': '10.0.3.1', 'ip2': '10.0.3.2'},
        ],
    },

    # -------------------------------------------------------------------------
    # IT EXAMPLES - Corporate/Enterprise networks
    # -------------------------------------------------------------------------
    'it-small-office': {
        'id': 'it-small-office',
        'name': 'Small Office Network',
        'category': 'IT',
        'icon': 'office',
        'description': 'Router + switch + 4 workstations - typical small office',
        'complexity': 2,
        'auto_ip': False,
        'networks': {
            'switch1': {'subnet': '192.168.1.0/24', 'gateway': '192.168.1.1', 'name': 'Office-LAN'}
        },
        'nodes': [
            {'name': 'gateway', 'type': 'router', 'x': 300, 'y': 80},
            {'name': 'switch1', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'pc1', 'type': 'host', 'x': 100, 'y': 320, 'ip': '192.168.1.10'},
            {'name': 'pc2', 'type': 'host', 'x': 220, 'y': 320, 'ip': '192.168.1.11'},
            {'name': 'pc3', 'type': 'host', 'x': 380, 'y': 320, 'ip': '192.168.1.12'},
            {'name': 'server', 'type': 'host', 'x': 500, 'y': 320, 'ip': '192.168.1.100', 'services': ['HTTP', 'SSH']},
        ],
        'links': [
            {'from': 'gateway', 'to': 'switch1', 'ip1': '192.168.1.1'},
            {'from': 'switch1', 'to': 'pc1', 'ip2': '192.168.1.10'},
            {'from': 'switch1', 'to': 'pc2', 'ip2': '192.168.1.11'},
            {'from': 'switch1', 'to': 'pc3', 'ip2': '192.168.1.12'},
            {'from': 'switch1', 'to': 'server', 'ip2': '192.168.1.100'},
        ],
    },
    'it-dmz': {
        'id': 'it-dmz',
        'name': 'DMZ Architecture',
        'category': 'IT',
        'icon': 'shield',
        'description': 'Firewall with DMZ and internal network zones',
        'complexity': 3,
        'auto_ip': False,
        'networks': {
            'dmz-switch': {'subnet': '10.0.1.0/24', 'gateway': '10.0.1.1', 'name': 'DMZ'},
            'lan-switch': {'subnet': '10.0.2.0/24', 'gateway': '10.0.2.1', 'name': 'Internal-LAN'},
        },
        'nodes': [
            {'name': 'internet', 'type': 'host', 'x': 300, 'y': 50, 'ip': '203.0.113.100'},
            {'name': 'firewall', 'type': 'router', 'x': 300, 'y': 150, 'services': ['Firewall', 'IPForward']},
            {'name': 'dmz-switch', 'type': 'switch', 'x': 150, 'y': 250},
            {'name': 'lan-switch', 'type': 'switch', 'x': 450, 'y': 250},
            {'name': 'webserver', 'type': 'host', 'x': 100, 'y': 370, 'ip': '10.0.1.10', 'services': ['HTTP']},
            {'name': 'mailserver', 'type': 'host', 'x': 200, 'y': 370, 'ip': '10.0.1.11', 'services': ['SSH']},
            {'name': 'workstation1', 'type': 'host', 'x': 400, 'y': 370, 'ip': '10.0.2.10'},
            {'name': 'workstation2', 'type': 'host', 'x': 500, 'y': 370, 'ip': '10.0.2.11'},
        ],
        'links': [
            {'from': 'internet', 'to': 'firewall', 'ip1': '203.0.113.100', 'ip2': '203.0.113.1'},
            {'from': 'firewall', 'to': 'dmz-switch', 'ip1': '10.0.1.1'},
            {'from': 'firewall', 'to': 'lan-switch', 'ip1': '10.0.2.1'},
            {'from': 'dmz-switch', 'to': 'webserver', 'ip2': '10.0.1.10'},
            {'from': 'dmz-switch', 'to': 'mailserver', 'ip2': '10.0.1.11'},
            {'from': 'lan-switch', 'to': 'workstation1', 'ip2': '10.0.2.10'},
            {'from': 'lan-switch', 'to': 'workstation2', 'ip2': '10.0.2.11'},
        ],
    },

    # -------------------------------------------------------------------------
    # OT EXAMPLES - Industrial/SCADA networks
    # -------------------------------------------------------------------------
    'ot-simple-plc': {
        'id': 'ot-simple-plc',
        'name': 'Simple PLC Network',
        'category': 'OT',
        'icon': 'factory',
        'description': 'HMI + PLC + 2 field devices - minimal OT setup',
        'complexity': 2,
        'auto_ip': False,
        'networks': {
            'ot-switch': {'subnet': '10.10.1.0/24', 'gateway': '10.10.1.1', 'name': 'OT-Control'}
        },
        'nodes': [
            {'name': 'ot-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'hmi', 'type': 'host', 'x': 150, 'y': 100, 'ip': '10.10.1.10'},
            {'name': 'plc1', 'type': 'docker', 'x': 450, 'y': 100, 'image': 'openplc-core', 'ip': '10.10.1.100'},
            {'name': 'field-io1', 'type': 'host', 'x': 200, 'y': 350, 'ip': '10.10.1.201'},
            {'name': 'field-io2', 'type': 'host', 'x': 400, 'y': 350, 'ip': '10.10.1.202'},
        ],
        'links': [
            {'from': 'ot-switch', 'to': 'hmi', 'ip2': '10.10.1.10'},
            {'from': 'ot-switch', 'to': 'plc1', 'ip2': '10.10.1.100'},
            {'from': 'ot-switch', 'to': 'field-io1', 'ip2': '10.10.1.201'},
            {'from': 'ot-switch', 'to': 'field-io2', 'ip2': '10.10.1.202'},
        ],
    },
    'ot-water-system': {
        'id': 'ot-water-system',
        'name': 'Water Treatment Plant',
        'category': 'OT',
        'icon': 'water',
        'description': 'SCADA + 3 PLCs + historian - water treatment digital twin',
        'complexity': 3,
        'auto_ip': False,
        'networks': {
            'ot-switch': {'subnet': '10.10.0.0/24', 'gateway': '10.10.0.1', 'name': 'SCADA-Network'}
        },
        'nodes': [
            {'name': 'scada-server', 'type': 'host', 'x': 300, 'y': 80, 'ip': '10.10.0.10', 'services': ['HTTP', 'SSH']},
            {'name': 'historian', 'type': 'host', 'x': 500, 'y': 80, 'ip': '10.10.0.11'},
            {'name': 'ot-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'plc-intake', 'type': 'docker', 'x': 150, 'y': 320, 'image': 'openplc-core', 'ip': '10.10.0.101'},
            {'name': 'plc-treatment', 'type': 'docker', 'x': 300, 'y': 320, 'image': 'openplc-core', 'ip': '10.10.0.102'},
            {'name': 'plc-distribution', 'type': 'docker', 'x': 450, 'y': 320, 'image': 'openplc-core', 'ip': '10.10.0.103'},
            {'name': 'hmi-ops', 'type': 'host', 'x': 100, 'y': 200, 'ip': '10.10.0.20'},
        ],
        'links': [
            {'from': 'ot-switch', 'to': 'scada-server', 'ip2': '10.10.0.10'},
            {'from': 'ot-switch', 'to': 'historian', 'ip2': '10.10.0.11'},
            {'from': 'ot-switch', 'to': 'plc-intake', 'ip2': '10.10.0.101'},
            {'from': 'ot-switch', 'to': 'plc-treatment', 'ip2': '10.10.0.102'},
            {'from': 'ot-switch', 'to': 'plc-distribution', 'ip2': '10.10.0.103'},
            {'from': 'ot-switch', 'to': 'hmi-ops', 'ip2': '10.10.0.20'},
        ],
    },
    'ot-it-segmented': {
        'id': 'ot-it-segmented',
        'name': 'IT/OT Segmented Network',
        'category': 'OT',
        'icon': 'layers',
        'description': 'Firewall separating IT corporate from OT industrial network',
        'complexity': 4,
        'auto_ip': False,
        'networks': {
            'it-switch': {'subnet': '192.168.1.0/24', 'gateway': '192.168.1.1', 'name': 'IT-Corporate'},
            'ot-switch': {'subnet': '10.10.0.0/24', 'gateway': '10.10.0.1', 'name': 'OT-Industrial'},
        },
        'nodes': [
            # IT Zone
            {'name': 'it-router', 'type': 'router', 'x': 150, 'y': 100},
            {'name': 'it-switch', 'type': 'switch', 'x': 150, 'y': 200},
            {'name': 'workstation1', 'type': 'host', 'x': 80, 'y': 320, 'ip': '192.168.1.10'},
            {'name': 'workstation2', 'type': 'host', 'x': 220, 'y': 320, 'ip': '192.168.1.11'},
            # Firewall (between IT and OT)
            {'name': 'ot-firewall', 'type': 'router', 'x': 350, 'y': 150, 'services': ['Firewall', 'IPForward']},
            # OT Zone
            {'name': 'ot-switch', 'type': 'switch', 'x': 500, 'y': 200},
            {'name': 'hmi', 'type': 'host', 'x': 420, 'y': 320, 'ip': '10.10.0.20'},
            {'name': 'plc1', 'type': 'docker', 'x': 500, 'y': 320, 'image': 'openplc-core', 'ip': '10.10.0.100'},
            {'name': 'historian', 'type': 'host', 'x': 580, 'y': 320, 'ip': '10.10.0.11'},
        ],
        'links': [
            {'from': 'it-router', 'to': 'it-switch', 'ip1': '192.168.1.1'},
            {'from': 'it-switch', 'to': 'workstation1', 'ip2': '192.168.1.10'},
            {'from': 'it-switch', 'to': 'workstation2', 'ip2': '192.168.1.11'},
            {'from': 'it-router', 'to': 'ot-firewall', 'ip1': '172.16.0.1', 'ip2': '172.16.0.2'},
            {'from': 'ot-firewall', 'to': 'ot-switch', 'ip1': '10.10.0.1'},
            {'from': 'ot-switch', 'to': 'hmi', 'ip2': '10.10.0.20'},
            {'from': 'ot-switch', 'to': 'plc1', 'ip2': '10.10.0.100'},
            {'from': 'ot-switch', 'to': 'historian', 'ip2': '10.10.0.11'},
        ],
    },

    # -------------------------------------------------------------------------
    # SECURITY EXAMPLES - Red team / Blue team labs
    # -------------------------------------------------------------------------
    'sec-pentest-lab': {
        'id': 'sec-pentest-lab',
        'name': 'Pentest Lab',
        'category': 'Security',
        'icon': 'target',
        'description': 'Kali attacker + 3 target machines for penetration testing',
        'complexity': 3,
        'auto_ip': False,
        'networks': {
            'lab-switch': {'subnet': '10.0.0.0/24', 'gateway': '10.0.0.1', 'name': 'Lab-Network'}
        },
        'nodes': [
            {'name': 'lab-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'kali', 'type': 'docker', 'x': 150, 'y': 100, 'image': 'kali-novnc-core', 'ip': '10.0.0.5'},
            {'name': 'target-web', 'type': 'host', 'x': 450, 'y': 100, 'ip': '10.0.0.10', 'services': ['HTTP', 'SSH']},
            {'name': 'target-db', 'type': 'host', 'x': 200, 'y': 350, 'ip': '10.0.0.11'},
            {'name': 'target-dc', 'type': 'host', 'x': 400, 'y': 350, 'ip': '10.0.0.12'},
        ],
        'links': [
            {'from': 'lab-switch', 'to': 'kali', 'ip2': '10.0.0.5'},
            {'from': 'lab-switch', 'to': 'target-web', 'ip2': '10.0.0.10'},
            {'from': 'lab-switch', 'to': 'target-db', 'ip2': '10.0.0.11'},
            {'from': 'lab-switch', 'to': 'target-dc', 'ip2': '10.0.0.12'},
        ],
    },
    'sec-caldera-c2': {
        'id': 'sec-caldera-c2',
        'name': 'Caldera C2 Lab',
        'category': 'Security',
        'icon': 'skull',
        'description': 'MITRE Caldera C2 server with 3 victim machines',
        'complexity': 3,
        'auto_ip': False,
        'networks': {
            'lab-switch': {'subnet': '10.0.0.0/24', 'gateway': '10.0.0.1', 'name': 'C2-Network'}
        },
        'nodes': [
            {'name': 'lab-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'caldera', 'type': 'docker', 'x': 300, 'y': 80, 'image': 'caldera-mcp-core', 'ip': '10.0.0.5'},
            {'name': 'victim1', 'type': 'host', 'x': 150, 'y': 350, 'ip': '10.0.0.10'},
            {'name': 'victim2', 'type': 'host', 'x': 300, 'y': 350, 'ip': '10.0.0.11'},
            {'name': 'victim3', 'type': 'host', 'x': 450, 'y': 350, 'ip': '10.0.0.12'},
        ],
        'links': [
            {'from': 'lab-switch', 'to': 'caldera', 'ip2': '10.0.0.5'},
            {'from': 'lab-switch', 'to': 'victim1', 'ip2': '10.0.0.10'},
            {'from': 'lab-switch', 'to': 'victim2', 'ip2': '10.0.0.11'},
            {'from': 'lab-switch', 'to': 'victim3', 'ip2': '10.0.0.12'},
        ],
    },

    # -------------------------------------------------------------------------
    # IOT EXAMPLES - IoT sensor networks for digital twin integration
    # -------------------------------------------------------------------------
    'iot-sensor-network': {
        'id': 'iot-sensor-network',
        'name': 'IoT Sensor Network',
        'category': 'IoT',
        'icon': 'sensor',
        'description': 'MQTT broker + sensor server + HMI - for micro:bit/sensor integration',
        'complexity': 2,
        'auto_ip': False,
        'networks': {
            'iot-switch': {'subnet': '10.0.1.0/24', 'gateway': '10.0.1.1', 'name': 'IoT-Network'}
        },
        'nodes': [
            {'name': 'iot-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'mqtt-broker', 'type': 'docker', 'x': 300, 'y': 80, 'image': 'mqtt-broker-core', 'ip': '10.0.1.10'},
            {'name': 'sensor-server', 'type': 'docker', 'x': 480, 'y': 150, 'image': 'iot-sensor-server', 'ip': '10.0.1.20'},
            {'name': 'hmi1', 'type': 'docker', 'x': 200, 'y': 350, 'image': 'hmi-workstation:latest', 'ip': '10.0.1.50'},
        ],
        'links': [
            {'from': 'iot-switch', 'to': 'mqtt-broker', 'ip2': '10.0.1.10'},
            {'from': 'iot-switch', 'to': 'sensor-server', 'ip2': '10.0.1.20'},
            {'from': 'iot-switch', 'to': 'hmi1', 'ip2': '10.0.1.50'},
        ],
    },
    'iot-multi-hmi': {
        'id': 'iot-multi-hmi',
        'name': 'IoT Multi-HMI Network',
        'category': 'IoT',
        'icon': 'sensor',
        'description': 'MQTT broker + sensor server + 3 HMI workstations',
        'complexity': 2,
        'auto_ip': False,
        'networks': {
            'iot-switch': {'subnet': '10.0.1.0/24', 'gateway': '10.0.1.1', 'name': 'IoT-Network'}
        },
        'nodes': [
            {'name': 'iot-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'mqtt-broker', 'type': 'docker', 'x': 300, 'y': 80, 'image': 'mqtt-broker-core', 'ip': '10.0.1.10'},
            {'name': 'sensor-server', 'type': 'docker', 'x': 480, 'y': 150, 'image': 'iot-sensor-server', 'ip': '10.0.1.20'},
            {'name': 'hmi1', 'type': 'docker', 'x': 150, 'y': 350, 'image': 'hmi-workstation:latest', 'ip': '10.0.1.50'},
            {'name': 'hmi2', 'type': 'docker', 'x': 300, 'y': 350, 'image': 'hmi-workstation:latest', 'ip': '10.0.1.51'},
            {'name': 'hmi3', 'type': 'docker', 'x': 450, 'y': 350, 'image': 'hmi-workstation:latest', 'ip': '10.0.1.52'},
        ],
        'links': [
            {'from': 'iot-switch', 'to': 'mqtt-broker', 'ip2': '10.0.1.10'},
            {'from': 'iot-switch', 'to': 'sensor-server', 'ip2': '10.0.1.20'},
            {'from': 'iot-switch', 'to': 'hmi1', 'ip2': '10.0.1.50'},
            {'from': 'iot-switch', 'to': 'hmi2', 'ip2': '10.0.1.51'},
            {'from': 'iot-switch', 'to': 'hmi3', 'ip2': '10.0.1.52'},
        ],
    },
    'phone-sensor-network': {
        'id': 'phone-sensor-network',
        'name': 'Phone Sensor Network',
        'category': 'IoT',
        'icon': 'phone',
        'description': 'Stream phone accelerometer/gyroscope data via MQTT bridge into CORE',
        'complexity': 2,
        'auto_ip': False,
        'networks': {
            'phone-switch': {'subnet': '10.0.1.0/24', 'gateway': '10.0.1.1', 'name': 'Phone-Sensor-Network'}
        },
        'nodes': [
            {'name': 'phone-switch', 'type': 'switch', 'x': 300, 'y': 200},
            {'name': 'mqtt-broker', 'type': 'docker', 'x': 300, 'y': 80, 'image': 'mqtt-broker-core', 'ip': '10.0.1.10'},
            {'name': 'phone-display-server', 'type': 'docker', 'x': 480, 'y': 150, 'image': 'iot-sensor-server', 'ip': '10.0.1.20'},
            {'name': 'phone-hmi1', 'type': 'docker', 'x': 200, 'y': 350, 'image': 'hmi-workstation:latest', 'ip': '10.0.1.50'},
        ],
        'links': [
            {'from': 'phone-switch', 'to': 'mqtt-broker', 'ip2': '10.0.1.10'},
            {'from': 'phone-switch', 'to': 'phone-display-server', 'ip2': '10.0.1.20'},
            {'from': 'phone-switch', 'to': 'phone-hmi1', 'ip2': '10.0.1.50'},
        ],
        'setup_instructions': '''
=== PHONE SENSOR NETWORK SETUP ===

1. START THE PHONE WEB UI (on host, outside CORE):
   cd /workspaces/core/core-mcp-server
   ./start_phone_system.sh

2. CONFIGURE THE MQTT BRIDGE:
   curl -X POST http://localhost:8081/api/inject/configure \\
     -H "Content-Type: application/json" \\
     -d '{"session_id": 1, "broker_node": "mqtt-broker", "broker_ip": "10.0.1.10", "source_node": "mqtt-broker"}'

3. CONNECT YOUR PHONE:
   - Open the Phone Sensor page (port 8081) on desktop
   - Scan the QR code with your phone
   - Grant sensor permissions and tap "Start Streaming"

4. VIEW DATA IN CORE:
   - Open phone-hmi1 via VNC
   - Browse to http://10.0.1.20/ to see live phone data

5. VERIFY WITH WIRESHARK:
   - In CORE GUI, right-click mqtt-broker -> Wireshark
   - Filter: mqtt
   - See PUBLISH packets with phone sensor data
''',
    },
}


@app.route('/api/templates', methods=['GET'])
def get_templates():
    """Get quick-start templates organized by category"""
    # Organize by category
    categories = {}
    for template_id, template in QUICK_START_TEMPLATES.items():
        cat = template['category']
        if cat not in categories:
            categories[cat] = []
        categories[cat].append({
            'id': template['id'],
            'name': template['name'],
            'description': template['description'],
            'icon': template.get('icon', 'network'),
            'complexity': template.get('complexity', 1),
            'node_count': len(template['nodes']),
            'link_count': len(template['links']),
        })

    return jsonify({
        'categories': categories,
        'templates': list(QUICK_START_TEMPLATES.values())
    })


@app.route('/api/templates/<template_id>', methods=['GET'])
def get_template(template_id):
    """Get a specific template by ID"""
    if template_id not in QUICK_START_TEMPLATES:
        return jsonify({'error': 'Template not found'}), 404

    return jsonify({
        'success': True,
        'template': QUICK_START_TEMPLATES[template_id]
    })


@app.route('/api/templates/<template_id>/deploy', methods=['POST'])
def deploy_template(template_id):
    """Quick deploy a template directly to CORE"""
    global current_generator, last_deployed_template

    if template_id not in QUICK_START_TEMPLATES:
        return jsonify({'error': 'Template not found'}), 404

    template = QUICK_START_TEMPLATES[template_id]

    # Store a DEEP COPY of the template for later reference (network info, etc.)
    # This prevents modifications from affecting the original template definition
    last_deployed_template = copy.deepcopy(template)

    try:
        # Create new generator
        current_generator = TopologyGenerator()

        # Add nodes using NodeConfig
        node_map = {}  # name -> node_id
        next_id = 1

        for node_spec in template['nodes']:
            node_type = node_spec['type']
            name = node_spec['name']
            x = float(node_spec.get('x', 100))
            y = float(node_spec.get('y', 100))

            # Create NodeConfig
            node_config = NodeConfig(
                node_id=next_id,
                name=name,
                node_type=node_type,
                x=x,
                y=y,
                services=node_spec.get('services', []).copy() if 'services' in node_spec else [],
                image=node_spec.get('image') if node_type == 'docker' else None
            )

            current_generator.add_node(node_config)
            node_map[name] = next_id
            next_id += 1

        # Add links using LinkConfig
        for link in template['links']:
            # Handle both old format ['node1', 'node2'] and new format {'from': 'node1', 'to': 'node2', 'ip1': '...', 'ip2': '...'}
            if isinstance(link, dict):
                node1_name = link['from']
                node2_name = link['to']
                ip1 = link.get('ip1')
                ip2 = link.get('ip2')
            else:
                node1_name, node2_name = link[0], link[1]
                ip1 = None
                ip2 = None

            if node1_name in node_map and node2_name in node_map:
                link_config = LinkConfig(
                    node1_id=node_map[node1_name],
                    node2_id=node_map[node2_name],
                    ip4_1=ip1,
                    ip4_2=ip2
                )
                current_generator.add_link(link_config)

        # Generate XML
        xml_content = current_generator.to_xml()

        # Save and copy to CORE
        import subprocess
        filename = f"{template_id}.xml"
        local_path = f"/tmp/{filename}"
        container_path = f"/root/topologies/{filename}"

        with open(local_path, 'w') as f:
            f.write(xml_content)

        # Copy to container
        subprocess.run(f"docker cp {local_path} core-novnc:{container_path}",
                      shell=True, capture_output=True)

        # Copy load script
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
            shell=True, capture_output=True
        )

        # Clean up any existing Docker containers with the same names
        # This prevents "container name already in use" errors
        docker_node_names = [
            node_spec['name'] for node_spec in template['nodes']
            if node_spec['type'] == 'docker'
        ]
        cleanup_info = {'removed': [], 'errors': []}
        if docker_node_names:
            cleanup_info = cleanup_docker_containers(docker_node_names)
            if cleanup_info['removed']:
                print(f"Pre-deploy cleanup: removed {len(cleanup_info['removed'])} existing containers: {cleanup_info['removed']}")

        # Load in CORE with auto-start
        load_cmd = f"""docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/load_topology.py --start {container_path}
        '"""
        result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True, timeout=30)

        return jsonify({
            'success': True,
            'template_id': template_id,
            'template_name': template['name'],
            'nodes': len(template['nodes']),
            'links': len(template['links']),
            'message': f"Template '{template['name']}' deployed to CORE",
            'output': result.stdout,
            'cleanup': cleanup_info
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/clear', methods=['POST'])
def clear_topology():
    """Clear current topology"""
    global current_generator
    current_generator = TopologyGenerator()
    return jsonify({'success': True})


@app.route('/api/docker/cleanup', methods=['POST'])
def cleanup_docker_api():
    """
    Manually cleanup Docker containers in core-novnc.

    POST body options:
    - {"names": ["container1", "container2"]} - Remove specific containers
    - {"all_stopped": true} - Remove all stopped/exited containers (except protected ones)
    """
    import subprocess

    data = request.get_json() or {}

    if data.get('all_stopped'):
        # Get all stopped containers inside core-novnc
        cmd = "docker exec core-novnc docker ps -a --filter 'status=exited' --format '{{.Names}}'"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=15)
        names = [n.strip() for n in result.stdout.strip().split('\n') if n.strip()]
    elif 'names' in data:
        names = data['names']
    else:
        return jsonify({
            'error': 'Must provide either "names" array or "all_stopped": true',
            'example': {'names': ['hmi1', 'mqtt-broker']}
        }), 400

    if not names:
        return jsonify({
            'success': True,
            'message': 'No containers to clean up',
            'removed': [],
            'errors': []
        })

    cleanup_result = cleanup_docker_containers(names)

    return jsonify({
        'success': True,
        'removed': cleanup_result['removed'],
        'errors': cleanup_result['errors'],
        'skipped': cleanup_result.get('skipped', [])
    })


@app.route('/api/docker/containers', methods=['GET'])
def list_docker_containers():
    """List all Docker containers inside core-novnc"""
    import subprocess

    try:
        cmd = "docker exec core-novnc docker ps -a --format '{{.Names}}\\t{{.Image}}\\t{{.Status}}'"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=15)

        containers = []
        for line in result.stdout.strip().split('\n'):
            if line.strip():
                parts = line.split('\t')
                if len(parts) >= 3:
                    containers.append({
                        'name': parts[0],
                        'image': parts[1],
                        'status': parts[2]
                    })

        return jsonify({
            'success': True,
            'containers': containers,
            'count': len(containers)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =============================================================================
# TOPOLOGY INTROSPECTION & HOST ADDITION APIs
# =============================================================================

@app.route('/api/topology/networks', methods=['GET'])
def get_topology_networks():
    """Get available networks/switches in the current topology for adding hosts"""
    global last_deployed_template

    networks = []

    # First, try to get from the current generator
    if current_generator and current_generator.nodes:
        for node_id, node in current_generator.nodes.items():
            if node.node_type in ['switch', 'hub', 'wireless']:
                network_info = {
                    'id': node_id,
                    'name': node.name,
                    'type': node.node_type,
                    'subnet': None,
                    'gateway': None,
                    'next_ip': None
                }

                # Try to get subnet info from last deployed template
                if last_deployed_template and 'networks' in last_deployed_template:
                    net_config = last_deployed_template['networks'].get(node.name, {})
                    network_info['subnet'] = net_config.get('subnet')
                    network_info['gateway'] = net_config.get('gateway')
                    network_info['display_name'] = net_config.get('name', node.name)

                    # Calculate next available IP
                    if network_info['subnet']:
                        network_info['next_ip'] = _get_next_available_ip(
                            network_info['subnet'],
                            last_deployed_template
                        )

                networks.append(network_info)

    return jsonify({
        'success': True,
        'networks': networks,
        'has_topology': len(networks) > 0
    })


def _get_next_available_ip(subnet, template):
    """Calculate the next available IP in a subnet based on used IPs in template"""
    import ipaddress

    try:
        net = ipaddress.ip_network(subnet, strict=False)
        used_ips = set()

        # Collect all used IPs from nodes
        for node in template.get('nodes', []):
            if 'ip' in node:
                used_ips.add(node['ip'])

        # Collect from links
        for link in template.get('links', []):
            if isinstance(link, dict):
                if link.get('ip1'):
                    used_ips.add(link['ip1'])
                if link.get('ip2'):
                    used_ips.add(link['ip2'])

        # Find next available, starting from .50 (leave room for infrastructure)
        base_ip = int(net.network_address)
        for i in range(50, 250):  # .50 to .249
            candidate = str(ipaddress.ip_address(base_ip + i))
            if candidate not in used_ips:
                return candidate

        return None
    except Exception:
        return None


@app.route('/api/topology/hosts', methods=['GET'])
def get_topology_hosts():
    """Get list of hosts in current topology"""
    hosts = []

    if current_generator and current_generator.nodes:
        for node_id, node in current_generator.nodes.items():
            if node.node_type not in ['switch', 'hub', 'wireless', 'router']:
                hosts.append({
                    'id': node_id,
                    'name': node.name,
                    'type': node.node_type,
                    'image': node.image,
                    'services': node.services,
                    'x': node.x,
                    'y': node.y
                })

    return jsonify({
        'success': True,
        'hosts': hosts
    })


# Available Docker images for Add Host wizard
AVAILABLE_DOCKER_IMAGES = [
    {
        'category': 'Workstations',
        'images': [
            {'id': 'hmi-workstation:latest', 'name': 'HMI Workstation', 'description': 'Linux desktop with noVNC (port 6080)', 'ports': ['6080']},
            {'id': 'kali-novnc-core', 'name': 'Kali Linux', 'description': 'Kali with noVNC desktop (port 6080)', 'ports': ['6080']},
            {'id': 'engineering-workstation:latest', 'name': 'Engineering Workstation', 'description': 'Engineering tools with noVNC', 'ports': ['6080']},
        ]
    },
    {
        'category': 'Industrial/OT',
        'images': [
            {'id': 'openplc-core', 'name': 'OpenPLC Runtime', 'description': 'PLC runtime with Modbus (ports 8080, 502)', 'ports': ['8080', '502']},
        ]
    },
    {
        'category': 'Security',
        'images': [
            {'id': 'caldera-mcp-core', 'name': 'MITRE Caldera', 'description': 'C2 framework (port 8888)', 'ports': ['8888']},
        ]
    },
    {
        'category': 'Web/Services',
        'images': [
            {'id': 'nginx:alpine', 'name': 'Nginx Web Server', 'description': 'Lightweight web server (port 80)', 'ports': ['80']},
            {'id': 'ubuntu:22.04', 'name': 'Ubuntu 22.04', 'description': 'Base Ubuntu image', 'ports': []},
            {'id': 'alpine:latest', 'name': 'Alpine Linux', 'description': 'Minimal Linux image', 'ports': []},
        ]
    },
]


@app.route('/api/topology/docker-images', methods=['GET'])
def get_docker_images():
    """Get available Docker images for adding hosts"""
    return jsonify({
        'success': True,
        'categories': AVAILABLE_DOCKER_IMAGES
    })


@app.route('/api/topology/add-host', methods=['POST'])
def add_host_to_topology():
    """Add a new host to the current topology and reload in CORE"""
    global current_generator, last_deployed_template

    data = request.get_json()
    name = data.get('name')
    host_type = data.get('type', 'host')  # host, docker
    network_id = data.get('network_id')  # Switch/network to connect to
    ip_address = data.get('ip')
    docker_image = data.get('docker_image')
    x = float(data.get('x', 400))
    y = float(data.get('y', 400))

    if not name:
        return jsonify({'success': False, 'error': 'Host name is required'}), 400

    if not network_id:
        return jsonify({'success': False, 'error': 'Network to connect to is required'}), 400

    try:
        # Get next available node ID
        next_id = max(current_generator.nodes.keys()) + 1 if current_generator.nodes else 1

        # Create the node
        node_config = NodeConfig(
            node_id=next_id,
            name=name,
            node_type=host_type,
            x=x,
            y=y,
            image=docker_image if host_type == 'docker' else None,
            services=[]
        )

        current_generator.add_node(node_config)

        # Create link to the network
        link_config = LinkConfig(
            node1_id=int(network_id),
            node2_id=next_id,
            ip4_2=ip_address  # IP for the new host
        )
        current_generator.add_link(link_config)

        # Update the last_deployed_template with the new node
        if last_deployed_template:
            last_deployed_template['nodes'].append({
                'name': name,
                'type': host_type,
                'ip': ip_address,
                'x': x,
                'y': y,
                'image': docker_image
            })

            # Find network name for the link
            network_name = None
            for nid, node in current_generator.nodes.items():
                if nid == int(network_id):
                    network_name = node.name
                    break

            if network_name:
                last_deployed_template['links'].append({
                    'from': network_name,
                    'to': name,
                    'ip2': ip_address
                })

        # Regenerate XML and redeploy
        xml_content = current_generator.to_xml()

        import subprocess
        filename = "topology_with_new_host.xml"
        local_path = f"/tmp/{filename}"
        container_path = f"/root/topologies/{filename}"

        with open(local_path, 'w') as f:
            f.write(xml_content)

        # Copy to container
        subprocess.run(f"docker cp {local_path} core-novnc:{container_path}",
                      shell=True, capture_output=True)

        # Copy load script
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
            shell=True, capture_output=True
        )

        # Load in CORE with auto-start
        load_cmd = f"""docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/load_topology.py --start {container_path}
        '"""
        result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True, timeout=30)

        return jsonify({
            'success': True,
            'host': {
                'id': next_id,
                'name': name,
                'type': host_type,
                'ip': ip_address,
                'network_id': network_id
            },
            'message': f"Host '{name}' added to topology",
            'output': result.stdout
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/topology/ai-add', methods=['POST'])
def ai_add_to_topology():
    """Use AI to interpret natural language and add hosts/networks to topology"""
    global current_generator, last_deployed_template
    import re

    data = request.get_json()
    prompt = data.get('prompt', '')
    current_networks = data.get('current_networks', [])
    current_xml = data.get('current_xml', None)  # Current topology XML for AI context
    context_info = data.get('context', '')  # Additional context about NRL CORE

    # Log context for debugging (XML context is now available for AI model integration)
    if current_xml:
        app.logger.debug(f"AI Builder: Received request with XML context ({len(current_xml)} chars)")
    app.logger.debug(f"AI Builder: Prompt: {prompt}, Context: {context_info}")

    if not prompt:
        return jsonify({'success': False, 'error': 'Prompt is required'}), 400

    if not current_generator or not current_generator.nodes:
        return jsonify({'success': False, 'error': 'No topology deployed. Deploy a template first.'}), 400

    prompt_lower = prompt.lower()

    # Parse number of hosts to add
    num_hosts = 1
    number_patterns = [
        # Direct patterns like "10 hosts", "5 workstations"
        (r'(\d+)\s*hosts?', 1),
        (r'(\d+)\s*workstations?', 1),
        (r'(\d+)\s*machines?', 1),
        (r'(\d+)\s*computers?', 1),
        (r'(\d+)\s*nodes?', 1),
        (r'(\d+)\s*plcs?', 1),
        # Patterns with words between: "5 kali linux workstations", "10 ubuntu hosts"
        (r'(\d+)\s+\w+(?:\s+\w+)*\s+hosts?', 1),
        (r'(\d+)\s+\w+(?:\s+\w+)*\s+workstations?', 1),
        (r'(\d+)\s+\w+(?:\s+\w+)*\s+machines?', 1),
        (r'(\d+)\s+\w+(?:\s+\w+)*\s+computers?', 1),
        (r'(\d+)\s+\w+(?:\s+\w+)*\s+plcs?', 1),
        # "add N" or "add N <type>"
        (r'add\s+(\d+)', 1),
    ]
    for pattern, group in number_patterns:
        match = re.search(pattern, prompt_lower)
        if match:
            num_hosts = int(match.group(group))
            break

    # Check if we need to create a new network/router
    needs_new_network = any(word in prompt_lower for word in ['new subnet', 'new network', 'new router', 'add router', 'add a router', 'separate network'])

    # Parse subnet if specified
    new_subnet = None
    subnet_match = re.search(r'(\d{1,3}\.\d{1,3}\.\d{1,3})\.\d{1,3}/(\d{1,2})', prompt)
    if subnet_match:
        new_subnet = f"{subnet_match.group(1)}.0/{subnet_match.group(2)}"
    elif needs_new_network:
        # Auto-generate a new subnet
        existing_subnets = set()
        if last_deployed_template and 'networks' in last_deployed_template:
            for net_config in last_deployed_template['networks'].values():
                if net_config.get('subnet'):
                    existing_subnets.add(net_config['subnet'].split('.')[2])

        # Find next available third octet
        for octet in range(1, 255):
            if str(octet) not in existing_subnets:
                new_subnet = f"192.168.{octet}.0/24"
                break

    # Map common terms to Docker images
    image_mapping = {
        'kali': 'kali-novnc-core',
        'penetration': 'kali-novnc-core',
        'pentest': 'kali-novnc-core',
        'attacker': 'kali-novnc-core',
        'hmi': 'hmi-workstation:latest',
        'workstation': 'hmi-workstation:latest',
        'desktop': 'hmi-workstation:latest',
        'engineering': 'engineering-workstation:latest',
        'plc': 'openplc-core',
        'controller': 'openplc-core',
        'openplc': 'openplc-core',
        'caldera': 'caldera-mcp-core',
        'c2': 'caldera-mcp-core',
        'web': 'nginx:alpine',
        'nginx': 'nginx:alpine',
        'server': 'ubuntu:22.04',
        'ubuntu': 'ubuntu:22.04',
    }

    # Detect host type
    detected_image = None
    host_type_name = 'host'

    for keyword, image in image_mapping.items():
        if keyword in prompt_lower:
            detected_image = image
            host_type_name = keyword
            break

    if not detected_image:
        detected_image = 'ubuntu:22.04'
        host_type_name = 'host'

    added_items = []
    try:
        next_id = max(current_generator.nodes.keys()) + 1 if current_generator.nodes else 1
        max_y = max((n.y for n in current_generator.nodes.values()), default=100)

        # If we need a new network, create router and switch first
        target_network_id = None
        new_network_name = None

        if needs_new_network and new_subnet:
            # Create router
            router_name = f"router-{next_id}"
            router_config = NodeConfig(
                node_id=next_id,
                name=router_name,
                node_type='router',
                x=300,
                y=max_y + 100,
                services=['IPForward']
            )
            current_generator.add_node(router_config)
            router_id = next_id
            added_items.append(f"Router '{router_name}'")
            next_id += 1

            # Connect router to existing network (find a switch to connect to)
            existing_switch_id = None
            for node_id, node in current_generator.nodes.items():
                if node.node_type == 'switch' and node_id != next_id:
                    existing_switch_id = node_id
                    break

            if existing_switch_id:
                # Link router to existing switch
                link_config = LinkConfig(
                    node1_id=existing_switch_id,
                    node2_id=router_id,
                    ip4_2=new_subnet.replace('.0/', '.1/')[:new_subnet.rfind('.')] + '.1'
                )
                current_generator.add_link(link_config)

            # Create new switch for the new network
            switch_name = f"switch-{next_id}"
            switch_config = NodeConfig(
                node_id=next_id,
                name=switch_name,
                node_type='switch',
                x=500,
                y=max_y + 100
            )
            current_generator.add_node(switch_config)
            target_network_id = next_id
            new_network_name = switch_name
            added_items.append(f"Switch '{switch_name}' ({new_subnet})")
            next_id += 1

            # Link router to new switch
            subnet_base = new_subnet.split('/')[0].rsplit('.', 1)[0]
            link_config = LinkConfig(
                node1_id=router_id,
                node2_id=target_network_id,
                ip4_1=f"{subnet_base}.1"
            )
            current_generator.add_link(link_config)

            # Update template tracking
            if last_deployed_template:
                if 'networks' not in last_deployed_template:
                    last_deployed_template['networks'] = {}
                last_deployed_template['networks'][switch_name] = {
                    'subnet': new_subnet,
                    'gateway': f"{subnet_base}.1",
                    'name': switch_name
                }

            max_y += 100

        else:
            # Use existing network
            for net in current_networks:
                target_network_id = net['id']
                break

            if not target_network_id:
                for node_id, node in current_generator.nodes.items():
                    if node.node_type in ['switch', 'hub']:
                        target_network_id = node_id
                        break

        if not target_network_id:
            return jsonify({'success': False, 'error': 'No network found to connect hosts to'}), 400

        # Determine base IP for hosts
        if new_subnet:
            subnet_base = new_subnet.split('/')[0].rsplit('.', 1)[0]
            start_ip = 10
        else:
            # Get from existing network
            subnet_base = '10.10.0'
            start_ip = 50
            if current_networks and current_networks[0].get('subnet'):
                subnet_base = current_networks[0]['subnet'].split('/')[0].rsplit('.', 1)[0]
            if current_networks and current_networks[0].get('next_ip'):
                start_ip = int(current_networks[0]['next_ip'].split('.')[-1])

        # Add the hosts
        for i in range(num_hosts):
            host_name = f"{host_type_name}-{next_id}"
            host_ip = f"{subnet_base}.{start_ip + i}"

            # Calculate position in a grid
            row = i // 5
            col = i % 5
            x_pos = 400 + (col * 100)
            y_pos = max_y + 150 + (row * 80)

            node_config = NodeConfig(
                node_id=next_id,
                name=host_name,
                node_type='docker' if detected_image else 'host',
                x=x_pos,
                y=y_pos,
                image=detected_image,
                services=[]
            )
            current_generator.add_node(node_config)

            link_config = LinkConfig(
                node1_id=target_network_id,
                node2_id=next_id,
                ip4_2=host_ip
            )
            current_generator.add_link(link_config)

            added_items.append(f"'{host_name}' ({host_ip})")

            # Update template tracking
            if last_deployed_template:
                last_deployed_template['nodes'].append({
                    'name': host_name,
                    'type': 'docker',
                    'ip': host_ip,
                    'image': detected_image
                })

            next_id += 1

        # Regenerate and deploy
        xml_content = current_generator.to_xml()

        import subprocess
        filename = "topology_ai_updated.xml"
        local_path = f"/tmp/{filename}"
        container_path = f"/root/topologies/{filename}"

        with open(local_path, 'w') as f:
            f.write(xml_content)

        subprocess.run(f"docker cp {local_path} core-novnc:{container_path}",
                      shell=True, capture_output=True)
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
            shell=True, capture_output=True
        )
        load_cmd = f"""docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/load_topology.py --start {container_path}
        '"""
        subprocess.run(load_cmd, shell=True, capture_output=True, text=True, timeout=30)

        message = f"Added: {', '.join(added_items)}"
        return jsonify({
            'success': True,
            'message': message,
            'added_count': len(added_items),
            'items': added_items
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


def cleanup_core_interfaces():
    """Clean up leftover network interfaces and session files in CORE container"""
    import subprocess
    try:
        # Remove leftover session socket files
        subprocess.run(
            "docker exec core-novnc rm -rf /tmp/pycore.* 2>/dev/null || true",
            shell=True, capture_output=True, timeout=10
        )
        # Delete leftover veth/beth interfaces
        subprocess.run(
            "docker exec core-novnc bash -c \"ip link show | grep -oP '(beth|veth)[^:@]+' | xargs -r -I{} ip link delete {} 2>/dev/null || true\"",
            shell=True, capture_output=True, timeout=15
        )
        return True
    except Exception:
        return False

@app.route('/api/copy-to-core', methods=['POST'])
def copy_to_core():
    """Copy generated topology to CORE container and auto-open"""
    try:
        # Clean up leftover interfaces first to prevent "File exists" errors
        # Don't let cleanup failure stop the copy operation
        try:
            cleanup_core_interfaces()
        except Exception as cleanup_error:
            print(f"Warning: Cleanup failed but continuing: {cleanup_error}")

        data = request.get_json()
        filename = data.get('filename', 'web_generated.xml')
        auto_open = data.get('auto_open', True)
        auto_start = data.get('auto_start', False)  # New option for full automation

        # Ensure filename ends with .xml
        if not filename.endswith('.xml'):
            filename += '.xml'

        # Save XML locally
        xml_content = current_generator.to_xml()
        local_path = f"/tmp/{filename}"

        with open(local_path, 'w') as f:
            f.write(xml_content)

        # Copy to container
        import subprocess
        container_path = f"/root/topologies/{filename}"

        copy_cmd = f"docker cp {local_path} core-novnc:{container_path}"
        result = subprocess.run(copy_cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({
                'success': False,
                'error': f'Failed to copy to container: {result.stderr}'
            }), 500

        # Save startup scripts if any exist
        scripts_path = None
        has_startup_scripts = current_generator.has_startup_scripts()
        if has_startup_scripts:
            scripts_json = current_generator.get_startup_scripts_json()
            scripts_filename = filename.replace('.xml', '_startup.json')
            local_scripts_path = f"/tmp/{scripts_filename}"

            with open(local_scripts_path, 'w') as f:
                f.write(scripts_json)

            scripts_path = f"/root/topologies/{scripts_filename}"
            copy_scripts_cmd = f"docker cp {local_scripts_path} core-novnc:{scripts_path}"
            subprocess.run(copy_scripts_cmd, shell=True, capture_output=True, text=True)

            # Also copy the start_and_deploy script
            subprocess.run(
                "docker cp /workspaces/core/core-mcp-server/start_and_deploy.py core-novnc:/tmp/",
                shell=True,
                capture_output=True
            )

        # Auto-open in CORE GUI if requested
        session_id = None
        if auto_open:
            # Copy the load script to container if not exists
            subprocess.run(
                "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
                shell=True,
                capture_output=True
            )

            # Load topology using CORE Python API
            # Always use --start to auto-start the session (no need to press play button)
            load_cmd = f"""docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 /tmp/load_topology.py --start {container_path} > /tmp/load_topology.log 2>&1
            '"""
            result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True)

            # Check for errors
            log_check = subprocess.run(
                "docker exec core-novnc cat /tmp/load_topology.log",
                shell=True,
                capture_output=True,
                text=True
            )

            if "Session ID:" in log_check.stdout:
                # Extract session ID
                import re
                match = re.search(r'Session ID: (\d+)', log_check.stdout)
                if match:
                    session_id = int(match.group(1))

            # Check for actual errors (look for error indicators, not emojis)
            has_error = ("Error loading topology" in log_check.stdout or
                        "❌" in log_check.stdout or
                        "Traceback" in log_check.stdout or
                        (result.returncode != 0 and "✅" not in log_check.stdout))

            if has_error:
                return jsonify({
                    'success': False,
                    'error': f'Failed to load in CORE GUI: {log_check.stdout}'
                }), 500

        # Auto-start and deploy if requested
        if auto_start and session_id and has_startup_scripts:
            deploy_cmd = f"""docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 /tmp/start_and_deploy.py {session_id} {scripts_path} > /tmp/deploy.log 2>&1 &
            '"""
            subprocess.run(deploy_cmd, shell=True, capture_output=True, text=True)

        # Auto-start MQTT injector if topology contains an mqtt-broker node
        injector_started = False
        if session_id and current_generator:
            # Build template dict from current generator for injector detection
            template = {
                'nodes': [
                    {'name': node.name, 'image': node.image or '', 'ip': node.ip_address}
                    for node in current_generator.nodes.values()
                ],
                'links': []
            }
            injector_started = auto_start_injector_for_topology(template, session_id)

        return jsonify({
            'success': True,
            'message': f'Copied to {container_path}',
            'container_path': container_path,
            'scripts_path': scripts_path,
            'session_id': session_id,
            'auto_opened': auto_open,
            'auto_started': auto_start and session_id is not None,
            'has_startup_scripts': has_startup_scripts,
            'injector_started': injector_started
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/start-and-deploy', methods=['POST'])
def start_and_deploy():
    """Start the CORE session and deploy startup scripts automatically."""
    try:
        import subprocess

        data = request.get_json()
        session_id = data.get('session_id')

        if not session_id:
            # Try to get the latest session
            get_session_cmd = """docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 -c "
from core.api.grpc import client
core = client.CoreGrpcClient()
core.connect()
sessions = core.get_sessions()
if sessions:
    print(sessions[-1].id)
"
            '"""
            result = subprocess.run(get_session_cmd, shell=True, capture_output=True, text=True)
            if result.stdout.strip().isdigit():
                session_id = int(result.stdout.strip())
            else:
                return jsonify({
                    'success': False,
                    'error': 'No session found. Load a topology first.'
                }), 400

        # Check if we have startup scripts saved
        scripts_path = data.get('scripts_path')
        if not scripts_path and current_generator.has_startup_scripts():
            # Save scripts temporarily
            scripts_json = current_generator.get_startup_scripts_json()
            local_scripts_path = f"/tmp/startup_scripts_{session_id}.json"

            with open(local_scripts_path, 'w') as f:
                f.write(scripts_json)

            scripts_path = f"/tmp/startup_scripts_{session_id}.json"
            subprocess.run(
                f"docker cp {local_scripts_path} core-novnc:{scripts_path}",
                shell=True,
                capture_output=True
            )

        # Copy the deploy script
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/start_and_deploy.py core-novnc:/tmp/",
            shell=True,
            capture_output=True
        )

        # Run the deployment
        scripts_arg = scripts_path if scripts_path else ""
        deploy_cmd = f"""docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/start_and_deploy.py {session_id} {scripts_arg}
        '"""
        result = subprocess.run(deploy_cmd, shell=True, capture_output=True, text=True, timeout=120)

        return jsonify({
            'success': True,
            'session_id': session_id,
            'output': result.stdout + result.stderr
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Deployment timed out. Check CORE GUI for status.'
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/interpret-text', methods=['POST'])
def interpret_text():
    """Interpret text description and return structured plan"""
    try:
        data = request.get_json()
        description = data.get('description', '')

        if not description:
            return jsonify({'error': 'Description is required'}), 400

        # Use GPT-4o (latest) to interpret the description
        response = openai.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": """You are a network engineer planning a CORE network emulation topology. Think like an engineer configuring a realistic network simulation.

CORE CAPABILITIES YOU CAN USE:
- Node types: routers (Quagga/FRR), switches, hosts, Docker containers
- Services: HTTP, SSH, FTP, DNS, DHCP servers on hosts
- Security: Firewall service (iptables), NAT service
- Firewalls: Built-in iptables OR Docker containers (pfSense, OPNsense, Palo Alto if available)
- Routing protocols: OSPF, BGP, RIP, static routes
- Network segments: VLANs, subnets, isolated networks, DMZ zones
- Docker containers: custom applications, web servers, databases, advanced firewalls
- Host placement: DMZ, internal network, management network

YOUR TASK:
Interpret the user's description and ask CONFIGURATION questions about:
- What services should run on hosts? (web server, SSH access, FTP?)
- Firewall needs? (iptables firewall, NAT, or Docker-based like pfSense?)
- What routing protocol? (OSPF for dynamic, static for simple?)
- Should hosts use Docker containers? (for specific apps or advanced firewalls?)
- Network segmentation? (DMZ, internal, management zones?)
- Security zones? (public-facing vs internal hosts?)

Return a JSON object with:
{
  "interpretation": "What I understood from your description",
  "nodes": {
    "routers": <count>,
    "switches": <count>,
    "hosts": <count>
  },
  "structure": "Topology type and design",
  "questions": ["Service questions", "Routing questions", "Placement questions"],
  "suggestions": [
    {"id": "ospf", "label": "Enable OSPF routing on routers", "description": "Dynamic routing protocol"},
    {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"},
    {"id": "ssh", "label": "Enable SSH access on all nodes", "description": "Remote management"}
  ]
}

SUGGESTIONS FORMAT:
- Each suggestion must be a JSON object with: id (unique), label (what to enable), description (brief)
- Make suggestions ACTIONABLE - things that can be toggled on/off
- Examples: "Enable OSPF routing", "Add HTTP servers", "Use Docker containers", "Create DMZ zone"

EXAMPLE GOOD QUESTIONS:
- "Should the hosts run HTTP servers for web services?"
- "Do you need firewalls? (iptables on routers or Docker-based like pfSense?)"
- "Which routing protocol: OSPF for dynamic routing or static routes?"
- "Should any hosts be Docker containers with custom services?"
- "Do you want a DMZ segment for public-facing servers?"
- "Should routers run SSH for management access?"
- "Enable NAT service for internet access?"

EXAMPLE ACTIONABLE SUGGESTIONS:
- {"id": "firewall_iptables", "label": "Enable iptables firewall on edge routers", "description": "Basic packet filtering"}
- {"id": "firewall_docker", "label": "Use pfSense Docker container as firewall", "description": "Advanced firewall features"}
- {"id": "ospf", "label": "Enable OSPF routing on routers", "description": "Dynamic routing protocol"}
- {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"}
- {"id": "dhcp", "label": "Add DHCP server on first host", "description": "Automatic IP configuration"}
- {"id": "ssh", "label": "Enable SSH access on all nodes", "description": "Remote management"}

DON'T ASK about physical hardware (ports, cables, racks)."""},
                {"role": "user", "content": description}
            ],
            temperature=0.7,
            max_tokens=1000
        )

        content = response.choices[0].message.content.strip()

        # Extract JSON from response
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        elif "```" in content:
            content = content.split("```")[1].split("```")[0].strip()

        interpretation = json.loads(content)

        # Store for later use
        global current_interpretation
        current_interpretation = interpretation

        return jsonify({
            'success': True,
            'interpretation': interpretation
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/interpret-image', methods=['POST'])
def interpret_image():
    """Interpret uploaded network diagram image"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400

        image_file = request.files['image']

        # Read and encode image
        image_data = base64.b64encode(image_file.read()).decode('utf-8')

        # Use GPT-4o (with vision) to analyze the image
        response = openai.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": """You are a network engineer analyzing a diagram for CORE network emulation. Think about practical configuration.

CORE CAPABILITIES:
- Node types: routers (Quagga/FRR), switches, hosts, Docker containers
- Services: HTTP, SSH, FTP, DNS, DHCP servers
- Security: Firewall (iptables), NAT, Docker firewalls (pfSense, OPNsense, Palo Alto)
- Routing: OSPF, BGP, RIP, static routes
- Network zones: DMZ, internal, management

ANALYZE THE DIAGRAM:
1. Identify nodes and their roles
2. Understand connectivity
3. Ask CONFIGURATION questions:
   - What services on hosts? (HTTP servers, SSH?)
   - Which routing protocol for routers?
   - Should certain nodes be Docker containers?
   - Network segmentation needed? (DMZ zones?)
   - Where should specific services be located?

Return a JSON object with:
{
  "interpretation": "What I see in this network diagram",
  "nodes": {
    "routers": <count>,
    "switches": <count>,
    "hosts": <count>
  },
  "structure": "Topology type and design",
  "questions": ["Service configuration?", "Routing protocol?", "Host placement?"],
  "suggestions": [
    {"id": "ospf", "label": "Enable OSPF routing", "description": "Dynamic routing"},
    {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"}
  ]
}

SUGGESTIONS FORMAT:
- Each suggestion must be JSON object: {"id": "unique_id", "label": "What to enable", "description": "Brief"}
- Make ACTIONABLE: things user can check a box to add

GOOD QUESTIONS EXAMPLES:
- "Should edge hosts run web servers (HTTP)?"
- "Do you need a firewall? (iptables or Docker-based like pfSense?)"
- "OSPF or static routing between routers?"
- "Do you need Docker containers for specific applications?"
- "Should some hosts be in a DMZ for public access?"

ACTIONABLE SUGGESTIONS EXAMPLES:
- {"id": "firewall", "label": "Enable iptables firewall on gateway", "description": "Packet filtering"}
- {"id": "ospf", "label": "Enable OSPF routing", "description": "Dynamic routing"}

DON'T ask about physical hardware."""
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_data}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=1000
        )

        content = response.choices[0].message.content.strip()

        # Extract JSON
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        elif "```" in content:
            content = content.split("```")[1].split("```")[0].strip()

        interpretation = json.loads(content)

        # Store for later use
        global current_interpretation
        current_interpretation = interpretation

        return jsonify({
            'success': True,
            'interpretation': interpretation
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/generate-from-plan', methods=['POST'])
def generate_from_plan():
    """Generate topology from refined interpretation plan"""
    try:
        data = request.get_json()
        plan = data.get('plan', current_interpretation)

        if not plan:
            return jsonify({'error': 'No plan provided'}), 400

        # Build description from plan for existing generator
        nodes = plan.get('nodes', {})
        structure = plan.get('structure', '')

        # Construct description
        parts = []
        if 'ring' in structure.lower() and nodes.get('routers', 0) > 0:
            parts.append(f"ring with {nodes['routers']} routers")
        elif 'star' in structure.lower():
            if nodes.get('switches', 0) > 0:
                parts.append(f"star with a switch and {nodes.get('hosts', 0)} hosts")
            else:
                parts.append(f"star with {nodes.get('hosts', 0)} nodes")
        elif 'mesh' in structure.lower():
            parts.append(f"mesh with {nodes.get('routers', 0)} routers")

        description = "Create a " + " ".join(parts) if parts else plan.get('interpretation', '')

        # Generate using existing logic
        global current_generator
        current_generator = TopologyGenerator()
        result = current_generator.generate_from_description(description)

        # Apply selected features
        selected_features = plan.get('selected_features', [])
        caldera_config = plan.get('caldera_config', {})
        pfsense_config = plan.get('pfsense_config', {})

        apply_features_to_topology(current_generator, selected_features, caldera_config)

        # Apply security appliances (pfSense at router level)
        apply_security_appliances(current_generator, pfsense_config)

        summary = current_generator.get_summary()

        return jsonify({
            'success': True,
            'result': result,
            'summary': summary,
            'nodes': len(current_generator.nodes),
            'links': len(current_generator.links)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


def apply_features_to_topology(generator, features, caldera_config=None):
    """Apply selected features to the generated topology"""
    for feature in features:
        feature_id = feature.get('id', '') if isinstance(feature, dict) else feature

        if feature_id == 'http':
            # Add HTTP service to all host nodes
            for node_id, node in generator.nodes.items():
                if node.node_type in ['host', 'pc']:
                    if 'HTTP' not in node.services:
                        node.services.append('HTTP')

        elif feature_id == 'dhcp':
            # Add DHCP service to first host
            for node_id, node in generator.nodes.items():
                if node.node_type in ['host', 'pc']:
                    if 'DHCP' not in node.services:
                        node.services.append('DHCP')
                    break  # Only first host

        elif feature_id == 'ssh':
            # Add SSH service to all nodes
            for node_id, node in generator.nodes.items():
                if 'SSH' not in node.services:
                    node.services.append('SSH')

        elif feature_id == 'ospf':
            # Add OSPFv2 service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'OSPFv2' not in node.services:
                        node.services.append('OSPFv2')

        elif feature_id == 'firewall_iptables':
            # Add Firewall service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'Firewall' not in node.services:
                        node.services.append('Firewall')

        elif feature_id == 'nat':
            # Add NAT service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'NAT' not in node.services:
                        node.services.append('NAT')

    # Handle Caldera Docker container (Adversary Simulation on Hosts)
    if caldera_config and caldera_config.get('enabled'):
        host_index = caldera_config.get('host_index', 0)

        # Find the specified host and convert it to Docker container
        host_count = 0
        for node_id, node in generator.nodes.items():
            if node.node_type in ['host', 'pc']:
                if host_count == host_index:
                    # Convert to Docker container with Caldera
                    # Use unique name with node ID to prevent Docker name conflicts
                    # Use caldera-mcp-core:latest - Latest Caldera with MCP plugin, CORE-compatible
                    node.node_type = 'docker'
                    node.name = f'caldera-n{node_id}'  # Unique name per node
                    node.image = 'caldera-mcp-core:latest'
                    node.services = ['DefaultRoute']
                    break
                host_count += 1

def apply_security_appliances(generator, pfsense_config=None):
    """
    Apply security appliances with proper topology architecture.

    Security Architecture Rules:
    - Firewalls (pfSense) should be at ROUTER positions (network boundaries)
    - Not at host positions - that defeats the purpose of perimeter security
    - pfSense acts as both router and firewall at the edge
    """

    # Handle pfSense Firewall (Router-level placement for proper security architecture)
    if pfsense_config and pfsense_config.get('enabled'):
        router_index = pfsense_config.get('router_index', 0)

        # Find the specified router and convert it to pfSense Docker container
        router_count = 0
        for node_id, node in generator.nodes.items():
            if node.node_type == 'router':
                if router_count == router_index:
                    # Convert router to pfSense firewall appliance
                    # This maintains the routing position while adding firewall capabilities
                    # Use unique name with node ID to prevent Docker name conflicts
                    node.node_type = 'docker'
                    node.name = f'pfsense-fw-n{node_id}'  # Unique name per node
                    node.image = 'pfsense/pfsense:latest'
                    node.services = ['DefaultRoute', 'IPForward']
                    break
                router_count += 1

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'CORE MCP Topology Generator'})


# =============================================================================
# VNC HOST DISCOVERY API
# =============================================================================

@app.route('/api/vnc-hosts', methods=['GET'])
def get_vnc_hosts():
    """
    Discover VNC-capable hosts from running CORE containers.
    Returns hosts with noVNC ports that can be accessed via the dashboard.
    """
    import subprocess
    import re

    hosts = []

    try:
        # Get list of running containers with their info
        result = subprocess.run(
            'docker ps --format "{{.Names}}|{{.Image}}|{{.Ports}}"',
            shell=True, capture_output=True, text=True, timeout=10
        )

        if result.returncode == 0:
            for line in result.stdout.strip().split('\n'):
                if not line:
                    continue

                parts = line.split('|')
                if len(parts) < 3:
                    continue

                name, image, ports = parts[0], parts[1], parts[2]

                # Skip core-novnc (that's the main CORE GUI)
                if name == 'core-novnc':
                    continue

                # Check if this container has VNC ports exposed
                # Look for port 6080 (noVNC) or 5900 (VNC)
                vnc_port = None
                novnc_port = None

                # Parse port mappings like "0.0.0.0:6081->6080/tcp"
                port_matches = re.findall(r'(\d+)->(\d+)/tcp', ports)
                for host_port, container_port in port_matches:
                    if container_port == '6080':
                        novnc_port = host_port
                    elif container_port == '5900':
                        vnc_port = host_port

                # If noVNC port found, add to hosts
                if novnc_port:
                    host_type = 'workstation'
                    if 'hmi' in name.lower():
                        host_type = 'hmi'
                    elif 'plc' in name.lower() or 'openplc' in image.lower():
                        host_type = 'plc'
                    elif 'scada' in name.lower():
                        host_type = 'scada'
                    elif 'engineering' in name.lower() or 'eng' in name.lower():
                        host_type = 'workstation'

                    hosts.append({
                        'name': name,
                        'image': image,
                        'port': novnc_port,
                        'vncPort': vnc_port,
                        'type': host_type,
                        'ip': '0.0.0.0'  # Will be localhost or codespaces URL
                    })

        # Also check for CORE session nodes that might have VNC
        # Query CORE for running nodes with hmi-workstation image
        try:
            core_result = subprocess.run(
                '''docker exec core-novnc bash -c "
                    cd /opt/core && ./venv/bin/python3 -c '
import json
from core.api.grpc import client
try:
    core = client.CoreGrpcClient()
    core.connect()
    sessions = core.get_sessions()
    nodes = []
    for session in sessions:
        if session.state == 2:  # RUNTIME state
            session_nodes = core.get_session(session.id).nodes
            for node in session_nodes:
                if hasattr(node, \"image\") and \"hmi\" in node.image.lower():
                    nodes.append({
                        \"name\": node.name,
                        \"image\": node.image,
                        \"session_id\": session.id
                    })
    print(json.dumps(nodes))
except:
    print(\"[]\")
'"
                ''',
                shell=True, capture_output=True, text=True, timeout=15
            )

            if core_result.returncode == 0 and core_result.stdout.strip():
                try:
                    core_nodes = json.loads(core_result.stdout.strip())
                    for node in core_nodes:
                        # These are CORE nodes, they need their VNC started
                        hosts.append({
                            'name': node['name'] + ' (CORE)',
                            'image': node['image'],
                            'port': None,  # No external port yet
                            'type': 'hmi',
                            'coreNode': True,
                            'sessionId': node['session_id'],
                            'needsVncStart': True
                        })
                except json.JSONDecodeError:
                    pass
        except Exception:
            pass

    except Exception as e:
        return jsonify({'error': str(e), 'hosts': []}), 500

    return jsonify({'hosts': hosts})


@app.route('/api/start-host-vnc', methods=['POST'])
def start_host_vnc():
    """
    Start VNC services on a CORE container node and set up proxy access.

    This uses a two-layer proxy chain that works reliably:
      websockify:608X -> socat:1608X -> nsenter -> container:6080

    The websockify layer is required because:
    1. It properly handles WebSocket protocol for noVNC
    2. It serves the noVNC web files
    3. Raw socat doesn't work through Codespaces port forwarding

    Works with any VNC-capable container: HMI, Kali, Engineering workstations, etc.
    """
    import subprocess
    import time
    import os

    try:
        data = request.get_json()
        node_name = data.get('node_name')
        node_ip = data.get('node_ip')
        proxy_port = data.get('proxy_port')  # If not provided, auto-assign

        if not node_name:
            return jsonify({'success': False, 'error': 'Node name required'}), 400

        # First, find the Docker container ID for this CORE node
        # CORE Docker nodes have names like "n1.1234" where 1234 is the session ID
        find_container = f'''docker exec core-novnc bash -c "docker ps --format '{{{{.Names}}}}' | grep -E '^{node_name}\\.' | head -1"'''
        result = subprocess.run(find_container, shell=True, capture_output=True, text=True, timeout=10)

        if result.returncode != 0 or not result.stdout.strip():
            # Try alternative - look for container with node name anywhere
            find_alt = f'''docker exec core-novnc bash -c "docker ps --format '{{{{.Names}}}}' | grep '{node_name}' | head -1"'''
            result = subprocess.run(find_alt, shell=True, capture_output=True, text=True, timeout=10)

        container_name = result.stdout.strip()

        if not container_name:
            return jsonify({
                'success': False,
                'error': f'Container for node {node_name} not found. Is the topology running?'
            }), 404

        # Start supervisord in the container to enable VNC services
        # Use pgrep -f to match python scripts like supervisord
        start_cmd = f'''docker exec core-novnc docker exec {container_name} bash -c '
            if pgrep -f supervisord > /dev/null 2>&1; then
                # Check if websockify is also running (full stack healthy)
                if pgrep -f websockify > /dev/null 2>&1; then
                    echo VNC_ALREADY_RUNNING
                else
                    # supervisord running but services died, restart
                    pkill -f supervisord 2>/dev/null || true
                    sleep 1
                    supervisord -c /etc/supervisor/conf.d/desktop.conf &
                    sleep 4
                    echo VNC_RESTARTED
                fi
            else
                supervisord -c /etc/supervisor/conf.d/desktop.conf &
                sleep 4
                echo VNC_STARTED
            fi
        ' '''

        result = subprocess.run(start_cmd, shell=True, capture_output=True, text=True, timeout=30)
        vnc_status = result.stdout.strip()

        # Verify VNC services are actually running
        verify_cmd = f'''docker exec core-novnc docker exec {container_name} bash -c '
            pgrep -f websockify > /dev/null && pgrep -f x11vnc > /dev/null && echo OK || echo FAILED
        ' '''
        verify_result = subprocess.run(verify_cmd, shell=True, capture_output=True, text=True, timeout=10)

        if 'OK' not in verify_result.stdout:
            return jsonify({
                'success': False,
                'error': f'VNC services failed to start in {container_name}. Check supervisord config.'
            }), 500

        # Get the node's IP if not provided
        if not node_ip:
            get_ip_cmd = f'''docker exec core-novnc docker exec {container_name} ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet )\\d+(\\.\\d+){{3}}' | head -1'''
            ip_result = subprocess.run(get_ip_cmd, shell=True, capture_output=True, text=True, timeout=10)
            node_ip = ip_result.stdout.strip()

        # Get the container's PID for nsenter
        get_pid_cmd = f'''docker exec core-novnc docker inspect {container_name} --format '{{{{.State.Pid}}}}' '''
        pid_result = subprocess.run(get_pid_cmd, shell=True, capture_output=True, text=True, timeout=10)
        container_pid = pid_result.stdout.strip()

        if not container_pid or container_pid == '0':
            return jsonify({
                'success': False,
                'error': f'Could not get PID for container {container_name}'
            }), 500

        # Clean up stale proxies pointing to dead PIDs
        cleanup_stale_cmd = '''docker exec core-novnc bash -c '
            for port in 6081 6082 6083; do
                script_file=/tmp/ns_forward_$port.sh
                if [ -f $script_file ]; then
                    old_pid=$(grep -oP "(?<=nsenter -n -t )\\d+" $script_file 2>/dev/null || echo "")
                    if [ -n "$old_pid" ]; then
                        if ! kill -0 $old_pid 2>/dev/null; then
                            # PID is dead, clean up this port
                            pkill -f "websockify.*$port" 2>/dev/null || true
                            pkill -f "socat.*1$port" 2>/dev/null || true
                            rm -f $script_file
                        fi
                    fi
                fi
            done
        ' '''
        subprocess.run(cleanup_stale_cmd, shell=True, capture_output=True, timeout=10)

        # Auto-assign proxy port if not provided (6081-6083 are exposed)
        if not proxy_port:
            for port in range(6081, 6084):
                check_port = f"docker exec core-novnc bash -c 'ss -tln | grep -q :{port}'"
                port_check = subprocess.run(check_port, shell=True, capture_output=True, timeout=5)
                if port_check.returncode != 0:  # Port not in use
                    proxy_port = port
                    break

        if not proxy_port:
            return jsonify({
                'success': False,
                'error': 'No available proxy ports (6081-6083 all in use). Call /api/vnc/cleanup first.'
            }), 500

        # Internal port for socat (e.g., 6081 -> 16081)
        internal_port = 10000 + proxy_port

        # Kill any existing proxies on these ports
        kill_existing = f'''docker exec core-novnc bash -c '
            pkill -f "websockify.*{proxy_port}" 2>/dev/null || true
            pkill -f "socat.*{internal_port}" 2>/dev/null || true
            rm -f /tmp/ns_forward_{proxy_port}.sh 2>/dev/null || true
            sleep 0.5
        ' '''
        subprocess.run(kill_existing, shell=True, capture_output=True, timeout=5)

        # Create the nsenter wrapper script
        # This bridges into the container's network namespace to reach x11vnc on port 5900
        # CRITICAL: Connect to x11vnc (port 5900), NOT websockify (port 6080)
        # Websockify expects WebSocket protocol, not raw TCP - using it causes handshake failures
        wrapper_script = f'/tmp/ns_forward_{proxy_port}.sh'
        create_wrapper = f'''docker exec core-novnc bash -c 'cat > {wrapper_script} << "WRAPPEREOF"
#!/bin/sh
exec nsenter -n -t {container_pid} socat STDIO TCP:localhost:5900
WRAPPEREOF
chmod +x {wrapper_script}' '''
        subprocess.run(create_wrapper, shell=True, capture_output=True, timeout=5)

        # Start socat on the internal port - this does the actual namespace bridging
        socat_cmd = f'''docker exec core-novnc bash -c 'nohup socat TCP-LISTEN:{internal_port},fork,reuseaddr EXEC:{wrapper_script} > /tmp/socat_{proxy_port}.log 2>&1 &' '''
        subprocess.run(socat_cmd, shell=True, capture_output=True, timeout=5)
        time.sleep(0.5)

        # Start websockify on the external port - this handles WebSocket protocol and serves noVNC files
        websockify_cmd = f'''docker exec core-novnc bash -c 'nohup python3 -m websockify --web /opt/noVNC {proxy_port} localhost:{internal_port} > /tmp/websockify_{proxy_port}.log 2>&1 &' '''
        subprocess.run(websockify_cmd, shell=True, capture_output=True, timeout=5)
        time.sleep(1)

        # Verify the proxy chain is running
        verify_proxy = f'''docker exec core-novnc bash -c '
            pgrep -f "websockify.*{proxy_port}" > /dev/null && pgrep -f "socat.*{internal_port}" > /dev/null && echo OK || echo FAILED
        ' '''
        verify_result = subprocess.run(verify_proxy, shell=True, capture_output=True, text=True, timeout=5)

        if 'OK' not in verify_result.stdout:
            # Check logs for errors
            log_cmd = f'''docker exec core-novnc bash -c 'cat /tmp/websockify_{proxy_port}.log /tmp/socat_{proxy_port}.log 2>/dev/null | tail -10' '''
            log_result = subprocess.run(log_cmd, shell=True, capture_output=True, text=True, timeout=5)
            return jsonify({
                'success': False,
                'error': f'Proxy chain failed to start. Logs: {log_result.stdout}'
            }), 500

        # Build the access URL - use the port 8080 reverse proxy
        # This proxies VNC through /hmi-vnc/<port>/ to avoid needing direct port access
        codespace_name = os.environ.get('CODESPACE_NAME', '')
        ws_path = f"hmi-vnc/{proxy_port}/websockify"
        if codespace_name:
            vnc_url = f"https://{codespace_name}-8080.app.github.dev/hmi-vnc/{proxy_port}/vnc_lite.html?scale=true&path={ws_path}"
        else:
            vnc_url = f"http://localhost:8080/hmi-vnc/{proxy_port}/vnc_lite.html?scale=true&path={ws_path}"

        return jsonify({
            'success': True,
            'message': f'VNC proxy chain started for {node_name}',
            'container': container_name,
            'node_ip': node_ip,
            'proxy_port': proxy_port,
            'internal_port': internal_port,
            'container_pid': container_pid,
            'vnc_url': vnc_url,
            'vnc_status': vnc_status
        })

    except subprocess.TimeoutExpired:
        return jsonify({'success': False, 'error': 'Operation timed out'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/vnc/cleanup', methods=['POST'])
def cleanup_vnc_proxies_api():
    """
    Clean up all VNC proxy chains inside core-novnc container.

    This cleans up both layers of the proxy chain:
    - websockify processes on external ports (608X)
    - socat processes on internal ports (1608X)
    - wrapper scripts for nsenter

    Call this before starting a new topology or when VNC connections fail.
    """
    import subprocess

    try:
        # Clean up the two-layer proxy chain:
        # Layer 1: websockify on external ports (6081-6083)
        # Layer 2: socat on internal ports (16081-16083)
        cleanup_cmd = '''docker exec core-novnc bash -c '
            # Count existing websockify proxies (HMI proxies on 608X ports)
            ws_count=$(pgrep -c -f "websockify.*608[1-9]" 2>/dev/null || echo 0)

            # Count existing socat proxies (internal ports 160XX)
            socat_count=$(pgrep -c -f "socat.*TCP-LISTEN:160" 2>/dev/null || echo 0)

            # Kill websockify HMI proxies (ports 6081-6089, but NOT 6080 which is main VNC)
            pkill -f "websockify.*608[1-9]" 2>/dev/null || true

            # Kill socat internal proxies (ports 160XX)
            pkill -f "socat.*TCP-LISTEN:160" 2>/dev/null || true

            # Also kill any old-style socat proxies on 608X directly
            pkill -f "socat.*TCP-LISTEN:608" 2>/dev/null || true

            # Count wrapper scripts
            scripts=$(ls /tmp/ns_forward_*.sh 2>/dev/null | wc -l || echo 0)

            # Remove ALL wrapper scripts
            rm -f /tmp/ns_forward_*.sh 2>/dev/null || true

            # Clean up log files
            rm -f /tmp/socat_*.log 2>/dev/null || true
            rm -f /tmp/websockify_*.log 2>/dev/null || true

            echo "websockify:$ws_count socat:$socat_count scripts:$scripts"
        ' '''

        result = subprocess.run(cleanup_cmd, shell=True, capture_output=True, text=True, timeout=10)
        output = result.stdout.strip()

        # Parse output (format: "websockify:N socat:N scripts:N")
        ws_killed = 0
        socat_killed = 0
        scripts = 0
        try:
            parts = output.split()
            for part in parts:
                if part.startswith('websockify:'):
                    ws_killed = int(part.split(':')[1])
                elif part.startswith('socat:'):
                    socat_killed = int(part.split(':')[1])
                elif part.startswith('scripts:'):
                    scripts = int(part.split(':')[1])
        except:
            pass

        return jsonify({
            'success': True,
            'message': 'VNC proxy chains cleaned up',
            'websockify_killed': ws_killed,
            'socat_killed': socat_killed,
            'scripts_removed': scripts,
            'total_proxies': ws_killed + socat_killed
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/vnc/setup-all', methods=['POST'])
def setup_all_vnc_proxies():
    """
    Automatically set up VNC proxies for all HMI/workstation nodes in running topology.

    This finds all VNC-capable containers and sets up the two-layer proxy chain for each:
    websockify:608X -> socat:1608X -> nsenter -> container:6080

    Call this after starting a CORE topology with HMI nodes.
    """
    import subprocess
    import time

    try:
        # First, clean up any stale proxies (both layers)
        cleanup_cmd = '''docker exec core-novnc bash -c '
            # Kill websockify HMI proxies (ports 6081-6089, NOT 6080)
            pkill -f "websockify.*608[1-9]" 2>/dev/null || true
            # Kill socat internal proxies (ports 160XX)
            pkill -f "socat.*TCP-LISTEN:160" 2>/dev/null || true
            # Kill old-style socat proxies
            pkill -f "socat.*TCP-LISTEN:608" 2>/dev/null || true
            # Remove wrapper scripts
            rm -f /tmp/ns_forward_*.sh 2>/dev/null || true
        ' '''
        subprocess.run(cleanup_cmd, shell=True, capture_output=True, timeout=10)
        time.sleep(1)

        # Get list of running containers inside core-novnc
        list_cmd = '''docker exec core-novnc docker ps --format '{{.Names}}\t{{.Image}}' '''
        result = subprocess.run(list_cmd, shell=True, capture_output=True, text=True, timeout=10)

        if result.returncode != 0:
            return jsonify({'success': False, 'error': 'Could not list containers'}), 500

        # Find VNC-capable containers
        vnc_patterns = ['hmi', 'workstation', 'desktop', 'kali', 'engineering']
        vnc_images = ['hmi-workstation', 'kali-novnc-core', 'engineering-workstation']
        hmi_containers = []

        for line in result.stdout.strip().split('\n'):
            if not line or '\t' not in line:
                continue
            parts = line.split('\t')
            container_name = parts[0]
            image_name = parts[1] if len(parts) > 1 else ''

            if container_name in ['core-novnc', 'core-daemon']:
                continue

            name_match = any(p in container_name.lower() for p in vnc_patterns)
            image_match = any(img in image_name.lower() for img in vnc_images)

            if name_match or image_match:
                hmi_containers.append(container_name)

        if not hmi_containers:
            return jsonify({
                'success': True,
                'message': 'No VNC-capable nodes found in topology',
                'nodes': [],
                'setup_results': []
            })

        # Set up VNC for each container
        setup_results = []
        for container in hmi_containers:
            try:
                # Call our own start-host-vnc endpoint
                import urllib.request
                import json as json_lib

                data = json_lib.dumps({"node_name": container}).encode('utf-8')
                req = urllib.request.Request(
                    'http://localhost:8080/api/start-host-vnc',
                    data=data,
                    headers={'Content-Type': 'application/json'},
                    method='POST'
                )

                with urllib.request.urlopen(req, timeout=15) as response:
                    vnc_result = json_lib.loads(response.read().decode())
                    setup_results.append({
                        'container': container,
                        'success': vnc_result.get('success', False),
                        'port': vnc_result.get('proxy_port'),
                        'url': vnc_result.get('vnc_url'),
                        'error': vnc_result.get('error')
                    })
            except Exception as e:
                setup_results.append({
                    'container': container,
                    'success': False,
                    'error': str(e)
                })

        successful = sum(1 for r in setup_results if r.get('success'))

        return jsonify({
            'success': True,
            'message': f'VNC setup complete: {successful}/{len(hmi_containers)} nodes',
            'nodes': hmi_containers,
            'setup_results': setup_results
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/core-vnc-nodes', methods=['GET'])
def get_core_vnc_nodes():
    """
    Get all VNC-capable nodes from the running CORE session.
    Returns nodes that have VNC images (hmi-workstation, kali-novnc-core, etc.)
    """
    import subprocess

    vnc_images = ['hmi-workstation', 'kali-novnc-core', 'engineering-workstation']
    nodes = []

    try:
        # Query CORE for running session nodes - use file-based script to avoid escaping
        script_content = '''
import json
from core.api.grpc import client
from core.api.grpc.wrappers import NodeType

try:
    core = client.CoreGrpcClient()
    core.connect()
    sessions = core.get_sessions()
    nodes = []

    for session_info in sessions:
        # SessionState.RUNTIME is 4
        state_val = session_info.state.value if hasattr(session_info.state, 'value') else session_info.state
        if state_val == 4:  # RUNTIME state
            session = core.get_session(session_info.id)

            # Build a map of node_id -> IP from links
            node_ip_map = {}
            for link in session.links:
                # iface2 typically has the node's IP
                if link.iface2 and link.iface2.ip4:
                    node_ip_map[link.node2_id] = link.iface2.ip4.split("/")[0]
                if link.iface1 and link.iface1.ip4:
                    node_ip_map[link.node1_id] = link.iface1.ip4.split("/")[0]

            # session.nodes is a dict {node_id: Node}
            for node_id, node in session.nodes.items():
                # Check for Docker nodes (NodeType.DOCKER = 15)
                node_type_val = node.type.value if hasattr(node.type, 'value') else node.type
                if node_type_val == 15:  # DOCKER type
                    node_info = {
                        "id": node.id,
                        "name": node.name,
                        "image": node.image if node.image else "",
                        "session_id": session_info.id,
                        "position": {"x": node.position.x, "y": node.position.y}
                    }
                    # Get IP from our map built from links
                    if node_id in node_ip_map:
                        node_info["ip"] = node_ip_map[node_id]
                    nodes.append(node_info)

    print(json.dumps(nodes))
    core.close()
except Exception as e:
    import traceback
    print(json.dumps({"error": str(e), "trace": traceback.format_exc()}))
'''
        # Write script to temp file
        script_path = '/tmp/query_vnc_nodes.py'
        with open(script_path, 'w') as f:
            f.write(script_content)

        # Copy and execute
        subprocess.run(f'docker cp {script_path} core-novnc:/tmp/query_vnc_nodes.py',
                      shell=True, capture_output=True, timeout=10)

        query_cmd = 'docker exec core-novnc /opt/core/venv/bin/python3 /tmp/query_vnc_nodes.py'

        result = subprocess.run(query_cmd, shell=True, capture_output=True, text=True, timeout=20)

        if result.returncode == 0 and result.stdout.strip():
            try:
                all_nodes = json.loads(result.stdout.strip())
                if isinstance(all_nodes, dict) and 'error' in all_nodes:
                    return jsonify({'nodes': [], 'error': all_nodes['error']})

                # Filter for VNC-capable nodes
                for node in all_nodes:
                    image = node.get('image', '')
                    if any(vnc_img in image.lower() for vnc_img in vnc_images):
                        node['vnc_capable'] = True
                        node['type'] = 'hmi' if 'hmi' in image.lower() else (
                            'kali' if 'kali' in image.lower() else 'workstation'
                        )
                        nodes.append(node)

            except json.JSONDecodeError:
                pass

        return jsonify({'nodes': nodes})

    except Exception as e:
        return jsonify({'nodes': [], 'error': str(e)})


# =============================================================================
# VNC DESKTOP WRAPPER & AI HELP
# =============================================================================

# =============================================================================
# HMI VNC REVERSE PROXY
# Proxies VNC requests through port 8080 to the backend VNC servers
# This allows HMI VNC to work without requiring separate port forwarding
# =============================================================================

# -----------------------------------------------------------------------------
# CORE Desktop VNC Proxy - Main CORE GUI VNC through port 8080
# -----------------------------------------------------------------------------

@app.route('/core-vnc/<path:path>')
@app.route('/core-vnc/', defaults={'path': ''})
@app.route('/core-vnc', defaults={'path': ''})
def core_vnc_proxy(path):
    """
    Reverse proxy for main CORE desktop VNC connections.

    Proxies HTTP requests from /core-vnc/<path> to the websockify server
    running inside core-novnc container (originally on port 6080).

    This allows the CORE GUI VNC to work through port 8080 only.

    NOTE: WebSocket requests to /websockify are handled by the VNCWebSocketMiddleware.
    """
    import requests as http_requests

    # Check if this is a WebSocket upgrade request for the websockify endpoint
    if path == 'websockify' and request.headers.get('Upgrade', '').lower() == 'websocket':
        return jsonify({'error': 'WebSocket upgrade required. Use WebSocket connection.'}), 426

    # Default to vnc.html if no path specified
    if not path or path == '':
        path = 'vnc.html'

    # Proxy to the websockify server inside core-novnc (port 6080)
    target_url = f'http://localhost:6080/{path}'

    try:
        # Forward the request
        resp = http_requests.get(
            target_url,
            params=request.args,
            timeout=10
        )

        # Build response with CORS headers
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for name, value in resp.raw.headers.items()
                   if name.lower() not in excluded_headers]
        headers.append(('Access-Control-Allow-Origin', '*'))

        return Response(resp.content, resp.status_code, headers)

    except http_requests.exceptions.ConnectionError:
        return jsonify({
            'error': 'Cannot connect to CORE VNC server. Make sure core-novnc container is running.'
        }), 502
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# -----------------------------------------------------------------------------
# HMI VNC Proxy - Workstation VNC through port 8080
# -----------------------------------------------------------------------------

@app.route('/hmi-vnc/<int:port>/<path:path>')
@app.route('/hmi-vnc/<int:port>/', defaults={'path': ''})
@app.route('/hmi-vnc/<int:port>', defaults={'path': ''})
def hmi_vnc_proxy(port, path):
    """
    Reverse proxy for HMI VNC connections.

    Proxies HTTP requests from /hmi-vnc/<port>/<path> to localhost:<port>/<path>
    This allows VNC to work through port 8080 without requiring separate port exposure.

    The two-layer proxy chain (websockify:608X -> socat:1608X -> HMI) must already be running.

    NOTE: WebSocket requests to /websockify are handled by the flask-sock WebSocket route.
    """
    import requests as http_requests

    # Only allow proxying to valid VNC ports (6081-6083)
    if port < 6081 or port > 6083:
        return jsonify({'error': f'Invalid VNC port {port}. Must be 6081-6083'}), 400

    # Check if this is a WebSocket upgrade request for the websockify endpoint
    # If so, return an error - this should be handled by the WebSocket route
    if path == 'websockify' and request.headers.get('Upgrade', '').lower() == 'websocket':
        # This shouldn't happen if flask-sock is properly configured,
        # but just in case, return an appropriate error
        return jsonify({'error': 'WebSocket upgrade required. Use WebSocket connection.'}), 426

    # Build target URL
    target_url = f'http://localhost:{port}/{path}'
    if request.query_string:
        target_url += f'?{request.query_string.decode()}'

    try:
        # Forward the request
        resp = http_requests.request(
            method=request.method,
            url=target_url,
            headers={k: v for k, v in request.headers if k.lower() not in ['host', 'connection']},
            data=request.get_data(),
            allow_redirects=False,
            timeout=10
        )

        # Build response
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(k, v) for k, v in resp.raw.headers.items() if k.lower() not in excluded_headers]

        return (resp.content, resp.status_code, headers)

    except http_requests.exceptions.ConnectionError:
        return jsonify({
            'error': f'VNC proxy on port {port} not running. Start it via /api/start-host-vnc first.'
        }), 503
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# WebSocket proxy for VNC - handles the actual VNC data stream
# Uses flask-sockets for proper WebSocket routing

# HTTP fallback route for non-WebSocket requests to the websockify path
@app.route('/hmi-vnc/<int:port>/websockify')
def hmi_vnc_websocket_info(port):
    """Return info for HTTP requests to WebSocket endpoint."""
    if port < 6081 or port > 6089:
        return jsonify({'error': f'Invalid VNC port {port}. Must be 6081-6089'}), 400
    return jsonify({
        'info': 'WebSocket endpoint for VNC proxy',
        'port': port,
        'usage': f'Connect via WebSocket to ws://host:8080/hmi-vnc/{port}/websockify'
    }), 200


def vnc_websocket_proxy_handler(ws, port, is_core_vnc=False):
    """
    WebSocket proxy for VNC connections.

    Proxies WebSocket traffic from /hmi-vnc/<port>/websockify to localhost:<port>/websockify
    This is required for noVNC to work through the port 8080 reverse proxy.

    This function is called from the VNCWebSocketMiddleware when a WebSocket
    connection is made to /hmi-vnc/<port>/websockify or /core-vnc/websockify.

    Args:
        ws: The client WebSocket connection
        port: The backend port to connect to
        is_core_vnc: If True, this is the main CORE desktop VNC (port 5901)
    """
    import gevent

    # For CORE VNC, we connect directly to port 5901 (the VNC server)
    # For HMI VNC, we connect to ports 6081-6089 (websockify instances)
    if is_core_vnc:
        if port != 5901:
            print(f"VNC proxy: Invalid CORE VNC port {port}", flush=True)
            ws.close()
            return
    else:
        # Only allow proxying to valid HMI VNC ports (6081-6089)
        if port < 6081 or port > 6089:
            print(f"VNC proxy: Invalid port {port}", flush=True)
            ws.close()
            return

    print(f"VNC WebSocket proxy: client connected for port {port} (is_core_vnc={is_core_vnc})", flush=True)
    backend_ws = None

    try:
        # Connect to the backend websockify server
        # For CORE VNC: connect to websockify on port 6080 (which forwards to VNC on 5901)
        # For HMI VNC: connect to websockify on the specified port (6081-6089)
        if is_core_vnc:
            target_url = 'ws://localhost:6080/websockify'
        else:
            target_url = f'ws://localhost:{port}/websockify'

        print(f"VNC proxy: connecting to backend {target_url}", flush=True)
        backend_ws = ws_client.create_connection(target_url, timeout=10)
        backend_ws.settimeout(0.1)  # Short timeout for non-blocking recv

        print(f"VNC proxy: connected to backend", flush=True)

        running = [True]  # Shared flag to stop both greenlets

        def forward_client_to_backend():
            """Forward data from client WebSocket to backend WebSocket."""
            try:
                while running[0]:
                    try:
                        # gevent WebSocket's receive() blocks until data is available
                        # It returns None only when the connection is closed
                        msg = ws.receive()
                        if msg is None:
                            print(f"VNC proxy [{port}]: client closed connection", flush=True)
                            running[0] = False
                            break
                        # Forward to backend
                        print(f"VNC proxy [{port}]: client->backend: {len(msg) if msg else 0} bytes: {msg[:30] if msg else None}", flush=True)
                        if backend_ws:
                            if isinstance(msg, bytes):
                                backend_ws.send_binary(msg)
                            else:
                                # Convert text to bytes and send as binary
                                backend_ws.send_binary(msg.encode('latin-1') if isinstance(msg, str) else msg)
                    except Exception as e:
                        print(f"VNC proxy [{port}]: client->backend error: {e}", flush=True)
                        running[0] = False
                        break
            except Exception as e:
                print(f"VNC proxy [{port}]: client greenlet error: {e}", flush=True)
                running[0] = False

        def forward_backend_to_client():
            """Forward data from backend WebSocket to client WebSocket."""
            try:
                while running[0]:
                    try:
                        if not backend_ws:
                            break
                        # Use non-blocking recv with timeout
                        data = backend_ws.recv()
                        if data:
                            # VNC protocol uses binary data - always send as binary
                            # gevent-websocket's send() has binary=None by default
                            # which auto-detects, but explicitly set binary=True for bytes
                            print(f"VNC proxy [{port}]: backend->client: {len(data) if data else 0} bytes", flush=True)
                            if isinstance(data, bytes):
                                ws.send(data, binary=True)
                            else:
                                ws.send(data)
                        elif data == '':
                            # Empty string means connection closed
                            print(f"VNC proxy [{port}]: backend closed connection", flush=True)
                            running[0] = False
                            break
                        # If data is None, it might be a timeout, continue
                    except ws_client.WebSocketTimeoutException:
                        # Timeout is normal, yield to other greenlets
                        gevent.sleep(0.01)
                        continue
                    except ws_client.WebSocketConnectionClosedException:
                        print(f"VNC proxy [{port}]: backend connection closed", flush=True)
                        running[0] = False
                        break
                    except Exception as e:
                        print(f"VNC proxy [{port}]: backend->client error: {e}", flush=True)
                        running[0] = False
                        break
            except Exception as e:
                print(f"VNC proxy [{port}]: backend greenlet error: {e}", flush=True)
                running[0] = False

        # Run both directions concurrently using gevent
        g1 = gevent.spawn(forward_client_to_backend)
        g2 = gevent.spawn(forward_backend_to_client)

        # Wait for either greenlet to finish (connection closed)
        gevent.joinall([g1, g2], raise_error=False)

        print(f"VNC proxy: disconnected from port {port}", flush=True)

    except Exception as e:
        print(f"VNC proxy error: {e}", flush=True)
    finally:
        try:
            if backend_ws:
                backend_ws.close()
        except:
            pass


@app.route('/vnc/<node_name>')
def vnc_desktop(node_name):
    """
    Render the VNC desktop wrapper page with sidebar for a specific node.
    This provides Lab Guide, AI Help, and Node Info panels alongside the VNC viewer.

    VNC is now accessed through the /hmi-vnc/<port>/ proxy route, which proxies
    requests through port 8080 instead of requiring direct access to ports 6081-6083.
    """
    import os

    # Get node details from query params or defaults
    node_ip = request.args.get('ip', '')
    proxy_port = request.args.get('port', '6081')

    # Build VNC URL - now use the reverse proxy through port 8080
    # The path= parameter tells noVNC where to connect for WebSocket
    # This proxies through /hmi-vnc/<port>/ which forwards to localhost:<port>
    codespace_name = os.environ.get('CODESPACE_NAME', '')
    ws_path = f"hmi-vnc/{proxy_port}/websockify"
    if codespace_name:
        # In Codespaces, use the 8080 port with proxy path
        vnc_url = f"https://{codespace_name}-8080.app.github.dev/hmi-vnc/{proxy_port}/vnc_lite.html?scale=true&path={ws_path}"
    else:
        # Local dev can use direct port or proxy
        vnc_url = f"http://localhost:8080/hmi-vnc/{proxy_port}/vnc_lite.html?scale=true&path={ws_path}"

    return render_template('vnc_desktop.html',
                          node_name=node_name,
                          node_ip=node_ip,
                          vnc_url=vnc_url)


@app.route('/api/ai-help', methods=['POST'])
def ai_help():
    """
    AI Help endpoint for student questions.
    Accepts question text, optional screenshot, and context about current lab/node.
    Returns an AI-generated response to help the student.
    """
    try:
        data = request.get_json()
        question = data.get('question', '')
        screenshot = data.get('screenshot')  # Base64 encoded image
        context = data.get('context', {})
        conversation_history = data.get('conversation_history', [])

        # Build context summary
        context_parts = []
        if context.get('node_name'):
            context_parts.append(f"Node: {context['node_name']}")
        if context.get('node_ip'):
            context_parts.append(f"IP: {context['node_ip']}")
        if context.get('current_lab'):
            context_parts.append(f"Lab: {context['current_lab']}")
        if context.get('current_step'):
            context_parts.append(f"Step {context['current_step']}")
            if context.get('step_title'):
                context_parts.append(f"({context['step_title']})")

        context_str = " | ".join(context_parts) if context_parts else "No lab context"

        # For now, provide a helpful response based on the question
        # In production, this would integrate with an LLM API
        response_text = generate_ai_help_response(question, context, screenshot, conversation_history)

        return jsonify({
            'success': True,
            'response': response_text,
            'context_used': context_str
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'response': 'Sorry, there was an error processing your question.'
        }), 500


def generate_ai_help_response(question, context, screenshot, history):
    """
    Generate a helpful response for the student's question.
    This is a placeholder that provides contextual help based on common patterns.
    In production, integrate with an LLM API like Claude.
    """
    question_lower = question.lower()

    # Lab-specific help
    if context.get('current_lab'):
        lab = context['current_lab'].lower()

        if 'iot' in lab:
            if 'sensor' in question_lower or 'data' in question_lower:
                return """To view sensor data in the IoT lab:

1. Open Firefox in your HMI workstation
2. Navigate to the sensor server: `http://10.0.1.20/`
3. You should see the IoT Sensor Monitor page showing live sensor readings

If sensors aren't appearing:
- Check that the micro:bit is connected and sending data
- Verify the MQTT broker is running: `docker logs mqtt-broker`
- Check network connectivity: `ping 10.0.1.10`"""

            if 'mqtt' in question_lower or 'broker' in question_lower:
                return """The MQTT broker in this lab is at `10.0.1.10:1883`.

To test MQTT connectivity:
```bash
# Subscribe to sensor topics
mosquitto_sub -h 10.0.1.10 -t "core/sensors/#" -v

# Publish test data
mosquitto_pub -h 10.0.1.10 -t "core/sensors/test" -m '{"x":0,"y":0,"z":0}'
```

Common issues:
- Broker not started: Check with `docker ps | grep mqtt`
- Network issue: Run `ping 10.0.1.10` to test connectivity"""

    # General networking help
    if 'ping' in question_lower or 'network' in question_lower or 'connect' in question_lower:
        return """For network troubleshooting:

1. **Check connectivity**: `ping <target-ip>`
2. **View routing table**: `ip route`
3. **Check interfaces**: `ip addr`
4. **Test port**: `nc -zv <ip> <port>`

Common issues in CORE labs:
- Missing routes between networks
- Firewall blocking traffic
- Service not started on target host"""

    if 'terminal' in question_lower or 'command' in question_lower:
        return """To open a terminal on your HMI workstation:
1. Right-click on the desktop
2. Select "Terminal" or "XTerm"

Useful commands:
- `ip addr` - Show network interfaces
- `ping <ip>` - Test connectivity
- `curl http://<ip>` - Test web services
- `firefox <url>` - Open web browser"""

    if 'wireshark' in question_lower or 'capture' in question_lower:
        return """To capture network traffic:

1. From the Dashboard, go to the CORE GUI tab
2. Click on a network link (the line between nodes)
3. Right-click and select "Start Capture"
4. Wireshark will open in the CORE desktop

Or use tcpdump on a node:
```bash
tcpdump -i eth0 -w capture.pcap
```"""

    # Screenshot was included
    if screenshot:
        return """I can see you've shared a screenshot. Based on what I can observe:

If you're seeing an error:
- Check the terminal for error messages
- Verify the service is running
- Check network connectivity with `ping`

If it's a configuration screen:
- Review the current settings
- Consult the lab guide for expected values

Need more specific help? Describe what you see or what you're trying to accomplish."""

    # Generic help
    return f"""I'm here to help with your lab work!

**Current Context**: {context.get('current_lab', 'No active lab')}

Some things I can help with:
- Network troubleshooting (ping, routing, connectivity)
- MQTT broker and sensor data
- Terminal commands and navigation
- Understanding the lab topology

Try asking a specific question like:
- "How do I check if the MQTT broker is running?"
- "Why can't I ping the sensor server?"
- "How do I view sensor data in the browser?"

Or include a screenshot if you're seeing an error!"""


@app.route('/api/lab/current', methods=['GET'])
def get_current_lab():
    """Get the current lab state (for syncing across pages)"""
    # This is managed client-side via localStorage
    # This endpoint could be used to store/retrieve lab state server-side if needed
    return jsonify({'message': 'Lab state is managed client-side via localStorage'})


@app.route('/api/lab/current', methods=['POST'])
def set_current_lab():
    """Set the current lab state (for syncing across pages)"""
    # Could be used to persist lab state server-side
    data = request.get_json()
    # For now, just acknowledge - state is managed client-side
    return jsonify({'success': True, 'message': 'Lab state acknowledged'})


# =============================================================================
# PACKET CAPTURE API ENDPOINTS
# =============================================================================

# Track active captures: {capture_id: {'bridge': name, 'pid': pid, 'file': path}}
active_captures = {}

@app.route('/api/capture/bridges', methods=['GET'])
def get_capture_bridges():
    """
    Get all network bridges in CORE that can be used for packet capture.
    Returns bridge names, associated network info, and current capture status.
    """
    import subprocess

    bridges = []

    try:
        # Get all CORE bridges (format: b.<network-id>.<session-id>)
        result = subprocess.run(
            "docker exec core-novnc ip link show type bridge | grep -oE 'b\\.[0-9]+\\.[0-9]+' | sort -u",
            shell=True, capture_output=True, text=True, timeout=10
        )

        if result.returncode == 0 and result.stdout.strip():
            bridge_names = result.stdout.strip().split('\n')

            for bridge in bridge_names:
                # Parse bridge name: b.<network-id>.<session-id>
                parts = bridge.split('.')
                if len(parts) == 3:
                    network_id = parts[1]
                    session_id = parts[2]

                    # Check if capture is active on this bridge
                    capture_active = any(
                        c['bridge'] == bridge for c in active_captures.values()
                    )

                    bridges.append({
                        'name': bridge,
                        'network_id': int(network_id),
                        'session_id': int(session_id),
                        'capturing': capture_active,
                        'display_name': f"Network {network_id} (Session {session_id})"
                    })

        # Also get node interface info to enrich bridge data
        script_content = '''
import json
from core.api.grpc import client

try:
    core = client.CoreGrpcClient()
    core.connect()
    sessions = core.get_sessions()
    networks = []

    for session_info in sessions:
        state_val = session_info.state.value if hasattr(session_info.state, 'value') else session_info.state
        if state_val == 4:  # RUNTIME
            session = core.get_session(session_info.id)
            # Get network nodes (switches, hubs, wlans)
            for node_id, node in session.nodes.items():
                node_type_val = node.type.value if hasattr(node.type, 'value') else node.type
                # Switch=4, Hub=5, Wlan=6
                if node_type_val in [4, 5, 6]:
                    networks.append({
                        "id": node.id,
                        "name": node.name,
                        "type": "switch" if node_type_val == 4 else ("hub" if node_type_val == 5 else "wlan"),
                        "session_id": session_info.id
                    })
    print(json.dumps(networks))
    core.close()
except Exception as e:
    print(json.dumps([]))
'''
        script_path = '/tmp/query_networks.py'
        with open(script_path, 'w') as f:
            f.write(script_content)

        subprocess.run(f'docker cp {script_path} core-novnc:/tmp/query_networks.py',
                      shell=True, capture_output=True, timeout=10)

        net_result = subprocess.run(
            'docker exec core-novnc /opt/core/venv/bin/python3 /tmp/query_networks.py',
            shell=True, capture_output=True, text=True, timeout=20
        )

        if net_result.returncode == 0 and net_result.stdout.strip():
            try:
                networks = json.loads(net_result.stdout.strip())
                # Match bridges with network names
                for bridge in bridges:
                    for net in networks:
                        if net['id'] == bridge['network_id'] and net['session_id'] == bridge['session_id']:
                            bridge['display_name'] = f"{net['name']} ({net['type']})"
                            bridge['network_name'] = net['name']
                            bridge['network_type'] = net['type']
                            break
            except json.JSONDecodeError:
                pass

        return jsonify({'success': True, 'bridges': bridges})

    except Exception as e:
        return jsonify({'success': False, 'bridges': [], 'error': str(e)})


@app.route('/api/capture/start', methods=['POST'])
def start_capture():
    """
    Start packet capture on a bridge interface.
    POST body: { "bridge": "b.1.1", "filter": "optional pcap filter" }
    """
    import subprocess
    import uuid

    data = request.get_json()
    bridge = data.get('bridge')
    pcap_filter = data.get('filter', '')

    if not bridge:
        return jsonify({'success': False, 'error': 'Bridge name required'}), 400

    # Check if already capturing on this bridge
    for cap_id, cap_info in active_captures.items():
        if cap_info['bridge'] == bridge:
            return jsonify({
                'success': False,
                'error': f'Already capturing on {bridge}',
                'capture_id': cap_id
            }), 400

    try:
        capture_id = str(uuid.uuid4())[:8]
        pcap_file = f'/tmp/capture_{bridge.replace(".", "_")}_{capture_id}.pcap'

        # Build tcpdump command
        filter_arg = f'"{pcap_filter}"' if pcap_filter else ''
        cmd = f'docker exec -d core-novnc tcpdump -i {bridge} -w {pcap_file} -s 0 {filter_arg}'

        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)

        if result.returncode == 0:
            # Get the PID of tcpdump
            pid_result = subprocess.run(
                f"docker exec core-novnc pgrep -f 'tcpdump -i {bridge}'",
                shell=True, capture_output=True, text=True, timeout=5
            )
            pid = pid_result.stdout.strip().split('\n')[0] if pid_result.stdout.strip() else None

            active_captures[capture_id] = {
                'bridge': bridge,
                'pid': pid,
                'file': pcap_file,
                'filter': pcap_filter,
                'started_at': time.strftime('%Y-%m-%d %H:%M:%S')
            }

            return jsonify({
                'success': True,
                'capture_id': capture_id,
                'bridge': bridge,
                'file': pcap_file,
                'message': f'Capture started on {bridge}'
            })
        else:
            return jsonify({
                'success': False,
                'error': result.stderr or 'Failed to start capture'
            }), 500

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/capture/stop', methods=['POST'])
def stop_capture():
    """
    Stop a running packet capture.
    POST body: { "capture_id": "abc123" } or { "bridge": "b.1.1" }
    """
    import subprocess

    data = request.get_json()
    capture_id = data.get('capture_id')
    bridge = data.get('bridge')

    # Find the capture to stop
    cap_to_stop = None
    cap_id_to_remove = None

    if capture_id and capture_id in active_captures:
        cap_to_stop = active_captures[capture_id]
        cap_id_to_remove = capture_id
    elif bridge:
        for cap_id, cap_info in active_captures.items():
            if cap_info['bridge'] == bridge:
                cap_to_stop = cap_info
                cap_id_to_remove = cap_id
                break

    if not cap_to_stop:
        return jsonify({'success': False, 'error': 'Capture not found'}), 404

    try:
        # Kill the tcpdump process
        if cap_to_stop.get('pid'):
            subprocess.run(
                f"docker exec core-novnc kill {cap_to_stop['pid']}",
                shell=True, capture_output=True, timeout=5
            )
        else:
            # Fallback: kill by interface name
            subprocess.run(
                f"docker exec core-novnc pkill -f 'tcpdump -i {cap_to_stop['bridge']}'",
                shell=True, capture_output=True, timeout=5
            )

        # Remove from active captures
        del active_captures[cap_id_to_remove]

        return jsonify({
            'success': True,
            'message': f'Capture stopped on {cap_to_stop["bridge"]}',
            'file': cap_to_stop['file']
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/capture/status', methods=['GET'])
def get_capture_status():
    """Get status of all active captures"""
    import subprocess

    captures = []
    for cap_id, cap_info in list(active_captures.items()):
        # Check if still running
        result = subprocess.run(
            f"docker exec core-novnc pgrep -f 'tcpdump -i {cap_info['bridge']}'",
            shell=True, capture_output=True, text=True, timeout=5
        )
        running = result.returncode == 0

        # Get file size
        size_result = subprocess.run(
            f"docker exec core-novnc stat -c %s {cap_info['file']} 2>/dev/null || echo 0",
            shell=True, capture_output=True, text=True, timeout=5
        )
        file_size = int(size_result.stdout.strip() or 0)

        captures.append({
            'capture_id': cap_id,
            'bridge': cap_info['bridge'],
            'file': cap_info['file'],
            'filter': cap_info.get('filter', ''),
            'started_at': cap_info.get('started_at', ''),
            'running': running,
            'file_size': file_size,
            'file_size_human': f"{file_size / 1024:.1f} KB" if file_size < 1024*1024 else f"{file_size / (1024*1024):.1f} MB"
        })

        # Clean up if no longer running
        if not running:
            del active_captures[cap_id]

    return jsonify({'success': True, 'captures': captures})


@app.route('/api/capture/download/<capture_id>', methods=['GET'])
def download_capture(capture_id):
    """Download a capture file"""
    import subprocess

    # Check if capture exists or was recently stopped
    cap_info = active_captures.get(capture_id)

    if not cap_info:
        return jsonify({'success': False, 'error': 'Capture not found'}), 404

    try:
        # Copy file from container to host
        local_path = f'/tmp/capture_{capture_id}.pcap'
        subprocess.run(
            f"docker cp core-novnc:{cap_info['file']} {local_path}",
            shell=True, capture_output=True, timeout=30
        )

        if os.path.exists(local_path):
            return send_file(
                local_path,
                as_attachment=True,
                download_name=f"capture_{cap_info['bridge'].replace('.', '_')}.pcap",
                mimetype='application/vnd.tcpdump.pcap'
            )
        else:
            return jsonify({'success': False, 'error': 'File not found'}), 404

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/capture/stop-all', methods=['POST'])
def stop_all_captures():
    """Stop all running captures"""
    import subprocess

    stopped = []
    for cap_id, cap_info in list(active_captures.items()):
        try:
            subprocess.run(
                f"docker exec core-novnc pkill -f 'tcpdump -i {cap_info['bridge']}'",
                shell=True, capture_output=True, timeout=5
            )
            stopped.append(cap_info['bridge'])
        except:
            pass

    active_captures.clear()

    return jsonify({
        'success': True,
        'stopped': stopped,
        'message': f'Stopped {len(stopped)} captures'
    })


# Track active Wireshark instances: {wireshark_id: {'bridge': name, 'pid': pid}}
active_wiresharks = {}

@app.route('/api/capture/wireshark', methods=['POST'])
def launch_wireshark():
    """
    Launch Wireshark GUI in the noVNC desktop to view live traffic on a bridge.
    POST body: { "bridge": "b.1.1", "filter": "optional display filter" }

    The Wireshark window will open in the core-novnc X11 desktop, visible via noVNC.
    """
    import subprocess
    import uuid

    data = request.get_json()
    bridge = data.get('bridge')
    display_filter = data.get('filter', '')

    if not bridge:
        return jsonify({'success': False, 'error': 'Bridge name required'}), 400

    try:
        wireshark_id = str(uuid.uuid4())[:8]

        # Build Wireshark command
        # -i: interface to capture on
        # -k: start capture immediately
        # -f: capture filter (BPF syntax)
        # -Y: display filter (Wireshark syntax)
        cmd_parts = ['wireshark', '-i', bridge, '-k']

        if display_filter:
            # Use display filter (-Y) for Wireshark-style filters
            cmd_parts.extend(['-Y', f'"{display_filter}"'])

        wireshark_cmd = ' '.join(cmd_parts)

        # Launch Wireshark in the X11 desktop (DISPLAY=:1)
        # Use nohup and & to run in background
        full_cmd = f'docker exec -d -e DISPLAY=:1 core-novnc {wireshark_cmd}'

        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, timeout=10)

        if result.returncode == 0:
            # Get PID of the new Wireshark process
            import time
            time.sleep(1)  # Give it a moment to start

            pid_result = subprocess.run(
                f"docker exec core-novnc pgrep -n -f 'wireshark -i {bridge}'",
                shell=True, capture_output=True, text=True, timeout=5
            )

            pid = pid_result.stdout.strip() if pid_result.returncode == 0 else 'unknown'

            active_wiresharks[wireshark_id] = {
                'bridge': bridge,
                'pid': pid,
                'filter': display_filter
            }

            return jsonify({
                'success': True,
                'wireshark_id': wireshark_id,
                'bridge': bridge,
                'pid': pid,
                'message': f'Wireshark launched on {bridge}. View in noVNC desktop (port 6080).',
                'novnc_hint': 'Open noVNC to see the Wireshark window'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Failed to launch Wireshark: {result.stderr}'
            }), 500

    except subprocess.TimeoutExpired:
        return jsonify({'success': False, 'error': 'Timeout launching Wireshark'}), 500
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/capture/wireshark/stop', methods=['POST'])
def stop_wireshark():
    """
    Stop a running Wireshark instance.
    POST body: { "wireshark_id": "abc123" } or { "bridge": "b.1.1" } or { "all": true }
    """
    import subprocess

    data = request.get_json()
    wireshark_id = data.get('wireshark_id')
    bridge = data.get('bridge')
    stop_all = data.get('all', False)

    stopped = []

    try:
        if stop_all:
            # Kill all Wireshark instances
            subprocess.run(
                "docker exec core-novnc pkill -f 'wireshark -i b\\.'",
                shell=True, capture_output=True, timeout=5
            )
            stopped = list(active_wiresharks.keys())
            active_wiresharks.clear()

        elif wireshark_id and wireshark_id in active_wiresharks:
            ws_info = active_wiresharks[wireshark_id]
            subprocess.run(
                f"docker exec core-novnc pkill -f 'wireshark -i {ws_info['bridge']}'",
                shell=True, capture_output=True, timeout=5
            )
            del active_wiresharks[wireshark_id]
            stopped.append(wireshark_id)

        elif bridge:
            # Stop by bridge name
            subprocess.run(
                f"docker exec core-novnc pkill -f 'wireshark -i {bridge}'",
                shell=True, capture_output=True, timeout=5
            )
            # Remove from tracking
            to_remove = [wid for wid, info in active_wiresharks.items() if info['bridge'] == bridge]
            for wid in to_remove:
                del active_wiresharks[wid]
                stopped.append(wid)

        return jsonify({
            'success': True,
            'stopped': stopped,
            'message': f'Stopped {len(stopped)} Wireshark instance(s)'
        })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/capture/wireshark/status', methods=['GET'])
def get_wireshark_status():
    """Get status of running Wireshark instances"""
    import subprocess

    # Verify which ones are still running
    running = []
    for ws_id, ws_info in list(active_wiresharks.items()):
        try:
            result = subprocess.run(
                f"docker exec core-novnc pgrep -f 'wireshark -i {ws_info['bridge']}'",
                shell=True, capture_output=True, text=True, timeout=5
            )
            if result.returncode == 0 and result.stdout.strip():
                ws_info['pid'] = result.stdout.strip().split()[0]
                running.append({
                    'wireshark_id': ws_id,
                    **ws_info
                })
            else:
                # Process died, remove from tracking
                del active_wiresharks[ws_id]
        except:
            pass

    return jsonify({
        'success': True,
        'wiresharks': running,
        'count': len(running)
    })


@app.route('/api/topology/enable-pcap', methods=['POST'])
def enable_pcap_on_nodes():
    """
    Enable the PCAP service on nodes in the current topology.
    This adds automatic packet capture on all interfaces of selected nodes.
    POST body: { "nodes": ["node1", "node2"] } or { "all": true }
    """
    global current_generator

    if not current_generator or not current_generator.nodes:
        return jsonify({'success': False, 'error': 'No topology loaded'}), 400

    data = request.get_json()
    enable_all = data.get('all', False)
    node_names = data.get('nodes', [])

    updated_nodes = []

    for node_id, node in current_generator.nodes.items():
        if enable_all or node.name in node_names:
            # Add pcap service if not already present
            if 'pcap' not in node.services:
                node.services.append('pcap')
                updated_nodes.append(node.name)

    if updated_nodes:
        return jsonify({
            'success': True,
            'message': f'PCAP service enabled on {len(updated_nodes)} nodes',
            'nodes': updated_nodes,
            'info': 'Capture files will be saved to $SESSION_DIR/pcap/ when session stops'
        })
    else:
        return jsonify({
            'success': True,
            'message': 'No nodes updated (PCAP already enabled or no matching nodes)',
            'nodes': []
        })


@app.route('/api/topology/disable-pcap', methods=['POST'])
def disable_pcap_on_nodes():
    """
    Disable the PCAP service on nodes in the current topology.
    POST body: { "nodes": ["node1", "node2"] } or { "all": true }
    """
    global current_generator

    if not current_generator or not current_generator.nodes:
        return jsonify({'success': False, 'error': 'No topology loaded'}), 400

    data = request.get_json()
    disable_all = data.get('all', False)
    node_names = data.get('nodes', [])

    updated_nodes = []

    for node_id, node in current_generator.nodes.items():
        if disable_all or node.name in node_names:
            if 'pcap' in node.services:
                node.services.remove('pcap')
                updated_nodes.append(node.name)

    return jsonify({
        'success': True,
        'message': f'PCAP service disabled on {len(updated_nodes)} nodes',
        'nodes': updated_nodes
    })


@app.route('/api/topology/pcap-status', methods=['GET'])
def get_pcap_status():
    """Get PCAP service status for all nodes"""
    global current_generator

    if not current_generator or not current_generator.nodes:
        return jsonify({'success': False, 'nodes': [], 'error': 'No topology loaded'})

    nodes = []
    for node_id, node in current_generator.nodes.items():
        if node.node_type not in ['switch', 'hub', 'wlan']:  # Only show for hosts/routers
            nodes.append({
                'id': node_id,
                'name': node.name,
                'type': node.node_type,
                'pcap_enabled': 'pcap' in node.services,
                'services': node.services
            })

    return jsonify({
        'success': True,
        'nodes': nodes,
        'pcap_enabled_count': sum(1 for n in nodes if n['pcap_enabled'])
    })


@app.route('/api/start-topology', methods=['POST'])
def start_topology():
    """Start the current CORE session (transition from CONFIGURATION to RUNTIME)"""
    import subprocess

    try:
        # Create a Python script to start the session
        # States: DEFINITION=1, CONFIGURATION=2, INSTANTIATION=3, RUNTIME=4
        script = '''
import sys
sys.path.insert(0, '/opt/core/venv/lib/python3.11/site-packages')
from core.api.grpc import client

# State values as integers
DEFINITION = 1
CONFIGURATION = 2
RUNTIME = 4

try:
    core = client.CoreGrpcClient()
    core.connect()
    sessions = core.get_sessions()
    started = False
    for session_info in sessions:
        # Get state value (could be int or enum)
        state = session_info.state.value if hasattr(session_info.state, "value") else session_info.state
        if state == RUNTIME:
            print(f"Session {session_info.id} already running")
            started = True
            break
        elif state in [DEFINITION, CONFIGURATION]:
            # Get full session object to pass to start_session
            session = core.get_session(session_info.id)
            # start_session takes Session object, not session id
            result = core.start_session(session)
            started = True
            print(f"Started session {session_info.id}: {result}")
            break
    if not started:
        print("No session to start")
    core.close()
except Exception as e:
    import traceback
    traceback.print_exc()
    print(f"Error: {e}")
'''
        # Write script to temp file and execute
        script_path = '/tmp/start_session.py'
        with open(script_path, 'w') as f:
            f.write(script)

        # Copy and execute in core-novnc
        subprocess.run(f'docker cp {script_path} core-novnc:/tmp/start_session.py',
                      shell=True, capture_output=True, timeout=10)

        result = subprocess.run(
            'docker exec core-novnc /opt/core/venv/bin/python3 /tmp/start_session.py',
            shell=True, capture_output=True, text=True, timeout=60
        )

        if 'Started session' in result.stdout or 'already running' in result.stdout:
            return jsonify({
                'success': True,
                'message': 'Topology started successfully',
                'output': result.stdout.strip()
            })
        elif 'No session to start' in result.stdout:
            return jsonify({
                'success': False,
                'error': 'No session found to start'
            }), 400
        else:
            return jsonify({
                'success': False,
                'error': result.stderr or result.stdout or 'Unknown error'
            }), 500

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


# =============================================================================
# Digital Twin Builder API Routes
# =============================================================================

from digital_twin_builder import builder, DigitalTwinBuilder

@app.route('/builder')
def builder_ui():
    """Digital Twin Builder progressive UI"""
    return render_template('builder.html')


@app.route('/api/builder/projects', methods=['GET'])
def list_builder_projects():
    """List all saved projects"""
    return jsonify(builder.list_projects())


@app.route('/api/builder/projects', methods=['POST'])
def create_builder_project():
    """Create a new project"""
    data = request.get_json()
    project = builder.new_project(
        name=data.get('name', 'Untitled'),
        description=data.get('description', ''),
        is_real_site=data.get('is_real_site', False)
    )
    return jsonify({'success': True, 'project': builder._project_to_dict(project)})


@app.route('/api/builder/projects/<project_id>', methods=['GET'])
def load_builder_project(project_id):
    """Load a specific project"""
    project = builder.load_project(project_id)
    if project:
        return jsonify({'success': True, 'project': builder._project_to_dict(project)})
    return jsonify({'success': False, 'error': 'Project not found'}), 404


@app.route('/api/builder/projects/<project_id>', methods=['DELETE'])
def delete_builder_project(project_id):
    """Delete a project"""
    if builder.delete_project(project_id):
        return jsonify({'success': True})
    return jsonify({'success': False, 'error': 'Project not found'}), 404


@app.route('/api/builder/zones', methods=['POST'])
def add_builder_zone():
    """Add a network zone"""
    data = request.get_json()
    try:
        builder.add_zone(
            name=data.get('name'),
            zone_type=data.get('zone_type'),
            subnet=data.get('subnet', ''),
            description=data.get('description', '')
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/nodes', methods=['POST'])
def add_builder_node():
    """Add a node to the topology"""
    data = request.get_json()
    try:
        builder.add_node(
            name=data.get('name'),
            node_type=data.get('node_type'),
            zone=data.get('zone', ''),
            services=data.get('services', []),
            docker_image=data.get('docker_image', ''),
            x=data.get('x', 0),
            y=data.get('y', 0)
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/links', methods=['POST'])
def add_builder_link():
    """Add a link between nodes"""
    data = request.get_json()
    try:
        link = builder.add_link(
            node1_name=data.get('node1_name'),
            node2_name=data.get('node2_name'),
            bandwidth=data.get('bandwidth', 100000000),
            delay=data.get('delay', 0),
            loss=data.get('loss', 0.0)
        )
        if link:
            return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
        return jsonify({'success': False, 'error': 'Nodes not found'}), 400
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/plcs', methods=['POST'])
def add_builder_plc():
    """Add a PLC placeholder"""
    data = request.get_json()
    try:
        builder.add_plc_placeholder(
            name=data.get('name'),
            plc_type=data.get('plc_type', 'OpenPLC'),
            language=data.get('language', 'ST'),
            io_mapping=data.get('io_mapping', {}),
            process_description=data.get('process_description', ''),
            connected_otsim=data.get('connected_otsim', '')
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/otsim', methods=['POST'])
def add_builder_otsim():
    """Add an OT-sim process model placeholder"""
    data = request.get_json()
    try:
        builder.add_otsim_placeholder(
            name=data.get('name'),
            process_type=data.get('process_type'),
            physical_units=data.get('physical_units', {}),
            signals=data.get('signals', []),
            behavior_description=data.get('behavior_description', ''),
            connected_plcs=data.get('connected_plcs', [])
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/sensors', methods=['POST'])
def add_builder_sensor():
    """Add a sensor placeholder"""
    data = request.get_json()
    try:
        builder.add_sensor_placeholder(
            name=data.get('name'),
            sensor_type=data.get('sensor_type'),
            data_source=data.get('data_source', ''),
            signals=data.get('signals', []),
            update_interval=data.get('update_interval', 60),
            description=data.get('description', '')
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/protocols', methods=['POST'])
def add_builder_protocol():
    """Add a protocol placeholder"""
    data = request.get_json()
    try:
        builder.add_protocol_placeholder(
            name=data.get('name'),
            protocol=data.get('protocol'),
            role=data.get('role', ''),
            endpoints=data.get('endpoints', []),
            description=data.get('description', '')
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/physical-twins', methods=['POST'])
def add_builder_physical_twin():
    """Add a 3D/AR/VR physical twin placeholder"""
    data = request.get_json()
    try:
        # Parse cyber_mappings if it's a string
        cyber_mappings = data.get('cyber_mappings', {})
        if isinstance(cyber_mappings, str):
            # Simple parsing: "key1 -> val1, key2 -> val2"
            cyber_mappings = {}
            for mapping in data.get('cyber_mappings', '').split(','):
                if '->' in mapping:
                    k, v = mapping.split('->')
                    cyber_mappings[k.strip()] = v.strip()

        builder.add_physical_twin_placeholder(
            name=data.get('name'),
            model_type=data.get('model_type'),
            scale=data.get('scale', {}),
            materials=data.get('materials', []),
            moving_parts=data.get('moving_parts', []),
            physics_type=data.get('physics_type', ''),
            interactions=data.get('interactions', []),
            cyber_mappings=cyber_mappings,
            ar_vr_targets=data.get('ar_vr_targets', []),
            description=data.get('description', '')
        )
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/notes', methods=['POST'])
def add_builder_note():
    """Add a note to the project"""
    data = request.get_json()
    try:
        builder.add_note(data.get('note', ''))
        return jsonify({'success': True, 'project': builder._project_to_dict(builder.current_project)})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/generate-xml', methods=['POST'])
def generate_builder_xml():
    """Generate CORE XML from current project"""
    try:
        xml = builder.generate_xml()
        return jsonify({'success': True, 'xml': xml})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400


@app.route('/api/builder/load-in-core', methods=['POST'])
def load_builder_in_core():
    """Load generated XML into CORE"""
    import subprocess
    import shutil

    try:
        if not builder.current_project or not builder.current_project.last_generated_xml:
            return jsonify({'success': False, 'error': 'Generate XML first'}), 400

        # Save XML to temp file
        xml_path = '/tmp/builder_topology.xml'
        with open(xml_path, 'w') as f:
            f.write(builder.current_project.last_generated_xml)

        # Copy to container
        subprocess.run(
            f"docker cp {xml_path} core-novnc:/root/topologies/builder_topology.xml",
            shell=True,
            capture_output=True
        )

        # Copy load script
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
            shell=True,
            capture_output=True
        )

        # Load the topology with auto-start
        load_cmd = """docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/load_topology.py --start /root/topologies/builder_topology.xml
        '"""
        result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True, timeout=60)

        # Check for success indicators
        if "Topology loaded" in result.stdout or "Session ID:" in result.stdout:
            # Extract session ID for injector auto-start
            session_id = 1  # Default
            import re
            match = re.search(r'Session ID: (\d+)', result.stdout)
            if match:
                session_id = int(match.group(1))

            # Auto-start MQTT injector if topology contains an mqtt-broker node
            injector_started = False
            if builder.current_project:
                # Build template dict from builder project for injector detection
                template = {
                    'nodes': [
                        {
                            'name': node.name,
                            'image': node.docker_image or '',
                            'ip': ''  # IP will be detected from node name pattern
                        }
                        for node in builder.current_project.nodes
                    ],
                    'links': []
                }
                injector_started = auto_start_injector_for_topology(template, session_id)

            return jsonify({
                'success': True,
                'output': result.stdout,
                'session_id': session_id,
                'injector_started': injector_started
            })
        else:
            return jsonify({'success': False, 'error': result.stdout + result.stderr}), 500

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/builder/progress', methods=['GET'])
def get_builder_progress():
    """Get project progress summary"""
    try:
        return jsonify(builder.get_progress_summary())
    except Exception as e:
        return jsonify({'error': str(e)}), 400


# =============================================================================
# APPLIANCE REGISTRY ENDPOINTS
# =============================================================================

@app.route('/api/appliances', methods=['GET'])
def get_appliances():
    """Get list of available network appliances"""
    try:
        category = request.args.get('category')

        if category:
            try:
                cat = ApplianceCategory(category)
                appliances = list_appliances(cat)
            except ValueError:
                appliances = list_appliances()
        else:
            appliances = list_appliances()

        result = []
        for spec in appliances:
            status = check_appliance_ready(spec)
            result.append({
                'name': spec.name,
                'display_name': spec.display_name,
                'description': spec.description,
                'category': spec.category.value,
                'keywords': spec.keywords,
                'image': spec.full_image_name(),
                'supports_multi_nic': spec.supports_multi_nic,
                'min_interfaces': spec.min_interfaces,
                'max_interfaces': spec.max_interfaces,
                'typical_placement': spec.typical_placement,
                'ports': spec.ports,
                'ready': status['ready'],
                'warnings': status['warnings'] if not status['ready'] else [],
            })

        return jsonify({
            'appliances': result,
            'categories': [c.value for c in ApplianceCategory]
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/appliances/verify', methods=['GET'])
def verify_appliances():
    """Verify all appliances are ready (images available)"""
    try:
        results = verify_all_appliances()

        all_ready = all(status['ready'] for status in results.values())

        return jsonify({
            'all_ready': all_ready,
            'appliances': {
                name: {
                    'ready': status['ready'],
                    'image_available': status['image_available'],
                    'warnings': status['warnings'],
                }
                for name, status in results.items()
            }
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/appliances/<name>', methods=['GET'])
def get_appliance_details(name):
    """Get details for a specific appliance"""
    try:
        spec = get_appliance(name)
        if not spec:
            return jsonify({'error': f'Appliance not found: {name}'}), 404

        status = check_appliance_ready(spec)

        return jsonify({
            'name': spec.name,
            'display_name': spec.display_name,
            'description': spec.description,
            'category': spec.category.value,
            'keywords': spec.keywords,
            'image': spec.full_image_name(),
            'base_image': spec.base_image,
            'compose': {
                'template_file': spec.compose.template_file,
                'service_name': spec.compose.service_name,
            } if spec.compose else None,
            'supports_multi_nic': spec.supports_multi_nic,
            'min_interfaces': spec.min_interfaces,
            'max_interfaces': spec.max_interfaces,
            'interfaces': [
                {
                    'name': iface.name,
                    'role': iface.role,
                    'description': iface.description,
                }
                for iface in spec.interfaces
            ],
            'config_method': spec.config_method.value,
            'config_paths': spec.config_paths,
            'ports': spec.ports,
            'health_check': spec.health_check,
            'startup_time': spec.startup_time,
            'network_roles': [r.value for r in spec.network_roles],
            'typical_placement': spec.typical_placement,
            'ready': status['ready'],
            'warnings': status['warnings'],
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============================================================================
# IoT Sensor Data API - Bridge physical sensors to CORE network nodes
# ============================================================================

@app.route('/api/sensors', methods=['GET'])
def list_sensors():
    """List all registered sensors and their bindings"""
    return jsonify({
        'sensors': sensor_data_store['sensors'],
        'bindings': sensor_data_store['bindings'],
        'active_count': len(sensor_data_store['sensors']),
    })


@app.route('/api/sensors/<sensor_id>', methods=['GET'])
def get_sensor(sensor_id):
    """Get sensor info and recent readings"""
    if sensor_id not in sensor_data_store['sensors']:
        return jsonify({'error': f'Sensor {sensor_id} not found'}), 404

    readings = sensor_data_store['readings'].get(sensor_id, [])
    return jsonify({
        'sensor': sensor_data_store['sensors'][sensor_id],
        'binding': sensor_data_store['bindings'].get(sensor_id),
        'readings': readings[-100:],  # Last 100 readings
        'total_readings': len(readings),
    })


@app.route('/api/sensors/<sensor_id>/register', methods=['POST'])
def register_sensor(sensor_id):
    """Register a new sensor (called when micro:bit connects)"""
    data = request.get_json() or {}

    sensor_data_store['sensors'][sensor_id] = {
        'id': sensor_id,
        'type': data.get('type', 'microbit'),
        'name': data.get('name', f'Sensor-{sensor_id}'),
        'registered_at': json.dumps({"$date": "now"}),  # Timestamp
        'config': data.get('config', {}),
    }
    sensor_data_store['readings'][sensor_id] = []

    return jsonify({
        'status': 'registered',
        'sensor_id': sensor_id,
        'sensor': sensor_data_store['sensors'][sensor_id],
    })


@app.route('/api/sensors/<sensor_id>/data', methods=['POST'])
def receive_sensor_data(sensor_id):
    """
    Receive sensor data from browser WebSerial
    POST body: {"x": 100, "y": 200, "z": 300, "timestamp": 1234567890}

    This endpoint is called by the microbit.html page to relay data
    from the physical micro:bit into the CORE network environment.
    """
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # Auto-register sensor if not exists
    if sensor_id not in sensor_data_store['sensors']:
        sensor_data_store['sensors'][sensor_id] = {
            'id': sensor_id,
            'type': 'microbit',
            'name': f'Sensor-{sensor_id}',
            'auto_registered': True,
        }
        sensor_data_store['readings'][sensor_id] = []

    # Add timestamp if not provided
    if 'timestamp' not in data:
        import time
        data['timestamp'] = int(time.time() * 1000)

    # Store reading
    readings = sensor_data_store['readings'][sensor_id]
    readings.append(data)

    # Circular buffer - keep only MAX_SENSOR_READINGS
    if len(readings) > MAX_SENSOR_READINGS:
        sensor_data_store['readings'][sensor_id] = readings[-MAX_SENSOR_READINGS:]

    # If bound to a CORE node, we could forward data here
    binding = sensor_data_store['bindings'].get(sensor_id)

    # Publish to MQTT if connected
    mqtt_published = publish_sensor_data(sensor_id, data)

    return jsonify({
        'status': 'received',
        'sensor_id': sensor_id,
        'reading_count': len(sensor_data_store['readings'][sensor_id]),
        'bound_to': binding,
        'mqtt_published': mqtt_published,
    })


@app.route('/api/sensors/<sensor_id>/bind', methods=['POST'])
def bind_sensor_to_node(sensor_id):
    """
    Bind a sensor to a CORE network node.
    This creates the association between a physical sensor and a virtual node.

    POST body: {"node_name": "iot-sensor-1"}
    """
    data = request.get_json()
    if not data or 'node_name' not in data:
        return jsonify({'error': 'node_name is required'}), 400

    if sensor_id not in sensor_data_store['sensors']:
        return jsonify({'error': f'Sensor {sensor_id} not registered'}), 404

    node_name = data['node_name']
    sensor_data_store['bindings'][sensor_id] = node_name

    return jsonify({
        'status': 'bound',
        'sensor_id': sensor_id,
        'node_name': node_name,
    })


@app.route('/api/sensors/<sensor_id>/unbind', methods=['POST'])
def unbind_sensor(sensor_id):
    """Remove sensor-to-node binding"""
    if sensor_id in sensor_data_store['bindings']:
        del sensor_data_store['bindings'][sensor_id]

    return jsonify({
        'status': 'unbound',
        'sensor_id': sensor_id,
    })


@app.route('/api/sensors/<sensor_id>/readings', methods=['GET'])
def get_sensor_readings(sensor_id):
    """Get sensor readings with optional limit and offset"""
    if sensor_id not in sensor_data_store['readings']:
        return jsonify({'error': f'Sensor {sensor_id} not found'}), 404

    limit = request.args.get('limit', 100, type=int)
    offset = request.args.get('offset', 0, type=int)

    readings = sensor_data_store['readings'][sensor_id]
    total = len(readings)

    # Return readings with pagination
    paginated = readings[-(offset + limit):-offset] if offset > 0 else readings[-limit:]

    return jsonify({
        'sensor_id': sensor_id,
        'readings': paginated,
        'total': total,
        'limit': limit,
        'offset': offset,
    })


@app.route('/api/sensors/<sensor_id>', methods=['DELETE'])
def delete_sensor(sensor_id):
    """Delete a sensor and all its data"""
    if sensor_id not in sensor_data_store['sensors']:
        return jsonify({'error': f'Sensor {sensor_id} not found'}), 404

    # Remove from all stores
    del sensor_data_store['sensors'][sensor_id]
    if sensor_id in sensor_data_store['readings']:
        del sensor_data_store['readings'][sensor_id]
    if sensor_id in sensor_data_store['bindings']:
        del sensor_data_store['bindings'][sensor_id]

    return jsonify({
        'success': True,
        'sensor_id': sensor_id,
        'message': f'Sensor {sensor_id} deleted'
    })


# ============================================================================
# CORE Network Injector Proxy
# Proxies requests from browser to the MQTT injector running on localhost:8089
# This is needed because browsers can't directly access different ports (CORS)
# ============================================================================

INJECTOR_PORT = 8089  # Port where core_mqtt_injector.py listens

@app.route('/api/inject/<sensor_id>', methods=['POST'])
def proxy_inject(sensor_id):
    """Proxy sensor data injection to the CORE network injector.

    Falls back to embedded injector if external injector isn't running.
    """
    import requests

    data = request.get_json() or {}

    # First try external injector
    try:
        injector_url = f'http://localhost:{INJECTOR_PORT}/inject/{sensor_id}'
        response = requests.post(
            injector_url,
            json=data,
            timeout=5
        )
        return jsonify(response.json()), response.status_code
    except requests.exceptions.ConnectionError:
        # External injector not running - try embedded injector
        pass
    except Exception as e:
        # Other error with external injector - try embedded
        print(f"[INJECT] External injector error: {e}, trying embedded...")

    # Fall back to embedded injector
    global embedded_injector
    if embedded_injector.running and embedded_injector.broker_ip:
        topic = f"core/sensors/{sensor_id}/data"
        embedded_injector.queue_message(topic, data)
        return jsonify({
            'status': 'queued',
            'sensor_id': sensor_id,
            'topic': topic,
            'injected_to_core': True,
            'injector': 'embedded'
        })
    else:
        return jsonify({
            'error': 'No injector available',
            'external_injector': 'not running',
            'embedded_injector': 'not configured' if not embedded_injector.broker_ip else 'not running',
            'hint': 'Deploy a topology with mqtt-broker to auto-start the injector'
        }), 503


@app.route('/api/inject/status', methods=['GET'])
def proxy_injector_status():
    """Proxy status request to the CORE network injector"""
    import requests

    # Check external injector first
    try:
        injector_url = f'http://localhost:{INJECTOR_PORT}/status'
        response = requests.get(injector_url, timeout=5)
        result = response.json()
        result['injector_type'] = 'external'
        return jsonify(result), response.status_code
    except requests.exceptions.ConnectionError:
        pass
    except Exception:
        pass

    # Fall back to embedded injector status
    global embedded_injector
    return jsonify({
        'running': embedded_injector.running,
        'message_count': embedded_injector.message_count,
        'queue_size': embedded_injector.message_queue.qsize() if embedded_injector.message_queue else 0,
        'broker_ip': embedded_injector.broker_ip,
        'source_node': embedded_injector.source_node,
        'injector_type': 'embedded',
        'last_error': embedded_injector.last_error
    }), 200


@app.route('/api/inject/configure', methods=['POST'])
def configure_embedded_injector():
    """Manually configure and start the embedded MQTT injector.

    Can auto-detect mqtt-broker from current CORE session or accept manual config.
    """
    global embedded_injector

    data = request.get_json() or {}
    session_id = data.get('session_id', 1)
    broker_node = data.get('broker_node')
    broker_ip = data.get('broker_ip')

    # Auto-detect mqtt-broker if not provided
    if not broker_node or not broker_ip:
        try:
            # Query CORE for mqtt-broker node
            import subprocess
            detect_cmd = """docker exec core-novnc docker ps --format '{{.Names}}' | grep -i mqtt"""
            result = subprocess.run(detect_cmd, shell=True, capture_output=True, text=True, timeout=5)
            if result.stdout.strip():
                broker_node = result.stdout.strip().split('\n')[0]

                # Get IP from the container
                ip_cmd = f"docker exec core-novnc docker exec {broker_node} ip -4 addr show eth0 2>/dev/null | grep inet | head -1"
                ip_result = subprocess.run(ip_cmd, shell=True, capture_output=True, text=True, timeout=5)
                if ip_result.stdout.strip():
                    import re
                    match = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', ip_result.stdout)
                    if match:
                        broker_ip = match.group(1)
        except Exception as e:
            return jsonify({'success': False, 'error': f'Auto-detect failed: {e}'}), 500

    if not broker_node or not broker_ip:
        return jsonify({
            'success': False,
            'error': 'Could not detect mqtt-broker. Provide broker_node and broker_ip manually.'
        }), 400

    # Configure and start the embedded injector
    embedded_injector.configure(
        session_id=session_id,
        broker_node=broker_node,
        broker_ip=broker_ip,
        source_node=broker_node
    )
    embedded_injector.start()

    return jsonify({
        'success': True,
        'broker_node': broker_node,
        'broker_ip': broker_ip,
        'session_id': session_id,
        'running': embedded_injector.running
    })


# ============================================================================
# Control Commands (for micro:bit and other actuators)
# ============================================================================

# Store pending control commands per sensor (for polling by microbit.html)
pending_control_commands = {}  # sensor_id -> [list of commands]
import threading
control_lock = threading.Lock()


@app.route('/api/control/<sensor_id>', methods=['POST'])
def send_control_command(sensor_id):
    """Send a control command to a sensor/actuator.

    Commands are stored for polling by the micro:bit page and optionally
    published to MQTT for devices listening on the network.
    """
    data = request.get_json() or {}
    command = data.get('command', '')

    if not command:
        return jsonify({'success': False, 'error': 'No command provided'}), 400

    # Store command for polling
    with control_lock:
        if sensor_id not in pending_control_commands:
            pending_control_commands[sensor_id] = []
        pending_control_commands[sensor_id].append({
            'command': command,
            'timestamp': time.time()
        })
        # Keep only last 10 commands per sensor
        pending_control_commands[sensor_id] = pending_control_commands[sensor_id][-10:]

    # Also publish to MQTT if injector is running
    global embedded_injector
    if embedded_injector.running and embedded_injector.broker_ip:
        topic = f"core/control/{sensor_id}"
        embedded_injector.queue_message(topic, {'command': command})

    return jsonify({
        'success': True,
        'sensor_id': sensor_id,
        'command': command,
        'queued': True
    })


@app.route('/api/control/<sensor_id>/pending', methods=['GET'])
def get_pending_controls(sensor_id):
    """Get pending control commands for a sensor (for polling by micro:bit page)."""
    with control_lock:
        commands = pending_control_commands.get(sensor_id, [])
        # Clear after reading
        pending_control_commands[sensor_id] = []

    return jsonify({
        'sensor_id': sensor_id,
        'commands': commands
    })


@app.route('/api/control/all/pending', methods=['GET'])
def get_all_pending_controls():
    """Get all pending control commands (for debugging/monitoring)."""
    with control_lock:
        all_commands = dict(pending_control_commands)

    return jsonify({
        'pending': all_commands
    })


class VNCWebSocketMiddleware:
    """
    WSGI middleware that intercepts VNC WebSocket requests before Flask handles them.

    This middleware checks if the request is a WebSocket upgrade to /hmi-vnc/<port>/websockify
    and handles it directly using gevent-websocket, bypassing Flask's routing.
    All other requests are passed through to the Flask application.
    """

    def __init__(self, wsgi_app, flask_app):
        self.wsgi_app = wsgi_app
        self.flask_app = flask_app

    def __call__(self, environ, start_response):
        import re

        path = environ.get('PATH_INFO', '')
        ws = environ.get('wsgi.websocket')

        # Check if this is a WebSocket request to our VNC proxy endpoints
        hmi_match = re.match(r'^/hmi-vnc/(\d+)/websockify$', path)
        core_match = (path == '/core-vnc/websockify')

        if hmi_match and ws:
            # Extract port and handle WebSocket proxy for HMI VNC
            port = int(hmi_match.group(1))
            print(f"VNC middleware: handling HMI WebSocket for port {port}", flush=True)

            # Call the VNC proxy handler with the websocket and port
            try:
                vnc_websocket_proxy_handler(ws, port, is_core_vnc=False)
            except Exception as e:
                print(f"VNC middleware error: {e}", flush=True)

            # Return empty response (WebSocket handled)
            return []

        if core_match and ws:
            # Handle main CORE desktop VNC (connects to port 5901)
            print(f"VNC middleware: handling CORE desktop WebSocket", flush=True)

            try:
                vnc_websocket_proxy_handler(ws, 5901, is_core_vnc=True)
            except Exception as e:
                print(f"VNC middleware error (CORE): {e}", flush=True)

            return []

        # Not a VNC WebSocket, pass to Flask
        return self.wsgi_app(environ, start_response)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='CORE MCP Web UI')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind to')
    parser.add_argument('--port', type=int, default=8080, help='Port to bind to')
    args = parser.parse_args()

    # Use gevent with WebSocket support if available for proper VNC proxy
    if GEVENT_AVAILABLE and WEBSOCKET_AVAILABLE:
        try:
            from gevent.pywsgi import WSGIServer
            from geventwebsocket.handler import WebSocketHandler

            print(f"Starting with gevent WebSocket server on {args.host}:{args.port}", flush=True)

            # Wrap Flask app with VNC WebSocket middleware
            vnc_middleware = VNCWebSocketMiddleware(app.wsgi_app, app)
            app.wsgi_app = vnc_middleware

            http_server = WSGIServer((args.host, args.port), app, handler_class=WebSocketHandler)
            http_server.serve_forever()
        except ImportError as e:
            print(f"Warning: gevent-websocket not available ({e}), falling back to Flask dev server")
            print("Install with: pip install gevent-websocket")
            app.run(host=args.host, port=args.port, debug=False)
    else:
        # Fall back to standard Flask development server
        if not GEVENT_AVAILABLE:
            print("Note: gevent not available, WebSocket proxy may not work correctly")
        app.run(host=args.host, port=args.port, debug=False)
