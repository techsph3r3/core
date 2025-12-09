#!/usr/bin/env python3
"""
CORE Session Event Listener

This daemon listens for CORE session state changes and automatically
sets up VNC proxies when sessions enter RUNTIME_STATE.

Run this alongside the web UI to enable automatic VNC proxy setup
when users click "Start" in the CORE GUI.
"""

import sys
import time
import threading
import urllib.request
import json

from core.api.grpc import client
from core.api.grpc.wrappers import Event, EventType, SessionState


# Session states (from core.emulator.enumerations.EventTypes)
DEFINITION_STATE = 1
CONFIGURATION_STATE = 2
INSTANTIATION_STATE = 3
RUNTIME_STATE = 4
DATACOLLECT_STATE = 5
SHUTDOWN_STATE = 6


def setup_vnc_proxies(session_id: int):
    """
    Set up VNC proxies for all HMI/workstation nodes via the web UI API.
    """
    import subprocess

    print(f"[VNC Setup] Setting up VNC proxies for session {session_id}...")

    # Wait for containers to fully initialize
    time.sleep(5)

    try:
        # Get list of running containers INSIDE core-novnc (Docker-in-Docker)
        result = subprocess.run(
            '''docker exec core-novnc docker ps --format '{{.Names}}\t{{.Image}}' ''',
            shell=True, capture_output=True, text=True, timeout=10
        )

        if result.returncode != 0:
            print("[VNC Setup] Warning: Could not list containers")
            return

        hmi_containers = []
        vnc_patterns = ['hmi', 'workstation', 'desktop', 'kali', 'engineering']
        vnc_images = ['hmi-workstation', 'kali-novnc-core', 'engineering-workstation']

        for line in result.stdout.strip().split('\n'):
            if not line or '\t' not in line:
                continue
            parts = line.split('\t')
            container_name = parts[0]
            image_name = parts[1] if len(parts) > 1 else ''

            # Skip core containers
            if container_name in ['core-novnc', 'core-daemon']:
                continue

            # Check if it's a VNC-capable container
            name_match = any(pattern in container_name.lower() for pattern in vnc_patterns)
            image_match = any(img in image_name.lower() for img in vnc_images)

            if name_match or image_match:
                hmi_containers.append(container_name)

        if not hmi_containers:
            print("[VNC Setup] No HMI/workstation nodes found")
            return

        print(f"[VNC Setup] Found {len(hmi_containers)} VNC-capable nodes: {', '.join(hmi_containers)}")

        # Set up VNC proxy for each container via the web UI API
        successful = 0
        for container in hmi_containers:
            try:
                data = json.dumps({"node_name": container}).encode('utf-8')
                req = urllib.request.Request(
                    'http://localhost:8080/api/start-host-vnc',
                    data=data,
                    headers={'Content-Type': 'application/json'},
                    method='POST'
                )

                with urllib.request.urlopen(req, timeout=15) as response:
                    result = json.loads(response.read().decode())
                    if result.get('success'):
                        port = result.get('proxy_port')
                        print(f"[VNC Setup] VNC proxy for {container} on port {port}")
                        successful += 1
                    else:
                        print(f"[VNC Setup] Failed for {container}: {result.get('error')}")
            except Exception as e:
                print(f"[VNC Setup] Error for {container}: {e}")

        print(f"[VNC Setup] Complete: {successful}/{len(hmi_containers)} proxies set up")

    except Exception as e:
        print(f"[VNC Setup] Error: {e}")


def cleanup_vnc_proxies():
    """
    Clean up VNC proxies when session stops.
    """
    import subprocess

    print("[VNC Cleanup] Cleaning up VNC proxies...")

    try:
        cleanup_cmd = '''docker exec core-novnc bash -c '
            pkill -f "websockify.*608[1-9]" 2>/dev/null || true
            pkill -f "socat.*TCP-LISTEN:160" 2>/dev/null || true
            pkill -f "socat.*TCP-LISTEN:608" 2>/dev/null || true
            rm -f /tmp/ns_forward_*.sh 2>/dev/null || true
            rm -f /tmp/socat_*.log 2>/dev/null || true
            rm -f /tmp/websockify_*.log 2>/dev/null || true
            echo "VNC proxies cleaned"
        ' '''
        subprocess.run(cleanup_cmd, shell=True, capture_output=True, timeout=10)
        print("[VNC Cleanup] Complete")
    except Exception as e:
        print(f"[VNC Cleanup] Error: {e}")


def handle_event(event: Event):
    """
    Handle CORE session events.
    """
    if event.session_event:
        session_id = event.session_event.session_id
        state = event.session_event.state

        state_name = {
            DEFINITION_STATE: "DEFINITION",
            CONFIGURATION_STATE: "CONFIGURATION",
            INSTANTIATION_STATE: "INSTANTIATION",
            RUNTIME_STATE: "RUNTIME",
            DATACOLLECT_STATE: "DATACOLLECT",
            SHUTDOWN_STATE: "SHUTDOWN",
        }.get(state, f"UNKNOWN({state})")

        print(f"[Event] Session {session_id} -> {state_name}")

        if state == RUNTIME_STATE:
            # Session started - set up VNC proxies in a separate thread
            threading.Thread(
                target=setup_vnc_proxies,
                args=(session_id,),
                daemon=True
            ).start()

        elif state == SHUTDOWN_STATE:
            # Session stopped - clean up VNC proxies
            threading.Thread(
                target=cleanup_vnc_proxies,
                daemon=True
            ).start()


def listen_to_session(session_id: int):
    """
    Subscribe to events for a specific session.
    """
    try:
        core = client.CoreGrpcClient()
        core.connect()

        print(f"[Listener] Subscribed to session {session_id} events")

        # Listen for session events
        stream = core.events(session_id, handle_event)

        # Keep the stream alive
        while True:
            time.sleep(1)

    except Exception as e:
        print(f"[Listener] Error for session {session_id}: {e}")


def monitor_sessions():
    """
    Monitor for new sessions and subscribe to their events.
    """
    known_sessions = set()

    while True:
        try:
            core = client.CoreGrpcClient()
            core.connect()

            sessions = core.get_sessions()
            current_sessions = {s.id for s in sessions}

            # Find new sessions
            new_sessions = current_sessions - known_sessions
            for session_id in new_sessions:
                print(f"[Monitor] New session detected: {session_id}")
                # Start listener thread for new session
                threading.Thread(
                    target=listen_to_session,
                    args=(session_id,),
                    daemon=True
                ).start()

            # Find removed sessions
            removed_sessions = known_sessions - current_sessions
            for session_id in removed_sessions:
                print(f"[Monitor] Session removed: {session_id}")

            known_sessions = current_sessions

        except Exception as e:
            print(f"[Monitor] Error: {e}")

        time.sleep(2)


def main():
    print("=" * 60)
    print("CORE Session Event Listener")
    print("Automatically sets up VNC proxies when sessions start")
    print("=" * 60)

    # Start the session monitor
    try:
        monitor_sessions()
    except KeyboardInterrupt:
        print("\n[Listener] Shutting down...")


if __name__ == '__main__':
    main()
