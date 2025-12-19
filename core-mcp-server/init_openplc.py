#!/usr/bin/env python3
"""
Initialize OpenPLC with sorting_merged.st program.

This script:
1. Waits for OpenPLC webserver to be ready
2. Copies sorting_merged.st to the correct location in the PLC container
3. Registers the program in the SQLite DB
4. Compiles the program via local API call (inside container)
5. Starts the PLC runtime

Run from host:
    python3 init_openplc.py
"""

import subprocess
import time
import sys
import os

# Configuration
# Run from the directory where web_ui.py is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DOCKER_HOST = os.environ.get('DOCKER_HOST', 'core-novnc')
OPENPLC_PORT = os.environ.get('OPENPLC_PORT', '8080')

# Use the merged ST file by default
ST_FILENAME = 'sorting_merged.st'
ST_FILE_PATH = os.path.join(SCRIPT_DIR, 'plc_programs', ST_FILENAME)
TARGET_ST_FILE = 'sorting_twin.st' # OpenPLC expects this name for the project or we choose to map it

def log(msg):
    print(f"[InitOpenPLC] {msg}")

def docker_exec_host(cmd, timeout=30):
    """Execute command in the core-novnc container."""
    full_cmd = f'docker exec {DOCKER_HOST} {cmd}'
    try:
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        if result.returncode != 0:
            return False, result.stderr
        return True, result.stdout
    except Exception as e:
        return False, str(e)

def docker_exec_plc(cmd, timeout=30):
    """Execute command in the nested plc container."""
    # We execute via core-novnc -> docker exec plc -> cmd
    full_cmd = f'docker exec {DOCKER_HOST} docker exec plc {cmd}'
    try:
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        if result.returncode != 0:
            return False, result.stderr or result.stdout
        return True, result.stdout
    except Exception as e:
        return False, str(e)

def wait_for_openplc_container(max_attempts=30):
    """Wait for OpenPLC container to be running and webserver (localhost) to be responsive."""
    log(f"Waiting for OpenPLC container in {DOCKER_HOST}...")
    
    for i in range(max_attempts):
        # Check if container exists and is running
        success, output = docker_exec_host("docker ps --filter name=plc --format '{{.Status}}'")
        if success and "Up" in output:
            # Check if port 8080 is answering locally
            success, _ = docker_exec_plc(f"curl -s --max-time 2 http://localhost:{OPENPLC_PORT}/login")
            if success:
                log("OpenPLC webserver is ready.")
                return True
        time.sleep(2)
        
    log("Timeout waiting for OpenPLC.")
    return False

def inject_files():
    """Copy ST file and Autostart script from Host -> core-novnc -> plc container."""
    log(f"Injecting files...")

    # Files to inject: (Local Path, Target Filename in Container)
    files_to_inject = [
        (ST_FILE_PATH, TARGET_ST_FILE),
        (os.path.join(SCRIPT_DIR, 'autostart_plc.sh'), 'autostart_plc.sh')
    ]

    for local_path, target_name in files_to_inject:
        if not os.path.exists(local_path):
            log(f"ERROR: Local file not found: {local_path}")
            return False

        # Step 1: Copy to core-novnc /tmp
        cmd1 = f'docker cp "{local_path}" {DOCKER_HOST}:/tmp/{target_name}'
        result1 = subprocess.run(cmd1, shell=True, capture_output=True, text=True)
        if result1.returncode != 0:
            log(f"Failed to copy {target_name} to {DOCKER_HOST}: {result1.stderr}")
            return False

        # Step 2: Copy from core-novnc /tmp to plc /tmp
        success, output = docker_exec_host(f"docker cp /tmp/{target_name} plc:/tmp/{target_name}")
        if not success:
            log(f"Failed copy {target_name} to plc: {output}")
            return False

    # Move ST file to destination
    dest_path = f"/workdir/webserver/st_files/{TARGET_ST_FILE}"
    success, output = docker_exec_plc(f"cp /tmp/{TARGET_ST_FILE} {dest_path}")
    if not success:
        log(f"Failed to move ST file in plc: {output}")
        return False
    
    # Make script executable
    docker_exec_plc("chmod +x /tmp/autostart_plc.sh")
    
    log("Files injected successfully.")
    
    # Register in SQLite
    db_cmd = f'''sqlite3 /workdir/webserver/openplc.db "INSERT OR REPLACE INTO Programs (Name, Description, File, Date_upload) VALUES ('Sorting_Twin', 'Auto Deployed Logic', '{TARGET_ST_FILE}', datetime('now'));"'''
    docker_exec_plc(db_cmd)
    
    return True

def compile_and_start():
    """Trigger compilation and start via injected script."""
    log("Compiling and Starting PLC...")
    
    success, output = docker_exec_plc("/tmp/autostart_plc.sh", timeout=120)
    log(f"Auto-start Output:\n{output}")
    
    if "PLC_RUNNING" in output:
        log("PLC started successfully.")
        return True
    else:
        log("Failed to start PLC.")
        return False

def main():
    log("Starting OpenPLC Initialization...")
    
    if not wait_for_openplc_container():
        sys.exit(1)
        
    if not inject_files():
        sys.exit(1)
        
    if not compile_and_start():
        sys.exit(1)
        
    log("Initialization Complete.")



if __name__ == '__main__':
    main()
