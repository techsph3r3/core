#!/usr/bin/env python3
"""
VNC/HMI Workstation Diagnostics and Repair Tool

This tool diagnoses and fixes common issues with VNC proxy connections
to HMI workstations running inside CORE network emulation.

Usage:
    python3 vnc_diagnostics.py diagnose     # Run full diagnostics
    python3 vnc_diagnostics.py repair       # Attempt automatic repair
    python3 vnc_diagnostics.py cleanup      # Force cleanup all proxies
    python3 vnc_diagnostics.py setup <node> # Setup VNC for specific node
"""

import subprocess
import sys
import time
import json
import re


def run_cmd(cmd, timeout=10, check=False):
    """Run a shell command and return (success, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, timeout=timeout
        )
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)


def docker_exec(cmd, timeout=10):
    """Execute command inside core-novnc container."""
    return run_cmd(f'docker exec core-novnc bash -c "{cmd}"', timeout=timeout)


def docker_exec_hmi(container, cmd, timeout=10):
    """Execute command inside an HMI container (via core-novnc DinD)."""
    # Use single quotes for outer command to avoid escaping issues
    full_cmd = f"docker exec core-novnc docker exec {container} bash -c '{cmd}'"
    return run_cmd(full_cmd, timeout=timeout)


class VNCDiagnostics:
    """Diagnostic tool for VNC proxy issues."""

    def __init__(self):
        self.issues = []
        self.warnings = []
        self.info = []

    def log_issue(self, msg):
        self.issues.append(f"❌ {msg}")
        print(f"❌ ISSUE: {msg}")

    def log_warning(self, msg):
        self.warnings.append(f"⚠️  {msg}")
        print(f"⚠️  WARNING: {msg}")

    def log_ok(self, msg):
        self.info.append(f"✅ {msg}")
        print(f"✅ {msg}")

    def log_info(self, msg):
        self.info.append(f"ℹ️  {msg}")
        print(f"ℹ️  {msg}")

    def check_core_novnc_running(self):
        """Check if core-novnc container is running."""
        print("\n=== Checking core-novnc container ===")
        success, out, err = run_cmd("docker ps --format '{{.Names}}' | grep core-novnc")
        if success and "core-novnc" in out:
            self.log_ok("core-novnc container is running")
            return True
        else:
            self.log_issue("core-novnc container is NOT running")
            return False

    def get_hmi_containers(self):
        """Get list of HMI/workstation containers."""
        print("\n=== Finding HMI containers ===")
        success, out, err = docker_exec("docker ps --format '{{.Names}}\\t{{.Image}}'")

        if not success:
            self.log_issue(f"Cannot list containers: {err}")
            return []

        hmi_containers = []
        vnc_patterns = ['hmi', 'workstation', 'desktop', 'kali', 'engineering']

        for line in out.split('\n'):
            if not line or '\t' not in line:
                continue
            name, image = line.split('\t', 1)
            if name == 'core-novnc':
                continue
            if any(p in name.lower() or p in image.lower() for p in vnc_patterns):
                hmi_containers.append({'name': name, 'image': image})
                self.log_info(f"Found HMI container: {name} ({image})")

        if not hmi_containers:
            self.log_warning("No HMI/workstation containers found")

        return hmi_containers

    def check_vnc_services(self, container_name):
        """Check if VNC services are running inside a container."""
        print(f"\n=== Checking VNC services in {container_name} ===")

        # Use pgrep -f for all services since they're python scripts
        services = {
            'supervisord': 'pgrep -f supervisord',
            'Xvfb': 'pgrep -f Xvfb',
            'x11vnc': 'pgrep -f x11vnc',
            'websockify': 'pgrep -f websockify'
        }

        all_running = True
        for service, cmd in services.items():
            success, out, err = docker_exec_hmi(container_name, cmd)
            if success and out:
                self.log_ok(f"{service}: running (PID {out.split()[0]})")
            else:
                self.log_issue(f"{service}: NOT running in {container_name}")
                all_running = False

        # Check ports - use netstat or ss
        success, out, err = docker_exec_hmi(container_name, "ss -tln 2>/dev/null || netstat -tln 2>/dev/null")
        has_6080 = ':6080' in out
        has_5900 = ':5900' in out
        if has_6080 and has_5900:
            self.log_ok("VNC ports 5900 and 6080 are listening")
        else:
            missing = []
            if not has_5900:
                missing.append("5900")
            if not has_6080:
                missing.append("6080")
            self.log_issue(f"VNC ports not listening: {', '.join(missing)}")
            all_running = False

        return all_running

    def get_proxy_state(self):
        """Get current state of VNC two-layer proxy chains.

        The proxy chain is: websockify:608X -> socat:1608X -> nsenter -> container:6080
        """
        print("\n=== Checking VNC proxy state (two-layer chain) ===")

        proxies = {}

        # Check websockify processes on external ports (6081-6083)
        success, out, err = docker_exec("pgrep -af 'websockify.*608[1-3]'")
        if success and out:
            for line in out.split('\n'):
                match = re.search(r'websockify.*?(\d{4})', line)
                if match:
                    port = int(match.group(1))
                    if 6081 <= port <= 6083:
                        proxies[port] = {'websockify_running': True, 'websockify_line': line}

        # Check socat processes on internal ports (16081-16083)
        success, out, err = docker_exec("pgrep -af 'socat.*TCP-LISTEN:1608[1-3]'")
        if success and out:
            for line in out.split('\n'):
                match = re.search(r'TCP-LISTEN:(\d+)', line)
                if match:
                    internal_port = int(match.group(1))
                    external_port = internal_port - 10000  # 16081 -> 6081
                    if external_port not in proxies:
                        proxies[external_port] = {}
                    proxies[external_port]['socat_running'] = True
                    proxies[external_port]['internal_port'] = internal_port
                    proxies[external_port]['socat_line'] = line

        # Check wrapper scripts (named by external port, not internal)
        for port in range(6081, 6084):
            internal_port = 10000 + port
            script = f"/tmp/ns_forward_{port}.sh"
            success, out, err = docker_exec(f"cat {script} 2>/dev/null")

            if port not in proxies:
                proxies[port] = {'websockify_running': False, 'socat_running': False}

            if success and out:
                proxies[port]['script_exists'] = True
                proxies[port]['script_content'] = out

                # Extract PID from script
                pid_match = re.search(r'nsenter.*-t (\d+)', out)
                if pid_match:
                    pid = pid_match.group(1)
                    proxies[port]['target_pid'] = pid

                    # Check if PID is valid
                    success, _, _ = docker_exec(f"kill -0 {pid} 2>/dev/null")
                    proxies[port]['pid_valid'] = success
            else:
                proxies[port]['script_exists'] = False

        # Report findings
        for port, state in sorted(proxies.items()):
            ws_ok = state.get('websockify_running', False)
            socat_ok = state.get('socat_running', False)
            pid_ok = state.get('pid_valid', False)
            pid = state.get('target_pid', 'N/A')

            if ws_ok and socat_ok and pid_ok:
                self.log_ok(f"Port {port}: full chain OK (websockify -> socat:{10000+port} -> PID {pid})")
            elif ws_ok and socat_ok and not pid_ok:
                self.log_issue(f"Port {port}: chain running but PID {pid} is STALE")
            elif ws_ok and not socat_ok:
                self.log_issue(f"Port {port}: websockify running but socat not running")
            elif not ws_ok and socat_ok:
                self.log_issue(f"Port {port}: socat running but websockify not running")
            elif state.get('script_exists'):
                self.log_warning(f"Port {port}: wrapper script exists but proxy not running")
            else:
                self.log_info(f"Port {port}: free (no proxy)")

        return proxies

    def check_nsenter_access(self, pid):
        """Verify nsenter can access a PID's network namespace."""
        success, out, err = docker_exec(f"nsenter -t {pid} -n ss -tln 2>&1 | head -3")
        return success and 'LISTEN' in out

    def diagnose(self):
        """Run full diagnostics."""
        print("=" * 60)
        print("VNC/HMI Workstation Diagnostics")
        print("=" * 60)

        # Check core-novnc
        if not self.check_core_novnc_running():
            print("\n⛔ Cannot proceed - core-novnc not running")
            return False

        # Find HMI containers
        hmi_containers = self.get_hmi_containers()

        # Check VNC services in each container
        for container in hmi_containers:
            self.check_vnc_services(container['name'])

        # Check proxy state
        proxies = self.get_proxy_state()

        # Summary
        print("\n" + "=" * 60)
        print("DIAGNOSTIC SUMMARY")
        print("=" * 60)

        if self.issues:
            print(f"\n{len(self.issues)} Issues found:")
            for issue in self.issues:
                print(f"  {issue}")
        else:
            print("\n✅ No critical issues found")

        if self.warnings:
            print(f"\n{len(self.warnings)} Warnings:")
            for warning in self.warnings:
                print(f"  {warning}")

        return len(self.issues) == 0

    def cleanup_all_proxies(self):
        """Force cleanup all VNC proxy chains (both websockify and socat layers)."""
        print("\n=== Force cleaning all VNC proxy chains ===")

        cmd = '''
            # Kill websockify HMI proxies (ports 6081-6089, NOT 6080 which is main VNC)
            pkill -f "websockify.*608[1-9]" 2>/dev/null || true

            # Kill socat internal proxies (ports 160XX)
            pkill -f "socat.*TCP-LISTEN:160" 2>/dev/null || true

            # Kill old-style socat proxies on 608X directly (legacy cleanup)
            pkill -f "socat.*TCP-LISTEN:608" 2>/dev/null || true

            # Remove ALL wrapper scripts
            rm -f /tmp/ns_forward_*.sh 2>/dev/null || true

            # Clean up log files
            rm -f /tmp/socat_*.log 2>/dev/null || true
            rm -f /tmp/websockify_*.log 2>/dev/null || true

            echo "Cleanup complete"
        '''

        success, out, err = docker_exec(cmd)
        if success:
            self.log_ok("All VNC proxy chains cleaned up")
        else:
            self.log_issue(f"Cleanup failed: {err}")

        return success

    def start_vnc_in_container(self, container_name):
        """Start VNC services inside an HMI container."""
        print(f"\n=== Starting VNC services in {container_name} ===")

        # Check if already running (use -f to match python script)
        success, out, err = docker_exec_hmi(container_name, "pgrep -f supervisord")
        if success and out:
            self.log_info("supervisord already running, checking if services are healthy...")
            # Check if websockify is running (indicates full stack is up)
            success2, out2, _ = docker_exec_hmi(container_name, "pgrep -f websockify")
            if success2 and out2:
                self.log_ok("VNC services already running and healthy")
                return True
            else:
                self.log_warning("supervisord running but services died, restarting...")
                docker_exec_hmi(container_name, "pkill -f supervisord; sleep 2")

        # Start supervisord
        cmd = '''
            supervisord -c /etc/supervisor/conf.d/desktop.conf &
            sleep 5

            # Verify all services started
            for svc in supervisord Xvfb x11vnc; do
                pgrep -x $svc > /dev/null || echo "FAILED: $svc not running"
            done
            pgrep -f websockify > /dev/null || echo "FAILED: websockify not running"

            # Verify ports
            ss -tln | grep -q :6080 || echo "FAILED: port 6080 not listening"
            ss -tln | grep -q :5900 || echo "FAILED: port 5900 not listening"

            echo "VNC startup complete"
        '''

        success, out, err = docker_exec_hmi(container_name, cmd, timeout=20)

        if 'FAILED' in out:
            self.log_issue(f"VNC startup issues: {out}")
            return False
        else:
            self.log_ok(f"VNC services started in {container_name}")
            return True

    def setup_proxy_for_container(self, container_name):
        """Set up socat proxy for a specific container."""
        print(f"\n=== Setting up VNC proxy for {container_name} ===")

        # Get container PID
        success, out, err = docker_exec(f"docker inspect {container_name} --format '{{{{.State.Pid}}}}'")
        if not success or not out or out == '0':
            self.log_issue(f"Cannot get PID for {container_name}")
            return None

        container_pid = out.strip()
        self.log_info(f"Container PID: {container_pid}")

        # Verify nsenter works
        if not self.check_nsenter_access(container_pid):
            self.log_issue(f"Cannot access network namespace of PID {container_pid}")
            return None

        self.log_ok("nsenter access verified")

        # Find available port
        available_port = None
        for port in range(6081, 6084):
            success, out, err = docker_exec(f"ss -tln | grep :{port}")
            if not success:  # Port not in use
                available_port = port
                break

        if not available_port:
            self.log_issue("No available proxy ports (6081-6083 all in use)")
            return None

        self.log_info(f"Using port {available_port}")

        # Clean up any existing proxy on this port
        docker_exec(f"pkill -f 'socat.*{available_port}.*ns_forward' 2>/dev/null || true")
        docker_exec(f"rm -f /tmp/ns_forward_{available_port}.sh 2>/dev/null || true")
        time.sleep(0.5)

        # Create wrapper script
        wrapper_script = f"/tmp/ns_forward_{available_port}.sh"
        create_cmd = f'''echo '#!/bin/bash
exec nsenter -t {container_pid} -n socat STDIO TCP:localhost:6080' > {wrapper_script} && chmod +x {wrapper_script}'''

        success, out, err = docker_exec(create_cmd)
        if not success:
            self.log_issue(f"Failed to create wrapper script: {err}")
            return None

        # Start socat proxy
        proxy_cmd = f"nohup socat TCP-LISTEN:{available_port},fork,reuseaddr EXEC:{wrapper_script} > /tmp/socat_{available_port}.log 2>&1 &"
        success, out, err = docker_exec(proxy_cmd)

        time.sleep(1)

        # Verify socat started
        success, out, err = docker_exec(f"pgrep -f 'socat.*{available_port}'")
        if not success:
            self.log_issue("socat proxy failed to start")
            # Check log
            docker_exec(f"cat /tmp/socat_{available_port}.log 2>/dev/null")
            return None

        self.log_ok(f"VNC proxy started on port {available_port}")
        return available_port

    def repair(self):
        """Attempt automatic repair of VNC issues."""
        print("=" * 60)
        print("VNC/HMI Automatic Repair")
        print("=" * 60)

        if not self.check_core_novnc_running():
            print("\n⛔ Cannot proceed - start core-novnc first")
            return False

        # Step 1: Cleanup stale proxies
        print("\nStep 1: Cleaning up stale proxies...")
        proxies = self.get_proxy_state()

        for port, state in proxies.items():
            if state.get('socat_running') and not state.get('pid_valid'):
                print(f"  Cleaning stale proxy on port {port}...")
                docker_exec(f"pkill -f 'socat.*{port}.*ns_forward' 2>/dev/null || true")
                docker_exec(f"rm -f /tmp/ns_forward_{port}.sh 2>/dev/null || true")

        time.sleep(1)

        # Step 2: Find and setup HMI containers
        print("\nStep 2: Setting up VNC for HMI containers...")
        hmi_containers = self.get_hmi_containers()

        results = []
        for container in hmi_containers:
            name = container['name']

            # Start VNC services in container
            if not self.check_vnc_services(name):
                self.start_vnc_in_container(name)
                time.sleep(2)

            # Setup proxy
            port = self.setup_proxy_for_container(name)
            if port:
                results.append({'container': name, 'port': port})

        # Summary
        print("\n" + "=" * 60)
        print("REPAIR RESULTS")
        print("=" * 60)

        if results:
            print("\nVNC proxies configured:")
            for r in results:
                print(f"  {r['container']} → port {r['port']}")
        else:
            print("\nNo VNC proxies could be configured")

        return len(results) > 0


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    diag = VNCDiagnostics()
    command = sys.argv[1].lower()

    if command == 'diagnose':
        diag.diagnose()
    elif command == 'repair':
        diag.repair()
    elif command == 'cleanup':
        diag.cleanup_all_proxies()
    elif command == 'setup' and len(sys.argv) > 2:
        container = sys.argv[2]
        diag.start_vnc_in_container(container)
        diag.setup_proxy_for_container(container)
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == '__main__':
    main()
