#!/usr/bin/env python3
"""
Load a CORE XML topology file into a running CORE daemon session.
This makes it appear in the CORE GUI.
"""

import sys
import shutil
from pathlib import Path
from core.api.grpc import client
from core.api.grpc.wrappers import Session


def cleanup_pycore_dirs():
    """Clean up stale /tmp/pycore.* directories that can block session creation."""
    tmp_path = Path('/tmp')
    for item in tmp_path.glob('pycore.*'):
        try:
            shutil.rmtree(item, ignore_errors=True)
            print(f"   Removed stale directory: {item}")
        except Exception as e:
            print(f"   Warning: Could not remove {item}: {e}")


def configure_mqtt_injector():
    """Configure the MQTT injector on the web UI to bridge data to CORE network."""
    import urllib.request
    import json

    # Default mqtt-broker IP in IoT topology
    broker_ip = "10.0.1.10"

    try:
        data = json.dumps({
            "broker_ip": broker_ip,
            "broker_node": "mqtt-broker"
        }).encode('utf-8')

        req = urllib.request.Request(
            'http://localhost:8080/api/inject/configure',
            data=data,
            headers={'Content-Type': 'application/json'},
            method='POST'
        )

        with urllib.request.urlopen(req, timeout=5) as response:
            result = json.loads(response.read().decode())
            if result.get('success'):
                print(f"📡 MQTT Injector configured (broker: {broker_ip})")
            else:
                print(f"   Warning: MQTT Injector config failed: {result}")
    except Exception as e:
        print(f"   Note: MQTT Injector not configured (web UI may not be running): {e}")


def cleanup_docker_containers():
    """Stop and remove CORE-managed Docker containers from previous sessions."""
    import subprocess

    # List of known CORE node container name patterns
    # CORE typically names containers based on node names in the topology
    known_core_containers = [
        'mqtt-broker', 'sensor-server', 'hmi1', 'hmi2', 'hmi3',
        'plc', 'openplc', 'firewall', 'router', 'switch',
        'attacker', 'kali', 'caldera'
    ]

    try:
        # Get list of running containers
        result = subprocess.run(
            ['docker', 'ps', '-a', '--format', '{{.Names}}'],
            capture_output=True, text=True, timeout=10
        )

        if result.returncode != 0:
            print("   Warning: Could not list Docker containers")
            return

        containers = result.stdout.strip().split('\n')
        stopped_count = 0

        for container in containers:
            if not container:
                continue
            # Check if this looks like a CORE-managed container
            # Skip core-novnc as that's the main CORE container
            if container == 'core-novnc':
                continue

            # Check if container name matches known CORE patterns
            is_core_container = any(pattern in container.lower() for pattern in known_core_containers)

            # Also check for CORE-style naming (node names from topology)
            # CORE often uses short names like n1, n2, or node names directly

            if is_core_container:
                try:
                    print(f"   🛑 Stopping container: {container}")
                    subprocess.run(['docker', 'stop', container],
                                   capture_output=True, timeout=10)
                    subprocess.run(['docker', 'rm', container],
                                   capture_output=True, timeout=10)
                    stopped_count += 1
                except Exception as e:
                    print(f"   Warning: Could not stop {container}: {e}")

        if stopped_count > 0:
            print(f"   ✓ Cleaned up {stopped_count} Docker containers")

    except Exception as e:
        print(f"   Warning: Docker cleanup failed: {e}")


def load_topology(xml_file_path):
    """Load XML topology into CORE daemon."""
    try:
        # Connect to CORE daemon
        core = client.CoreGrpcClient()
        core.connect()

        # Delete existing sessions and cleanup Docker containers
        print("🔄 Cleaning up existing sessions and containers...")
        import time

        sessions = core.get_sessions()
        for session in sessions:
            try:
                print(f"   Deleting session {session.id}")
                core.delete_session(session.id)
            except Exception as e:
                print(f"   Warning: Could not delete session {session.id}: {e}")

        # Give CORE extra time to fully clean up (critical for Docker nodes)
        if sessions:
            print("   ⏳ Waiting for CORE to fully clean up...")
            time.sleep(3)  # Increased delay for Docker cleanup

        # Clean up Docker containers from previous CORE sessions
        print("🐳 Cleaning up Docker containers...")
        cleanup_docker_containers()

        # Clean up stale pycore directories (critical fix for "File exists" error)
        cleanup_pycore_dirs()

        # Convert to Path object
        xml_path = Path(xml_file_path)

        if not xml_path.exists():
            print(f"❌ File not found: {xml_file_path}")
            return False

        # Open the XML file without starting (let user click Start manually)
        # This allows CORE to properly set up namespaces after cleanup
        print(f"📂 Loading {xml_file_path}...")
        response = core.open_xml(xml_path, start=False)

        # Response is a tuple: (session_id, session_response)
        if isinstance(response, tuple):
            session_id = response[0]
            session_response = response[1] if len(response) > 1 else None
        else:
            session_id = getattr(response, 'session_id', None)
            session_response = response

        # If we don't have a proper session_id, get the latest session
        if session_id is None or session_id is True:
            sessions = core.get_sessions()
            if sessions:
                session_id = sessions[-1].id  # Get the most recent session

        print(f"✅ Topology loaded from {xml_file_path}")
        print(f"   Session ID: {session_id}")

        # Get node count if available
        if session_response and hasattr(session_response, 'nodes'):
            print(f"   Nodes: {len(session_response.nodes)}")

        print(f"   📺 Topology loaded - click Start button to run!")

        # Launch CORE GUI to display the topology
        print(f"🚀 Launching CORE GUI with session {session_id}...")
        import subprocess
        import os

        # Set DISPLAY for GUI
        env = os.environ.copy()
        env['DISPLAY'] = ':1'

        # Kill any existing core-gui processes
        subprocess.run("pkill -9 core-gui 2>/dev/null", shell=True, env=env)

        # Small delay to ensure clean shutdown
        import time
        time.sleep(0.5)

        # Launch core-gui with session ID to auto-open it
        subprocess.Popen(
            ["core-gui", "-s", str(session_id)],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True
        )

        # Wait a moment for window to appear
        time.sleep(1.5)

        # Maximize the CORE GUI window using wmctrl
        try:
            subprocess.run(
                ["wmctrl", "-r", "CORE", "-b", "add,maximized_vert,maximized_horz"],
                env=env,
                timeout=2,
                capture_output=True
            )
            print(f"✅ CORE GUI launched and maximized!")
        except:
            print(f"✅ CORE GUI launched!")

        print(f"   🎯 Check your noVNC browser tab - topology loaded!")
        print(f"   ▶️  Click the Start button in CORE GUI to run the topology")

        # Auto-configure MQTT injector if mqtt-broker is in topology
        configure_mqtt_injector()

        return True

    except Exception as e:
        print(f"❌ Error loading topology: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 load_topology.py <xml_file>")
        sys.exit(1)

    xml_file = sys.argv[1]
    success = load_topology(xml_file)
    sys.exit(0 if success else 1)
