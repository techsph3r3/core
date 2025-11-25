#!/usr/bin/env python3
"""
Start a CORE session and deploy startup scripts automatically.

This script:
1. Starts the CORE session (if not running)
2. Waits for the session to be in RUNTIME state
3. Executes any startup scripts defined for nodes via vcmd

Usage:
    python3 start_and_deploy.py <session_id> [startup_scripts.json]
"""

import sys
import os
import json
import time
import subprocess
from pathlib import Path

# Add CORE to path
sys.path.insert(0, '/opt/core/venv/lib/python3.10/site-packages')

from core.api.grpc import client
from core.api.grpc.wrappers import SessionState


def wait_for_session_runtime(core, session_id, timeout=60):
    """Wait for session to reach RUNTIME state."""
    start_time = time.time()
    while time.time() - start_time < timeout:
        session = core.get_session(session_id)
        if session.state == SessionState.RUNTIME:
            return True
        time.sleep(1)
    return False


def execute_vcmd(session_id: int, node_name: str, command: str) -> tuple:
    """Execute a command on a node via vcmd."""
    vcmd_path = f"/tmp/pycore.{session_id}/{node_name}"

    if not os.path.exists(vcmd_path):
        return False, f"Node socket not found: {vcmd_path}"

    try:
        result = subprocess.run(
            ["vcmd", "-c", vcmd_path, "--", "bash", "-c", command],
            capture_output=True,
            text=True,
            timeout=30
        )
        return True, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, "Command timed out"
    except Exception as e:
        return False, str(e)


def run_startup_script(session_id: int, node_name: str, script_content: str, delay: int = 0):
    """Run a startup script on a node via vcmd."""
    print(f"   Running startup script on {node_name}...")

    if delay > 0:
        print(f"   (delayed by {delay}s)")

    # Write script to temp file on the node
    script_path = f"/tmp/startup_{node_name}.sh"

    # Escape the script content for shell
    escaped_script = script_content.replace("'", "'\"'\"'")

    # Create and run the script
    cmd = f"""
        echo '{escaped_script}' > {script_path}
        chmod +x {script_path}
        nohup {script_path} > /tmp/startup_{node_name}.log 2>&1 &
        echo "Started with PID $!"
    """

    success, output = execute_vcmd(session_id, node_name, cmd)

    if success:
        print(f"   [OK] {node_name}: {output.strip()}")
    else:
        print(f"   [FAIL] {node_name}: {output}")

    return success


def start_session_and_deploy(session_id: int, startup_scripts_file: str = None):
    """Start the CORE session and deploy startup scripts."""
    try:
        # Connect to CORE daemon
        core = client.CoreGrpcClient()
        core.connect()

        # Get session info
        session = core.get_session(session_id)
        if not session:
            print(f"Session {session_id} not found")
            return False

        print(f"Session {session_id}: {session.state}")

        # Start session if not running
        if session.state != SessionState.RUNTIME:
            print(f"Starting session {session_id}...")
            core.start_session(session_id)

            # Wait for runtime state
            if not wait_for_session_runtime(core, session_id, timeout=60):
                print("Timeout waiting for session to start")
                return False

            print("Session started!")

            # Give extra time for Docker containers to initialize
            print("Waiting for containers to initialize...")
            time.sleep(5)

        # Load and execute startup scripts
        if startup_scripts_file and os.path.exists(startup_scripts_file):
            print(f"\nLoading startup scripts from {startup_scripts_file}...")

            with open(startup_scripts_file) as f:
                scripts = json.load(f)

            print(f"Found {len(scripts)} startup scripts")

            # Execute scripts in order (by delay)
            scripts_sorted = sorted(scripts, key=lambda x: x.get('delay_seconds', 0))

            for script_info in scripts_sorted:
                node_name = script_info['node_name']
                script_content = script_info['script_content']
                delay = script_info.get('delay_seconds', 0)

                run_startup_script(session_id, node_name, script_content, delay)

        print("\nDeployment complete!")
        return True

    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 start_and_deploy.py <session_id> [startup_scripts.json]")
        sys.exit(1)

    session_id = int(sys.argv[1])
    scripts_file = sys.argv[2] if len(sys.argv) > 2 else None

    success = start_session_and_deploy(session_id, scripts_file)
    sys.exit(0 if success else 1)
