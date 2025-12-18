#!/bin/bash
# ICS Sorting Facility - Complete Runtime Script
#
# This script initializes and starts all components of the ICS Sorting Facility:
# - OpenPLC (10.0.0.10) with the sorting_twin.st program
# - Node-RED HMI (10.0.0.20) with pre-configured Modbus dashboard
# - Starts the PLC I/O bridge for 3D digital twin integration
#
# Architecture:
#   3D Digital Twin (Browser) <--WebSocket--> PLC I/O Bridge <--Modbus TCP--> OpenPLC
#                                                                              ^
#                                                                              |
#   Node-RED HMI Dashboard  <-----------Modbus TCP---------------------------|

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOCKER_HOST="${DOCKER_HOST:-core-novnc}"
OPENPLC_IP="10.0.0.10"
OPENPLC_PORT="8080"
OPENPLC_MODBUS="502"
OPENPLC_USER="openplc"
OPENPLC_PASS="openplc"
HMI_IP="10.0.0.20"
HMI_PORT="1880"
ST_PROGRAM="plc_programs/sorting_twin.st"
NODERED_FLOWS="../dockerfiles/nodered-hmi/flows.json"

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ICS Sorting Facility - Runtime Initialization ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Step 0: Clean up any stale CORE sessions and network interfaces
echo -e "${YELLOW}[0/8] Cleaning up stale CORE sessions...${NC}"

# Check if container is running first
if docker ps --format '{{.Names}}' | grep -q "^${DOCKER_HOST}$"; then
    # Stop existing CORE sessions via core-cli
    for session_id in $(docker exec $DOCKER_HOST /opt/core/venv/bin/core-cli session 2>/dev/null | grep -oP '^\d+' || true); do
        echo -e "  Stopping session $session_id..."
        docker exec $DOCKER_HOST /opt/core/venv/bin/core-cli session -i $session_id delete 2>/dev/null || true
    done

    # Clean up stale network bridges (CORE uses b.X.X pattern)
    STALE_BRIDGES=$(docker exec $DOCKER_HOST ip link show type bridge 2>/dev/null | grep -oP "b\.\d+\.\d+" | sort -u || true)
    if [ -n "$STALE_BRIDGES" ]; then
        echo -e "  Removing stale bridges..."
        for br in $STALE_BRIDGES; do
            docker exec $DOCKER_HOST ip link set $br down 2>/dev/null || true
            docker exec $DOCKER_HOST ip link delete $br 2>/dev/null || true
        done
    fi

    # Clean up stale veth pairs
    STALE_VETHS=$(docker exec $DOCKER_HOST ip link show type veth 2>/dev/null | grep -oP "(veth|beth)\d+\.\d+\.\d+" | sort -u || true)
    if [ -n "$STALE_VETHS" ]; then
        echo -e "  Removing stale veth interfaces..."
        for veth in $STALE_VETHS; do
            docker exec $DOCKER_HOST ip link delete $veth 2>/dev/null || true
        done
    fi

    # Clean up stale pycore directories
    docker exec $DOCKER_HOST rm -rf /tmp/pycore.* 2>/dev/null || true

    # Clean up any orphaned Docker containers from previous CORE sessions
    ORPHAN_CONTAINERS=$(docker exec $DOCKER_HOST docker ps -a --format '{{.Names}}' 2>/dev/null | grep -E '\.[0-9]+$' || true)
    if [ -n "$ORPHAN_CONTAINERS" ]; then
        echo -e "  Removing orphaned containers..."
        for container in $ORPHAN_CONTAINERS; do
            docker exec $DOCKER_HOST docker rm -f $container 2>/dev/null || true
        done
    fi

    echo -e "  ${GREEN}✓${NC} Cleanup complete"
else
    echo -e "  ${YELLOW}⚠${NC} Container not running, skipping cleanup"
fi
echo ""

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local name=$3
    local max_attempts=${4:-30}
    local attempt=1

    echo -n "  Waiting for $name ($host:$port)..."
    while [ $attempt -le $max_attempts ]; do
        if docker exec $DOCKER_HOST docker exec $(docker exec $DOCKER_HOST docker ps -q --filter "network=10.0.0.0/24" | head -1) timeout 1 nc -z $host $port 2>/dev/null; then
            echo -e " ${GREEN}ready${NC}"
            return 0
        fi
        # Try alternative method using curl from inside CORE
        if docker exec $DOCKER_HOST curl -s --max-time 2 http://$host:$port/ >/dev/null 2>&1; then
            echo -e " ${GREEN}ready${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    echo -e " ${RED}timeout${NC}"
    return 1
}

# Function to execute commands inside a CORE node
exec_in_node() {
    local node_name=$1
    shift
    docker exec $DOCKER_HOST docker exec $node_name "$@"
}

# Step 1: Check if core-novnc container is running
echo -e "${YELLOW}[1/8] Checking CORE container...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^${DOCKER_HOST}$"; then
    echo -e "  ${GREEN}✓${NC} $DOCKER_HOST is running"
else
    echo -e "  ${RED}✗${NC} $DOCKER_HOST not running"
    echo -e "  Please start the CORE environment first:"
    echo -e "    docker start $DOCKER_HOST"
    exit 1
fi

# Step 1b: Ensure VNC server and CORE GUI are running
echo -e "${YELLOW}[1b/8] Checking VNC and CORE GUI...${NC}"

# Check if VNC server is running
if docker exec $DOCKER_HOST pgrep -f "vncserver" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} VNC server is running"
else
    echo -e "  ${YELLOW}→${NC} Starting VNC server..."
    docker exec -d $DOCKER_HOST /opt/start-vnc.sh 2>/dev/null || true
    sleep 3
    if docker exec $DOCKER_HOST pgrep -f "vncserver" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} VNC server started"
    else
        echo -e "  ${YELLOW}⚠${NC} VNC server may not have started"
    fi
fi

# Check if websockify/noVNC proxy is running
if docker exec $DOCKER_HOST pgrep -f "websockify.*6080" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} noVNC proxy is running"
else
    echo -e "  ${YELLOW}→${NC} Starting noVNC proxy..."
    docker exec -d $DOCKER_HOST bash -c "python3 -m websockify --web /opt/noVNC 6080 localhost:5901" 2>/dev/null || true
    sleep 2
    echo -e "  ${GREEN}✓${NC} noVNC proxy started"
fi

# Check if CORE daemon is running
if docker exec $DOCKER_HOST pgrep -f "core-daemon" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} CORE daemon is running"
else
    echo -e "  ${YELLOW}→${NC} Starting CORE daemon..."
    docker exec -d $DOCKER_HOST core-daemon 2>/dev/null || true
    sleep 3
fi

# Check if CORE GUI is running
if docker exec $DOCKER_HOST pgrep -f "core-gui" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} CORE GUI is running"
else
    echo -e "  ${YELLOW}→${NC} Starting CORE GUI..."
    # Need DISPLAY set for GUI
    docker exec -d $DOCKER_HOST bash -c "export DISPLAY=:1 && /opt/core/venv/bin/python3 /usr/bin/core-gui" 2>/dev/null || true
    sleep 2
    if docker exec $DOCKER_HOST pgrep -f "core-gui" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} CORE GUI started"
    else
        echo -e "  ${YELLOW}⚠${NC} CORE GUI may need manual start via noVNC"
    fi
fi

# Step 2: Check for OpenPLC and HMI containers
echo -e "${YELLOW}[2/8] Checking ICS containers inside CORE...${NC}"
OPENPLC_CONTAINER=$(docker exec $DOCKER_HOST docker ps --format '{{.Names}}' 2>/dev/null | grep -E "openplc|plc" | head -1 || echo "")
HMI_CONTAINER=$(docker exec $DOCKER_HOST docker ps --format '{{.Names}}' 2>/dev/null | grep -E "nodered|hmi" | head -1 || echo "")

if [ -n "$OPENPLC_CONTAINER" ]; then
    echo -e "  ${GREEN}✓${NC} OpenPLC container: $OPENPLC_CONTAINER"
else
    echo -e "  ${RED}✗${NC} OpenPLC container not found"
    echo -e "  Deploy the ICS Sorting Facility topology first"
    exit 1
fi

if [ -n "$HMI_CONTAINER" ]; then
    echo -e "  ${GREEN}✓${NC} Node-RED HMI container: $HMI_CONTAINER"
else
    echo -e "  ${YELLOW}⚠${NC} Node-RED HMI container not found (optional)"
fi

# Step 3: Wait for OpenPLC to be ready
echo -e "${YELLOW}[3/8] Waiting for OpenPLC webserver...${NC}"
sleep 5  # Give containers time to start
OPENPLC_READY=false
for i in {1..30}; do
    # Check from the Docker host perspective
    if docker exec $DOCKER_HOST curl -s --max-time 3 http://$OPENPLC_IP:$OPENPLC_PORT/login >/dev/null 2>&1; then
        OPENPLC_READY=true
        echo -e "  ${GREEN}✓${NC} OpenPLC webserver ready at $OPENPLC_IP:$OPENPLC_PORT"
        break
    fi
    echo -n "."
    sleep 2
done

if [ "$OPENPLC_READY" != "true" ]; then
    echo -e "\n  ${RED}✗${NC} OpenPLC webserver not responding"
    echo -e "  Check if the container started correctly"
    exit 1
fi

# Step 4: Upload and compile ST program to OpenPLC
echo -e "${YELLOW}[4/8] Uploading PLC program to OpenPLC...${NC}"

if [ ! -f "$ST_PROGRAM" ]; then
    echo -e "  ${RED}✗${NC} ST program not found: $ST_PROGRAM"
    exit 1
fi

# Copy ST program into the CORE host container
docker cp "$ST_PROGRAM" $DOCKER_HOST:/tmp/sorting_twin.st
echo -e "  ${GREEN}✓${NC} Program copied to CORE host"

# Create a Python script to upload and compile the program
cat > /tmp/upload_plc_program.py << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
"""Upload and compile ST program to OpenPLC via HTTP API"""
import sys
import requests
import time

OPENPLC_URL = sys.argv[1] if len(sys.argv) > 1 else "http://10.0.0.10:8080"
ST_FILE = sys.argv[2] if len(sys.argv) > 2 else "/tmp/sorting_twin.st"
USERNAME = sys.argv[3] if len(sys.argv) > 3 else "openplc"
PASSWORD = sys.argv[4] if len(sys.argv) > 4 else "openplc"

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
    compile_resp = session.get(f"{OPENPLC_URL}/compile-program?file=sorting_twin.st", timeout=60)
    # Wait for compilation
    time.sleep(5)

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
sys.exit(0)
PYTHON_SCRIPT

# Copy and run the upload script inside CORE
docker cp /tmp/upload_plc_program.py $DOCKER_HOST:/tmp/upload_plc_program.py
docker exec $DOCKER_HOST pip3 install requests -q 2>/dev/null || true
docker exec $DOCKER_HOST python3 /tmp/upload_plc_program.py "http://$OPENPLC_IP:$OPENPLC_PORT" /tmp/sorting_twin.st "$OPENPLC_USER" "$OPENPLC_PASS" || {
    echo -e "  ${YELLOW}⚠${NC} PLC upload script had issues, continuing anyway..."
}

# Step 5: Configure Node-RED HMI
echo -e "${YELLOW}[5/8] Configuring Node-RED HMI...${NC}"

if [ -n "$HMI_CONTAINER" ] && [ -f "$NODERED_FLOWS" ]; then
    # Copy flows.json to the HMI container
    docker cp "$NODERED_FLOWS" $DOCKER_HOST:/tmp/flows.json
    docker exec $DOCKER_HOST docker cp /tmp/flows.json $HMI_CONTAINER:/data/flows.json 2>/dev/null || true

    # Restart Node-RED to load new flows
    docker exec $DOCKER_HOST docker restart $HMI_CONTAINER 2>/dev/null || true
    echo -e "  ${GREEN}✓${NC} Node-RED flows deployed and restarted"

    # Wait for Node-RED to restart
    sleep 5
else
    echo -e "  ${YELLOW}⚠${NC} Skipping Node-RED configuration"
fi

# Step 6: Start PLC I/O Bridge
echo -e "${YELLOW}[6/8] Starting PLC I/O Bridge...${NC}"

# The bridge should auto-start when digital twin connects via WebSocket
# But we can also explicitly start it via API
curl -s -X POST "http://localhost:8080/api/plc-bridge/start" \
    -H "Content-Type: application/json" \
    -d "{\"plc_ip\": \"$OPENPLC_IP\", \"plc_port\": $OPENPLC_MODBUS}" 2>/dev/null || true

# Check bridge status
BRIDGE_STATUS=$(curl -s "http://localhost:8080/api/plc-bridge/status" 2>/dev/null || echo "{}")
if echo "$BRIDGE_STATUS" | grep -q '"running":true'; then
    echo -e "  ${GREEN}✓${NC} PLC I/O Bridge running"
else
    echo -e "  ${YELLOW}⚠${NC} Bridge will start when digital twin connects"
fi

# Step 7: Verify all services
echo -e "${YELLOW}[7/8] Verifying services...${NC}"

# Check OpenPLC Modbus
echo -n "  OpenPLC Modbus ($OPENPLC_IP:$OPENPLC_MODBUS): "
if docker exec $DOCKER_HOST timeout 3 bash -c "echo '' | nc -w1 $OPENPLC_IP $OPENPLC_MODBUS" 2>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}waiting${NC}"
fi

# Check Node-RED
if [ -n "$HMI_CONTAINER" ]; then
    echo -n "  Node-RED HMI ($HMI_IP:$HMI_PORT): "
    if docker exec $DOCKER_HOST curl -s --max-time 3 http://$HMI_IP:$HMI_PORT/ >/dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${YELLOW}starting${NC}"
    fi
fi

# Step 8: Verify VNC/noVNC access
echo -e "${YELLOW}[8/8] Verifying noVNC access...${NC}"
echo -n "  VNC Server: "
if docker exec $DOCKER_HOST pgrep -f "Xtigervnc" >/dev/null 2>&1; then
    echo -e "${GREEN}running${NC}"
else
    echo -e "${YELLOW}not detected${NC}"
fi

echo -n "  noVNC Proxy (port 6080): "
if docker exec $DOCKER_HOST pgrep -f "websockify.*6080" >/dev/null 2>&1; then
    echo -e "${GREEN}running${NC}"
else
    echo -e "${YELLOW}not running${NC}"
fi

echo -n "  CORE GUI: "
if docker exec $DOCKER_HOST pgrep -f "core-gui" >/dev/null 2>&1; then
    echo -e "${GREEN}running${NC}"
else
    echo -e "${YELLOW}not running${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  ICS Sorting Facility Ready!                   ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Detect environment and show URLs
# VNC password for auto-login (keeps VNC secure but auto-fills for convenience)
VNC_PASSWORD="core123"

if [ -n "$CODESPACE_NAME" ]; then
    BASE_URL="https://$CODESPACE_NAME-8080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
    NOVNC_BASE="https://$CODESPACE_NAME-6080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
else
    BASE_URL="http://localhost:8080"
    NOVNC_BASE="http://localhost:6080"
fi

# noVNC URL with auto-connect and password (auto-login without user typing password)
NOVNC_URL="${NOVNC_BASE}/vnc.html?autoconnect=true&password=${VNC_PASSWORD}"

echo -e "${CYAN}Access Points:${NC}"
echo "  Web Dashboard:    $BASE_URL/"
echo "  3D Digital Twin:  $BASE_URL/digital-twin"
echo ""
echo -e "${CYAN}CORE Network Simulation (noVNC):${NC}"
echo "  noVNC Desktop:    $NOVNC_URL"
echo "  (Auto-connects with password - view CORE GUI with network topology)"
echo ""
echo -e "${CYAN}Internal CORE Network:${NC}"
echo "  OpenPLC Web:      http://$OPENPLC_IP:$OPENPLC_PORT (creds: openplc/openplc)"
echo "  OpenPLC Modbus:   $OPENPLC_IP:$OPENPLC_MODBUS"
if [ -n "$HMI_CONTAINER" ]; then
    echo "  Node-RED Editor:  http://$HMI_IP:$HMI_PORT/"
    echo "  Node-RED HMI:     http://$HMI_IP:$HMI_PORT/ui/"
fi
echo ""
echo -e "${CYAN}PLC I/O Mapping:${NC}"
echo "  Inputs (from 3D twin):"
echo "    IX0.0: sensor_red      IX0.4: estop"
echo "    IX0.1: sensor_white    IX0.5: start_button"
echo "    IX0.2: sensor_blue     IX0.6: stop_button"
echo "    IX0.3: package_present IX0.7: reset_button"
echo ""
echo "  Outputs (to 3D twin):"
echo "    QX0.0: conveyor_run    QX0.4: alarm"
echo "    QX0.1: diverter_red    QX0.5: run_light"
echo "    QX0.2: diverter_white  QX0.6: fault_light"
echo "    QX0.3: diverter_blue   QX0.7: ready_light"
echo ""
echo -e "${YELLOW}Quick Test:${NC}"
echo "  1. Open the 3D Digital Twin in your browser"
echo "  2. Switch to 'OpenPLC' mode in the control panel"
echo "  3. Click START to run the conveyor"
echo "  4. Spawn packages and watch them sort by color!"
echo ""
