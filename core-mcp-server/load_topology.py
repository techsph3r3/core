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


def cleanup_vnc_proxies():
    """
    Clean up stale VNC proxy chains from previous sessions.

    The VNC proxy uses a two-layer architecture:
    - Layer 1: websockify on external ports (6081-6083) - handles WebSocket protocol
    - Layer 2: socat on internal ports (16081-16083) - bridges to container namespace

    These proxies use nsenter to bridge into CORE container network namespaces.
    When a session ends, the PIDs they point to no longer exist, causing hangs.

    IMPORTANT: Only cleans up HMI proxies (6081+), NOT main VNC on 6080.
    NOTE: This runs INSIDE core-novnc container, so we run commands directly (no docker exec).
    """
    import subprocess

    print("   [DEBUG] cleanup_vnc_proxies() starting...")
    print("   [DEBUG] Running directly inside container (no docker exec)")

    try:
        # Show before state
        print("   [DEBUG] Before cleanup - websockify processes:")
        result = subprocess.run("ps aux | grep websockify | grep -v grep", shell=True, capture_output=True, text=True)
        print(f"   {result.stdout.strip() or '(none)'}")

        print("   [DEBUG] Before cleanup - socat processes:")
        result = subprocess.run("ps aux | grep socat | grep -v grep", shell=True, capture_output=True, text=True)
        print(f"   {result.stdout.strip() or '(none)'}")

        print("   [DEBUG] Before cleanup - listening ports:")
        result = subprocess.run("ss -tlnp | grep -E '590|608'", shell=True, capture_output=True, text=True)
        print(f"   {result.stdout.strip() or '(none)'}")

        # Kill websockify HMI proxies (ports 6081-6089, NOT 6080 which is main VNC)
        # Use very specific pattern: must have space before port number to avoid partial matches
        print("   [DEBUG] Killing websockify on ports 6081-6089 (NOT 6080)...")
        subprocess.run("pkill -f 'websockify.* 608[1-9]' 2>/dev/null", shell=True, capture_output=True, timeout=5)

        # Kill socat internal proxies (ports 160XX)
        print("   [DEBUG] Killing socat on ports 160XX...")
        subprocess.run("pkill -f 'socat.*TCP-LISTEN:160' 2>/dev/null", shell=True, capture_output=True, timeout=5)

        # Kill socat proxies on 6081-6089 directly
        print("   [DEBUG] Killing socat on ports 6081-6089...")
        subprocess.run("pkill -f 'socat.*TCP-LISTEN:608[1-9]' 2>/dev/null", shell=True, capture_output=True, timeout=5)

        # Remove wrapper scripts
        subprocess.run("rm -f /tmp/ns_forward_*.sh 2>/dev/null", shell=True, capture_output=True, timeout=5)

        # Clean up log files
        subprocess.run("rm -f /tmp/socat_*.log 2>/dev/null", shell=True, capture_output=True, timeout=5)
        subprocess.run("rm -f /tmp/websockify_*.log 2>/dev/null", shell=True, capture_output=True, timeout=5)

        # Show after state
        print("   [DEBUG] After cleanup - websockify processes:")
        result = subprocess.run("ps aux | grep websockify | grep -v grep", shell=True, capture_output=True, text=True)
        print(f"   {result.stdout.strip() or '(none)'}")

        print("   [DEBUG] After cleanup - listening ports:")
        result = subprocess.run("ss -tlnp | grep -E '590|608'", shell=True, capture_output=True, text=True)
        print(f"   {result.stdout.strip() or '(none)'}")

        print("   ✓ VNC proxy cleanup completed")

    except Exception as e:
        import traceback
        print(f"   [ERROR] VNC proxy cleanup failed: {e}")
        traceback.print_exc()


def cleanup_docker_containers():
    """
    Stop and remove CORE-managed Docker containers from previous sessions.

    IMPORTANT: This script runs INSIDE core-novnc, but the Docker socket
    (/var/run/docker.sock) is mounted from the HOST. This means 'docker' commands
    operate on the HOST Docker daemon, not a Docker-in-Docker setup!

    CORE creates its Docker node containers INSIDE core-novnc's namespace,
    so we cannot clean them up via the host Docker. The CORE gRPC session
    cleanup (via core.delete_session) handles this properly.

    This function is now a no-op since container cleanup is handled by CORE itself.
    """
    import subprocess

    print("   [DEBUG] cleanup_docker_containers() - SKIPPING")
    print("   [DEBUG] Docker socket is mounted from host, not Docker-in-Docker")
    print("   [DEBUG] CORE session cleanup handles container removal via gRPC")

    # Log what containers exist on the HOST for debugging
    try:
        result = subprocess.run(
            ['docker', 'ps', '-a', '--format', '{{.Names}}'],
            capture_output=True, text=True, timeout=10
        )
        print(f"   [DEBUG] HOST containers: {result.stdout.strip()}")
    except Exception as e:
        print(f"   [DEBUG] Could not list containers: {e}")

    print("   ✓ Docker cleanup skipped (handled by CORE gRPC)")


def cleanup_core_interfaces():
    """
    Clean up stale CORE virtual interfaces (veth pairs, bridges).

    These can persist after session cleanup and cause conflicts.
    """
    import subprocess

    try:
        # Find and delete CORE-created interfaces
        # CORE creates interfaces with patterns like: veth*, b.*, core*
        result = subprocess.run(
            "ip link show 2>/dev/null | grep -E 'veth|^b\\.|core' | awk -F: '{print $2}' | tr -d ' '",
            shell=True, capture_output=True, text=True, timeout=10
        )

        interfaces = [iface.strip() for iface in result.stdout.strip().split('\n') if iface.strip()]

        for iface in interfaces:
            # Skip certain interfaces
            if iface.startswith('br-') or iface == 'bridge':
                continue
            try:
                subprocess.run(
                    f"sudo ip link delete {iface} 2>/dev/null",
                    shell=True, capture_output=True, timeout=5
                )
            except:
                pass

        if interfaces:
            print(f"   ✓ Cleaned up {len(interfaces)} network interfaces")
    except Exception as e:
        print(f"   Warning: Interface cleanup failed: {e}")


def full_cleanup():
    """
    Perform complete cleanup of all CORE-related resources.

    Call this before starting a new session to ensure clean state.
    """
    print("🧹 Full cleanup starting...")

    # 1. Clean VNC proxies first (they hold connections to containers)
    print("   📺 Cleaning VNC proxies...")
    cleanup_vnc_proxies()

    # 2. Clean Docker containers
    print("   🐳 Cleaning Docker containers...")
    cleanup_docker_containers()

    # 3. Clean stale pycore directories
    print("   📁 Cleaning pycore directories...")
    cleanup_pycore_dirs()

    # 4. Clean network interfaces (optional, can cause issues)
    # cleanup_core_interfaces()

    print("🧹 Full cleanup complete!")


def setup_vnc_proxies_for_hmi_nodes(session_id=None):
    """
    Set up VNC socat proxies for all HMI/workstation nodes after session starts.

    NOTE: This function is now a no-op. VNC proxy setup is handled by the web UI
    via /api/start-host-vnc endpoint, which has proper access to query CORE containers.

    This script runs INSIDE core-novnc, but the Docker socket is mounted from the HOST.
    CORE Docker nodes are created in core-novnc's namespace and are not visible via
    the host Docker socket. The web UI handles this correctly.

    Args:
        session_id: Session ID (unused, kept for backward compatibility)
    """
    _ = session_id  # Explicitly mark as unused

    print("📺 VNC proxy setup...")
    print("   [DEBUG] Delegated to web UI API (/api/start-host-vnc)")
    print("   [DEBUG] (CORE Docker nodes are in core-novnc namespace, not host Docker)")
    print("   ✓ VNC proxy setup will be handled by web UI")


def load_topology(xml_file_path):
    """Load XML topology into CORE daemon."""
    try:
        # Connect to CORE daemon
        core = client.CoreGrpcClient()
        core.connect()

        # Delete existing sessions
        print("🔄 Cleaning up existing CORE sessions...")
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
            time.sleep(3)

        # Perform full cleanup (VNC proxies, Docker containers, pycore dirs)
        full_cleanup()

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

        # Check if core-gui is already running
        gui_check = subprocess.run("pgrep -x core-gui", shell=True, capture_output=True)
        gui_running = gui_check.returncode == 0

        if gui_running:
            # GUI is running - it will auto-refresh when session changes
            # Don't kill it as that disrupts the VNC display
            print("   CORE GUI already running - will auto-connect to new session")
        else:
            # No GUI running - launch it with session ID
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
        print(f"   📺 Topology loaded - click Start button to run!")

        # Auto-configure MQTT injector if mqtt-broker is in topology
        configure_mqtt_injector()

        return session_id  # Return session_id for chaining

    except Exception as e:
        print(f"❌ Error loading topology: {e}")
        import traceback
        traceback.print_exc()
        return False


def start_session_and_setup_vnc(session_id):
    """
    Start a CORE session and set up VNC proxies for HMI nodes.

    This should be called after load_topology() when you want auto-start.
    """
    import time

    try:
        core = client.CoreGrpcClient()
        core.connect()

        # Get session object (required for start_session API)
        session = core.get_session(session_id)

        print(f"▶️  Starting session {session_id}...")
        result = core.start_session(session)

        if result[0]:  # Success
            print(f"✅ Session {session_id} started successfully!")

            # Wait for containers to fully initialize
            print("   ⏳ Waiting for containers to initialize...")
            time.sleep(5)

            # The CORE GUI should auto-refresh when session state changes
            # Don't kill/restart it as that disrupts the VNC display
            print("   ✅ Session started - CORE GUI will auto-refresh")

            # Set up VNC proxies for HMI nodes
            setup_vnc_proxies_for_hmi_nodes(session_id)

            # Configure MQTT injector
            configure_mqtt_injector()

            return True
        else:
            print(f"❌ Failed to start session: {result[1]}")
            return False

    except Exception as e:
        print(f"❌ Error starting session: {e}")
        import traceback
        traceback.print_exc()
        return False


def wait_for_session_runtime(core, session_id, timeout=60):
    """Wait for session to reach RUNTIME state."""
    from core.api.grpc.wrappers import SessionState
    import time

    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            session = core.get_session(session_id)
            if session.state == SessionState.RUNTIME:
                return True
        except:
            pass
        time.sleep(1)
    return False


def load_and_start(xml_file_path):
    """
    Complete workflow: Load topology and start session.

    IMPORTANT: The main noVNC session (port 6080 → Xtigervnc 5901) must stay
    connected throughout. Only clean up:
    - CORE sessions (via gRPC API)
    - HMI VNC proxies (socat/websockify on ports 6081+)
    - Docker containers inside CORE
    - core-gui process

    DO NOT restart core-daemon or run core-cleanup as these can kill VNC.
    """
    import subprocess
    import os
    import time

    print("=" * 60)
    print("[DEBUG] load_and_start() called")
    print(f"[DEBUG] xml_file_path: {xml_file_path}")
    print("=" * 60)

    xml_path = Path(xml_file_path)
    if not xml_path.exists():
        print(f"❌ File not found: {xml_file_path}")
        return False

    print("🔄 Preparing to load topology...")

    # Check VNC state before we do anything
    print("[DEBUG] Checking VNC state before cleanup...")
    vnc_check = subprocess.run(
        "ps aux | grep -E 'Xtigervnc|websockify.*6080' | grep -v grep",
        shell=True, capture_output=True, text=True
    )
    print(f"[DEBUG] VNC processes before:\n{vnc_check.stdout}")

    # Set DISPLAY for GUI
    env = os.environ.copy()
    env['DISPLAY'] = ':1'

    # Step 1: Delete existing CORE sessions via gRPC (NOT daemon restart)
    # This preserves VNC while cleaning up CORE sessions
    print("   Step 1: Cleaning up existing CORE sessions via gRPC...")
    try:
        core = client.CoreGrpcClient()
        core.connect()
        sessions = core.get_sessions()
        print(f"   [DEBUG] Found {len(sessions)} existing sessions")
        for session in sessions:
            try:
                print(f"   [DEBUG] Deleting session {session.id}")
                core.delete_session(session.id)
            except Exception as e:
                print(f"   [ERROR] Could not delete session {session.id}: {e}")
        if sessions:
            print("   [DEBUG] Waiting 2s for CORE cleanup...")
            time.sleep(2)
    except Exception as e:
        import traceback
        print(f"   [ERROR] Could not clean sessions: {e}")
        traceback.print_exc()

    # Check VNC state after session cleanup
    print("[DEBUG] Checking VNC state after session cleanup...")
    vnc_check = subprocess.run(
        "ps aux | grep -E 'Xtigervnc|websockify.*6080' | grep -v grep",
        shell=True, capture_output=True, text=True
    )
    print(f"[DEBUG] VNC processes after session cleanup:\n{vnc_check.stdout}")

    # Step 2: Clean up HMI VNC proxies (6081+) but NOT main VNC (6080)
    print("   Step 2: Cleaning up HMI VNC proxies...")
    cleanup_vnc_proxies()

    # Check VNC state after VNC proxy cleanup
    print("[DEBUG] Checking VNC state after VNC proxy cleanup...")
    vnc_check = subprocess.run(
        "ps aux | grep -E 'Xtigervnc|websockify.*6080' | grep -v grep",
        shell=True, capture_output=True, text=True
    )
    print(f"[DEBUG] VNC processes after VNC proxy cleanup:\n{vnc_check.stdout}")

    # Step 3: Clean up Docker containers and pycore dirs
    print("   Step 3: Cleaning up Docker containers...")
    cleanup_docker_containers()
    cleanup_pycore_dirs()

    # Check VNC state after Docker cleanup
    print("[DEBUG] Checking VNC state after Docker cleanup...")
    vnc_check = subprocess.run(
        "ps aux | grep -E 'Xtigervnc|websockify.*6080' | grep -v grep",
        shell=True, capture_output=True, text=True
    )
    print(f"[DEBUG] VNC processes after Docker cleanup:\n{vnc_check.stdout}")

    # Step 4: Kill existing core-gui only (NOT VNC processes)
    print("   Step 4: Closing existing CORE GUI...")
    subprocess.run("pkill -9 core-gui", shell=True, capture_output=True)
    time.sleep(1)

    # Check VNC state after core-gui kill
    print("[DEBUG] Checking VNC state after core-gui kill...")
    vnc_check = subprocess.run(
        "ps aux | grep -E 'Xtigervnc|websockify.*6080' | grep -v grep",
        shell=True, capture_output=True, text=True
    )
    print(f"[DEBUG] VNC processes after core-gui kill:\n{vnc_check.stdout}")

    # Step 5: Load XML and Start Session via gRPC
    print(f"   Step 5: Loading XML and starting session via gRPC...")
    try:
        core = client.CoreGrpcClient()
        core.connect()
        
        # Parse session_id from response
        # open_xml(xml_path, start=True) returns (session_id, result) or result object
        # WARNING: result might just be boolean True in some versions
        response = core.open_xml(xml_path, start=True)
        
        session_id = None
        
        # Handle tuple response
        if isinstance(response, tuple):
            if isinstance(response[0], int):
                session_id = response[0]
                
        # Handle object response
        elif hasattr(response, 'session_id'):
            session_id = response.session_id
            
        # Fallback: Start=True sometimes returns just True or an object without ID
        # If we didn't get a valid INT id, fetch the latest session from daemon
        # NOTE: isinstance(True, int) is True in Python! Must check type or exclude bool explicitly.
        if session_id is None or isinstance(session_id, bool) or not isinstance(session_id, int):
            print(f"   [DEBUG] Invalid Session ID from response ({session_id}), querying daemon...")
            sessions = core.get_sessions()
            if sessions:
                # Get the session with the highest ID (most likely the new one)
                sessions.sort(key=lambda x: x.id)
                session_id = sessions[-1].id
                
        print(f"   ✅ Session created with ID: {session_id}")
        
    except Exception as e:
        print(f"   ❌ Failed to load XML via gRPC: {e}")
        import traceback
        traceback.print_exc()
        return False

    # Step 6: Launch core-gui attached to the session
    print(f"   Step 6: Launching CORE GUI for session {session_id}...")
    
    # Open log file for GUI output
    gui_log = open('/var/log/core-gui.log', 'a')
    gui_log.write(f"\n--- Launching CORE GUI for session {session_id} ---\n")
    
    proc = subprocess.Popen(
        ["core-gui", "-s", str(session_id)],
        env=env,
        stdout=gui_log,
        stderr=gui_log,
        start_new_session=True
    )
    
    # Give it a moment and check if it died
    time.sleep(1)
    if proc.poll() is not None:
        print(f"   ❌ CORE GUI failed to start! Return code: {proc.returncode}")
        print("   Checking logs...")
        subprocess.run("tail -n 10 /var/log/core-gui.log", shell=True)
    else:
        print(f"   CORE GUI started with PID {proc.pid}")

    # Step 5: Wait for session to reach RUNTIME state (from start_and_deploy.py)
    print("   ⏳ Waiting for session to reach RUNTIME state...")
    time.sleep(3)  # Initial wait for GUI to start loading

    try:
        core = client.CoreGrpcClient()
        core.connect()

        # Find the session
        session_id = None
        for _ in range(10):  # Try for up to 10 seconds to find session
            sessions = core.get_sessions()
            if sessions:
                session_id = sessions[-1].id
                break
            time.sleep(1)

        if session_id:
            print(f"   Session ID: {session_id}")

            # Wait for RUNTIME state (timeout 60s)
            if wait_for_session_runtime(core, session_id, timeout=60):
                print(f"✅ Session {session_id} is now RUNTIME!")

                # Maximize the GUI window
                print("   Running window maximization loop...")
                for _ in range(5):
                    try:
                        # Check if window exists
                        result = subprocess.run(
                            ["wmctrl", "-l"], 
                            env=env, capture_output=True, text=True
                        )
                        if "CORE" in result.stdout:
                            # Maximize it
                            subprocess.run(
                                ["wmctrl", "-r", "CORE", "-b", "add,maximized_vert,maximized_horz"],
                                env=env, timeout=2, capture_output=True
                            )
                            print("   ✅ Window maximized.")
                            break
                    except Exception as e:
                        print(f"   [WARN] Maximization failed: {e}")
                    time.sleep(1)

                # Set up VNC proxies for HMI nodes
                setup_vnc_proxies_for_hmi_nodes(session_id)

                # Configure MQTT injector
                configure_mqtt_injector()

                print(f"✅ Topology loaded and running!")
                print(f"   🎯 Check your noVNC browser tab!")
                return True
            else:
                print("   ⚠ Timeout waiting for RUNTIME state")
                print("   Session may still be starting - check the GUI")
                return True  # Still return True, session exists
        else:
            print("   ⚠ Could not find session")
            return False

    except Exception as e:
        print(f"   Warning: Error during session setup: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Load CORE topology from XML file')
    parser.add_argument('xml_file', nargs='?', help='Path to XML topology file')
    parser.add_argument('--start', '-s', action='store_true',
                        help='Auto-start the session after loading')
    parser.add_argument('--cleanup-only', action='store_true',
                        help='Only perform cleanup, do not load topology')

    args = parser.parse_args()

    if args.cleanup_only:
        print("🧹 Cleanup-only mode")
        full_cleanup()
        sys.exit(0)

    if not args.xml_file:
        parser.error("xml_file is required unless using --cleanup-only")

    if args.start:
        # Load and auto-start
        success = load_and_start(args.xml_file)
    else:
        # Just load (manual start)
        success = load_topology(args.xml_file)

    sys.exit(0 if success else 1)
