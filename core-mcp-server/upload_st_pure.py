#!/usr/bin/env python3
import sys
import time
import urllib.request
import urllib.parse
import urllib.error
import mimetypes
import uuid
import io

# Configuration
OPENPLC_URL = "http://localhost:8080"
ST_FILE = "/tmp/sorting_twin.st"
USERNAME = "openplc"
PASSWORD = "openplc"

if len(sys.argv) > 1:
    OPENPLC_URL = sys.argv[1]
if len(sys.argv) > 2:
    ST_FILE = sys.argv[2]

print(f"Target: {OPENPLC_URL}")
print(f"File: {ST_FILE}")

# Function to handle multipart upload
def encode_multipart_formdata(fields, files):
    boundary = uuid.uuid4().hex
    crlf = b'\r\n'
    lines = []
    
    for key, value in fields.items():
        lines.append(f'--{boundary}'.encode())
        lines.append(crlf)
        lines.append(f'Content-Disposition: form-data; name="{key}"'.encode())
        lines.append(crlf)
        lines.append(crlf)
        lines.append(value.encode())
        lines.append(crlf)
    
    for key, (filename, content) in files.items():
        lines.append(f'--{boundary}'.encode())
        lines.append(crlf)
        lines.append(f'Content-Disposition: form-data; name="{key}"; filename="{filename}"'.encode())
        lines.append(crlf)
        lines.append(b'Content-Type: text/plain')
        lines.append(crlf)
        lines.append(crlf)
        lines.append(content)
        lines.append(crlf)
    
    lines.append(f'--{boundary}--'.encode())
    lines.append(crlf)
    
    body = b''.join(lines)
    content_type = f'multipart/form-data; boundary={boundary}'
    return content_type, body

# Session handler (cookies)
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor())
urllib.request.install_opener(opener)

# Step 1: Login
print(f"  Logging in to {OPENPLC_URL}...")
try:
    data = urllib.parse.urlencode({
        "username": USERNAME,
        "password": PASSWORD
    }).encode()
    req = urllib.request.Request(f"{OPENPLC_URL}/login", data=data)
    with opener.open(req) as response:
        content = response.read().decode()
        if "dashboard" not in response.geturl() and "Invalid" in content:
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
        file_content = f.read()
    
    fields = {
        'program_name': 'Sorting Facility',
        'program_descr': 'Sorting Logic from API',
        'program_file': 'sorting_twin.st'
    }
    files = {
        'file': ('sorting_twin.st', file_content)
    }
    
    content_type, body = encode_multipart_formdata(fields, files)
    
    req = urllib.request.Request(f"{OPENPLC_URL}/upload-program-action", data=body)
    req.add_header('Content-Type', content_type)
    
    with opener.open(req) as response:
        if response.getcode() != 200:
            print(f"  ERROR: Upload failed with status {response.getcode()}")
            sys.exit(1)
            
    print(f"  Upload successful")
except Exception as e:
    print(f"  ERROR: Upload failed: {e}")
    sys.exit(1)

# Step 3: Compile program
print(f"  Compiling program...")
try:
    req = urllib.request.Request(f"{OPENPLC_URL}/compile-program?file=sorting_twin.st")
    with opener.open(req) as response:
        pass
    
    # Wait for compilation
    time.sleep(2)

    # Check compilation logs
    for i in range(30):
        req = urllib.request.Request(f"{OPENPLC_URL}/compilation-logs")
        with opener.open(req) as response:
            logs = response.read().decode()
        
        if "Compilation finished successfully" in logs:
            print(f"  Compilation successful!")
            break
        elif "error" in logs.lower() and "compilation finished" not in logs.lower():
            # Sometimes logs imply error but finish successfully, be careful
            if "Compilation finished successfully" not in logs: # Double check
                 pass # Keep waiting or checking
        
        # OpenPLC API is simple, if it fails it usually says so clearly.
        # But 'error' substring matches many things.
        # Let's rely on 'Compilation finished successfully'
        
        if "Compilation failed" in logs:
             print(f"  ERROR: Compilation failed")
             print(logs[:500])
             sys.exit(1)
             
        print("  Waiting for compilation...")
        time.sleep(2)
except Exception as e:
    print(f"  ERROR: Compilation failed: {e}")
    sys.exit(1)

# Step 4: Start PLC
print(f"  Starting PLC runtime...")
try:
    req = urllib.request.Request(f"{OPENPLC_URL}/start_plc")
    with opener.open(req) as response:
        pass
    time.sleep(3)

    # Verify PLC is running
    req = urllib.request.Request(f"{OPENPLC_URL}/dashboard")
    with opener.open(req) as response:
        dash_content = response.read().decode()
    
    if "Running" in dash_content or "running" in dash_content:
        print(f"  PLC runtime started!")
    else:
        print(f"  WARNING: PLC may not be running")
except Exception as e:
    print(f"  WARNING: Could not verify PLC start: {e}")

print("  OpenPLC setup complete!")
