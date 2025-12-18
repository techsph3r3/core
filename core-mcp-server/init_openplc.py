#!/usr/bin/env python3
"""
Initialize OpenPLC with sorting_twin.st program.

This script:
1. Waits for OpenPLC webserver to be ready
2. Copies sorting_twin.st to the correct location
3. Compiles the program
4. Starts the PLC runtime

Run from host:
    python3 init_openplc.py

Environment:
    OPENPLC_URL: OpenPLC web interface URL (default: http://10.0.0.10:8080)
    DOCKER_HOST: Docker host container name (default: core-novnc)
"""

import subprocess
import time
import sys
import os

DOCKER_HOST = os.environ.get('DOCKER_HOST', 'core-novnc')
OPENPLC_IP = os.environ.get('OPENPLC_IP', '10.0.0.10')
OPENPLC_PORT = os.environ.get('OPENPLC_PORT', '8080')
ST_FILE = os.environ.get('ST_FILE', '/workspaces/core/core-mcp-server/plc_programs/sorting_twin.st')


def docker_exec(container, cmd, timeout=30):
    """Execute command in nested Docker container."""
    full_cmd = f'docker exec {DOCKER_HOST} docker exec {container} {cmd}'
    try:
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return result.returncode == 0, result.stdout + result.stderr
    except subprocess.TimeoutExpired:
        return False, "Timeout"
    except Exception as e:
        return False, str(e)


def wait_for_openplc(max_attempts=30):
    """Wait for OpenPLC webserver to be ready."""
    print(f"Waiting for OpenPLC at {OPENPLC_IP}:{OPENPLC_PORT}...")
    for i in range(max_attempts):
        success, output = docker_exec('plc', f'curl -s --max-time 3 http://localhost:{OPENPLC_PORT}/login')
        if success and 'login' in output.lower():
            print("  OpenPLC webserver ready")
            return True
        print(f"  Attempt {i+1}/{max_attempts}...")
        time.sleep(2)
    print("  OpenPLC not responding")
    return False


def copy_st_program():
    """Copy sorting_twin.st to OpenPLC container."""
    print(f"Copying ST program to OpenPLC...")

    # Copy to core-novnc first
    cmd1 = f'docker cp {ST_FILE} {DOCKER_HOST}:/tmp/sorting_twin.st'
    result1 = subprocess.run(cmd1, shell=True, capture_output=True, text=True, timeout=10)
    if result1.returncode != 0:
        print(f"  Failed to copy to {DOCKER_HOST}: {result1.stderr}")
        return False

    # Copy to plc container
    cmd2 = f'docker exec {DOCKER_HOST} docker cp /tmp/sorting_twin.st plc:/workdir/sorting_twin.st'
    result2 = subprocess.run(cmd2, shell=True, capture_output=True, text=True, timeout=10)
    if result2.returncode != 0:
        print(f"  Failed to copy to plc: {result2.stderr}")
        return False

    # Copy to st_files directory
    success, output = docker_exec('plc', 'cp /workdir/sorting_twin.st /workdir/webserver/st_files/sorting_twin.st')
    if not success:
        print(f"  Failed to copy to st_files: {output}")
        return False

    # Register in database
    db_cmd = '''sqlite3 /workdir/webserver/openplc.db "INSERT OR IGNORE INTO Programs (Name, Description, File, Date_upload) VALUES ('Sorting_Twin', 'Digital Twin Sorting', 'sorting_twin.st', datetime('now'));"'''
    success, output = docker_exec('plc', db_cmd)
    if not success:
        print(f"  Warning: Could not register in DB: {output}")

    print("  ST program copied successfully")
    return True


def compile_and_start_plc():
    """Login, compile program, and start PLC runtime using curl."""
    print("Compiling and starting OpenPLC...")

    # Use curl to login and get session cookie
    print("  Logging in...")
    login_cmd = '''curl -s -c /tmp/cookies.txt -b /tmp/cookies.txt -L -d "username=openplc&password=openplc" http://localhost:8080/login'''
    success, output = docker_exec('plc', login_cmd, timeout=30)
    if not success:
        print(f"  Login failed: {output}")
        return False

    # Compile the program
    print("  Compiling sorting_twin.st...")
    compile_cmd = '''curl -s -b /tmp/cookies.txt "http://localhost:8080/compile-program?file=sorting_twin.st"'''
    success, output = docker_exec('plc', compile_cmd, timeout=60)

    # Wait for compilation
    print("  Waiting for compilation (25s)...")
    time.sleep(25)

    # Check compilation logs
    logs_cmd = '''curl -s -b /tmp/cookies.txt "http://localhost:8080/compilation-logs"'''
    success, output = docker_exec('plc', logs_cmd, timeout=30)
    if 'successfully' in output.lower():
        print("  Compilation successful!")
    else:
        print(f"  Compilation status: {output[:200] if output else 'unknown'}")

    # Start PLC runtime
    print("  Starting PLC runtime...")
    start_cmd = '''curl -s -b /tmp/cookies.txt "http://localhost:8080/start_plc"'''
    success, output = docker_exec('plc', start_cmd, timeout=30)

    # Wait for PLC to start
    time.sleep(5)

    # Verify PLC is running by checking if Modbus port is open
    print("  Verifying PLC runtime...")
    verify_cmd = '''timeout 2 bash -c "echo '' | nc -w1 localhost 502" && echo "MODBUS_OPEN" || echo "MODBUS_CLOSED"'''
    success, output = docker_exec('plc', verify_cmd, timeout=10)
    if 'MODBUS_OPEN' in output:
        print("  PLC runtime is RUNNING (Modbus port 502 open)")
        return True
    else:
        print("  PLC may not be running (Modbus port closed)")
        return False


def press_start_button():
    """Press the START button via Modbus to start the conveyor.

    Uses eng-ws container which has the correct pymodbus version.
    """
    print("Pressing START button via Modbus...")

    # Use eng-ws (engineering workstation) which has pymodbus 3.x
    start_cmd = '''python3 -c "
from pymodbus.client import ModbusTcpClient
import time
client = ModbusTcpClient('10.0.0.10', port=502, timeout=2)
if client.connect():
    # Press start button
    client.write_register(address=1129, value=1)
    time.sleep(0.3)
    # Release start button
    client.write_register(address=1129, value=0)
    # Check conveyor state
    time.sleep(0.2)
    coils = client.read_coils(address=0, count=1)
    if not coils.isError() and coils.bits[0]:
        print('CONVEYOR_RUNNING')
    else:
        print('CONVEYOR_STOPPED')
    client.close()
else:
    print('CONNECTION_FAILED')
"'''
    # Run on eng-ws, not plc
    success, output = docker_exec('eng-ws', start_cmd, timeout=15)
    if 'CONVEYOR_RUNNING' in output:
        print("  Conveyor is RUNNING")
        return True
    else:
        print(f"  Conveyor status: {output.strip()}")
        return False


def main():
    print("=" * 50)
    print("  OpenPLC Initialization Script")
    print("=" * 50)
    print()

    # Wait for OpenPLC
    if not wait_for_openplc():
        print("ERROR: OpenPLC not available")
        sys.exit(1)

    # Copy ST program
    if not copy_st_program():
        print("ERROR: Could not copy ST program")
        sys.exit(1)

    # Compile and start
    if not compile_and_start_plc():
        print("WARNING: PLC compilation/start may have issues")

    # Wait a bit for PLC to stabilize, then start the conveyor
    print("Waiting for PLC to stabilize...")
    time.sleep(3)

    # Auto-start the conveyor
    if not press_start_button():
        print("WARNING: Could not auto-start conveyor (press START in 3D twin)")

    print()
    print("=" * 50)
    print("  Initialization Complete!")
    print("=" * 50)


if __name__ == '__main__':
    main()
