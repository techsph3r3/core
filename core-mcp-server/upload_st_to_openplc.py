#!/usr/bin/env python3
"""Upload and compile ST program to OpenPLC via HTTP API"""
import sys
import requests
import time
import os

# Configuration defaults
OPENPLC_IP = "localhost" # Running inside the container or exposed via port forward
OPENPLC_PORT = "8080"
OPENPLC_URL = f"http://{OPENPLC_IP}:{OPENPLC_PORT}"
ST_FILE = "sorting_merged.st"
USERNAME = "openplc"
PASSWORD = "openplc"

if len(sys.argv) > 1:
    OPENPLC_URL = sys.argv[1]
if len(sys.argv) > 2:
    ST_FILE = sys.argv[2]

print(f"Target: {OPENPLC_URL}")
print(f"File: {ST_FILE}")

session = requests.Session()

# Step 1: Login
print(f"  Logging in to {OPENPLC_URL}...")
try:
    login_resp = session.post(f"{OPENPLC_URL}/login", data={
        "username": USERNAME,
        "password": PASSWORD
    }, allow_redirects=True, timeout=10)
    if "dashboard" not in login_resp.url and "Invalid" in login_resp.text:
        print(f"  ERROR: Login failed")
        sys.exit(1)
    print(f"  Logged in successfully")
except Exception as e:
    print(f"  ERROR: Could not connect to OpenPLC: {e}")
    sys.exit(1)

# Step 2: Upload program
print(f"  Uploading {ST_FILE}...")
try:
    with open(ST_FILE, 'rb') as f:
        files = {'file': ('sorting_twin.st', f, 'text/plain')}
        data = {
            'program_name': 'Sorting Facility',
            'program_descr': '3-Color Package Sorting System',
            'program_file': 'sorting_twin.st'
        }
        # Note: 'sorting_twin.st' is the hardcoded name OpenPLC often expects or uses internally for the file field
        upload_resp = session.post(f"{OPENPLC_URL}/upload-program-action",
                                   files=files, data=data, timeout=30)
        if upload_resp.status_code != 200:
            print(f"  ERROR: Upload failed with status {upload_resp.status_code}")
            sys.exit(1)
    print(f"  Upload successful")
except Exception as e:
    print(f"  ERROR: Upload failed: {e}")
    sys.exit(1)

# Step 3: Compile program
print(f"  Compiling program...")
try:
    # Use the filename that OpenPLC expects (often whatever was uploaded)
    compile_resp = session.get(f"{OPENPLC_URL}/compile-program?file=sorting_twin.st", timeout=60)
    # Wait for compilation
    time.sleep(2)

    # Check compilation logs
    for i in range(30):
        logs_resp = session.get(f"{OPENPLC_URL}/compilation-logs", timeout=10)
        if "Compilation finished successfully" in logs_resp.text:
            print(f"  Compilation successful!")
            break
        elif "error" in logs_resp.text.lower():
            print(f"  ERROR: Compilation failed")
            print(logs_resp.text[:500])
            sys.exit(1)
        time.sleep(2)
except Exception as e:
    print(f"  ERROR: Compilation failed: {e}")
    sys.exit(1)

# Step 4: Start PLC
print(f"  Starting PLC runtime...")
try:
    start_resp = session.get(f"{OPENPLC_URL}/start_plc", timeout=30)
    time.sleep(3)

    # Verify PLC is running
    dash_resp = session.get(f"{OPENPLC_URL}/dashboard", timeout=10)
    if "Running" in dash_resp.text or "running" in dash_resp.text:
        print(f"  PLC runtime started!")
    else:
        print(f"  WARNING: PLC may not be running")
except Exception as e:
    print(f"  WARNING: Could not verify PLC start: {e}")

print("  OpenPLC setup complete!")
