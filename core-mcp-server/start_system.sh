#!/bin/bash
# Complete System Startup Script
# This script starts all services needed for the CORE digital twin environment
#
# Services started:
#   1. core-novnc container (CORE emulator with VNC)
#   2. Web UI (Flask dashboard on port 8080)
#   3. CORE topology (loaded and started automatically)
#   4. VNC proxies for HMI nodes
#
# Usage:
#   ./start_system.sh                    # Start everything
#   ./start_system.sh --topology FILE    # Load specific topology
#   ./start_system.sh --no-start         # Load but don't start topology
#   ./start_system.sh --reset            # Full cleanup and restart

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default topology file
DEFAULT_TOPOLOGY="/tmp/iot_topology.xml"

# Parse arguments
TOPOLOGY_FILE=""
AUTO_START="true"
RESET_MODE="false"
PHONE_MODE="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --topology|-t)
            TOPOLOGY_FILE="$2"
            shift 2
            ;;
        --no-start)
            AUTO_START="false"
            shift
            ;;
        --reset|-r)
            RESET_MODE="true"
            shift
            ;;
        --phone)
            PHONE_MODE="true"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --topology, -t FILE   Load specific topology file"
            echo "  --no-start            Load topology but don't auto-start"
            echo "  --reset, -r           Full cleanup before starting"
            echo "  --phone               Also start phone sensor system (port 8081)"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  CORE Digital Twin System Startup     ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Step 1: Check/start core-novnc container
echo -e "${YELLOW}[1/5] Starting core-novnc container...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^core-novnc$"; then
    echo -e "  ${GREEN}✓${NC} core-novnc is already running"
else
    if docker ps -a --format '{{.Names}}' | grep -q "^core-novnc$"; then
        echo "  Starting stopped container..."
        docker start core-novnc
    else
        echo -e "  ${RED}✗${NC} core-novnc container not found"
        echo "  Please create the container first with:"
        echo "    docker run -d --name core-novnc --privileged ..."
        exit 1
    fi
    sleep 3
    echo -e "  ${GREEN}✓${NC} core-novnc started"
fi

# Step 2: Wait for CORE daemon to be ready
echo -e "${YELLOW}[2/5] Waiting for CORE daemon...${NC}"
MAX_WAIT=30
WAITED=0
while ! docker exec core-novnc pgrep -f "core-daemon" > /dev/null 2>&1; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo -e "  ${RED}✗${NC} CORE daemon not responding"
        exit 1
    fi
    sleep 1
    WAITED=$((WAITED + 1))
done
echo -e "  ${GREEN}✓${NC} CORE daemon is ready"

# Step 3: Start Web UI
echo -e "${YELLOW}[3/5] Starting Web UI (port 8080)...${NC}"
pkill -f "web_ui.py" 2>/dev/null || true
sleep 1
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/web_ui.log 2>&1 &
WEB_UI_PID=$!
sleep 2

if ps -p $WEB_UI_PID > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} Web UI running on port 8080 (PID: $WEB_UI_PID)"
else
    echo -e "  ${RED}✗${NC} Web UI failed to start"
    tail -10 /tmp/web_ui.log
    exit 1
fi

# Step 4: Load CORE topology
echo -e "${YELLOW}[4/5] Loading CORE topology...${NC}"

# Determine topology file
if [ -z "$TOPOLOGY_FILE" ]; then
    # Check for default topology
    if [ -f "$DEFAULT_TOPOLOGY" ]; then
        TOPOLOGY_FILE="$DEFAULT_TOPOLOGY"
        echo "  Using default topology: $TOPOLOGY_FILE"
    else
        # Look for any topology in common locations
        for f in /tmp/*.xml "$SCRIPT_DIR"/*.xml "$SCRIPT_DIR"/examples/*.xml; do
            if [ -f "$f" ]; then
                TOPOLOGY_FILE="$f"
                echo "  Found topology: $TOPOLOGY_FILE"
                break
            fi
        done
    fi
fi

if [ -n "$TOPOLOGY_FILE" ] && [ -f "$TOPOLOGY_FILE" ]; then
    # Copy topology to core-novnc container
    docker cp "$TOPOLOGY_FILE" core-novnc:/tmp/topology.xml
    docker cp load_topology.py core-novnc:/tmp/load_topology.py

    if [ "$AUTO_START" = "true" ]; then
        echo "  Loading and starting topology..."
        docker exec core-novnc /opt/core/venv/bin/python3 /tmp/load_topology.py --start /tmp/topology.xml 2>&1 | sed 's/^/  /'
    else
        echo "  Loading topology (not starting)..."
        docker exec core-novnc /opt/core/venv/bin/python3 /tmp/load_topology.py /tmp/topology.xml 2>&1 | sed 's/^/  /'
    fi
    echo -e "  ${GREEN}✓${NC} Topology loaded"
else
    echo -e "  ${YELLOW}⚠${NC} No topology file found"
    echo "  Generate one using the Web UI at /topology-generator"
    echo "  Or specify one with: $0 --topology /path/to/topology.xml"
fi

# Step 5: Set up VNC proxies for HMI nodes
echo -e "${YELLOW}[5/5] Setting up VNC proxies...${NC}"
sleep 2  # Wait for containers to fully initialize

if [ -x "$SCRIPT_DIR/setup_hmi_vnc_proxies.sh" ]; then
    "$SCRIPT_DIR/setup_hmi_vnc_proxies.sh" 2>&1 | sed 's/^/  /' || true
else
    echo "  VNC proxy setup script not found"
fi

# Optional: Start phone sensor system
if [ "$PHONE_MODE" = "true" ]; then
    echo ""
    echo -e "${YELLOW}Starting Phone Sensor System...${NC}"
    if [ -x "$SCRIPT_DIR/start_phone_system.sh" ]; then
        "$SCRIPT_DIR/start_phone_system.sh"
    fi
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  System Started Successfully!         ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Detect environment and show URLs
if [ -n "$CODESPACE_NAME" ]; then
    BASE_URL="https://$CODESPACE_NAME-8080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
    NOVNC_URL="https://$CODESPACE_NAME-6080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"

    echo -e "${CYAN}GitHub Codespace URLs:${NC}"
    echo ""
    echo -e "  ${YELLOW}Dashboard:${NC}     $BASE_URL/"
    echo -e "  ${YELLOW}CORE VNC:${NC}      $BASE_URL/core-vnc/vnc_lite.html?path=core-vnc/websockify"
    echo -e "  ${YELLOW}Topology Gen:${NC}  $BASE_URL/topology-generator"
    echo ""

    # List HMI VNC ports if available
    if docker exec core-novnc pgrep -f "websockify.*608[1-9]" > /dev/null 2>&1; then
        echo -e "  ${YELLOW}HMI VNC:${NC}"
        for port in $(docker exec core-novnc pgrep -af "websockify" 2>/dev/null | grep -oE '608[1-9]' | sort -u); do
            echo "     Port $port: $BASE_URL/hmi-vnc/$port/vnc_lite.html?path=hmi-vnc/$port/websockify"
        done
        echo ""
    fi

    echo -e "${YELLOW}Note:${NC} Ensure port 8080 is set to 'Public' in Codespace port settings"
else
    echo -e "${CYAN}Local URLs:${NC}"
    echo ""
    echo -e "  ${YELLOW}Dashboard:${NC}     http://localhost:8080/"
    echo -e "  ${YELLOW}CORE VNC:${NC}      http://localhost:8080/core-vnc/vnc_lite.html?path=core-vnc/websockify"
    echo -e "  ${YELLOW}Topology Gen:${NC}  http://localhost:8080/topology-generator"
    echo ""

    # List HMI VNC ports if available
    if docker exec core-novnc pgrep -f "websockify.*608[1-9]" > /dev/null 2>&1; then
        echo -e "  ${YELLOW}HMI VNC:${NC}"
        for port in $(docker exec core-novnc pgrep -af "websockify" 2>/dev/null | grep -oE '608[1-9]' | sort -u); do
            echo "     Port $port: http://localhost:8080/hmi-vnc/$port/vnc_lite.html?path=hmi-vnc/$port/websockify"
        done
        echo ""
    fi
fi

echo -e "${YELLOW}Quick Commands:${NC}"
echo "  Logs:           tail -f /tmp/web_ui.log"
echo "  Restart VNC:    ./setup_hmi_vnc_proxies.sh"
echo "  Load topology:  docker exec core-novnc /opt/core/venv/bin/python3 /tmp/load_topology.py --start /tmp/topology.xml"
echo ""
