#!/bin/bash
# Phone Sensor System - Complete Startup Script
# This script starts all services needed for the phone sensor IoT system
# This is SEPARATE from the micro:bit system and does not modify it

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Phone Sensor System - Startup Script ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Step 1: Check if core-novnc container is running
echo -e "${YELLOW}[1/4] Checking core-novnc container...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^core-novnc$"; then
    echo -e "  ✓ core-novnc is running"
else
    echo -e "  ${RED}✗ core-novnc not running. Starting...${NC}"
    docker start core-novnc || docker run -d --name core-novnc --privileged \
        -p 6080:6080 -p 5901:5901 -p 50051:50051 \
        core-novnc:latest
    sleep 5
fi

# Step 2: Check if IoT topology with MQTT broker is deployed
echo -e "${YELLOW}[2/4] Checking CORE IoT nodes...${NC}"
sleep 2
NODES=$(docker exec core-novnc docker ps --format '{{.Names}}' 2>/dev/null | grep -E "mqtt-broker" | wc -l)
if [ "$NODES" -ge 1 ]; then
    echo -e "  ✓ MQTT broker node running"
else
    echo -e "  ${YELLOW}⚠ MQTT broker not detected - phone data will be stored locally only${NC}"
    echo -e "  ${YELLOW}  Deploy an IoT topology from the web UI to enable CORE injection${NC}"
fi

# Step 3: Kill any existing phone web UI processes
echo -e "${YELLOW}[3/4] Stopping any existing phone services...${NC}"
pkill -f "phone_web_ui.py" 2>/dev/null || true
pkill -f "phone_mqtt_injector.py" 2>/dev/null || true
sleep 1
echo -e "  ✓ Cleaned up old processes"

# Step 4: Start Phone Web UI
echo -e "${YELLOW}[4/4] Starting Phone Web UI (port 8081)...${NC}"
nohup python3 phone_web_ui.py --host 0.0.0.0 --port 8081 --auto-configure-injector > /tmp/phone_webui.log 2>&1 &
sleep 2
if pgrep -f "phone_web_ui.py" > /dev/null; then
    echo -e "  ✓ Phone Web UI running on port 8081"
else
    echo -e "  ${RED}✗ Phone Web UI failed to start${NC}"
    tail -5 /tmp/phone_webui.log
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Phone Sensor System Started!         ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Detect environment and show URLs
if [ -n "$CODESPACE_NAME" ]; then
    PHONE_URL="https://$CODESPACE_NAME-8081.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
    NOVNC_URL="https://$CODESPACE_NAME-6080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"

    echo -e "${YELLOW}GitHub Codespace URLs:${NC}"
    echo ""
    echo -e "  ${CYAN}Phone Sensor Page:${NC}  ${PHONE_URL}/phone"
    echo -e "  ${CYAN}Phone Display:${NC}      ${PHONE_URL}/phone-display"
    echo -e "  ${CYAN}noVNC Desktop:${NC}      ${NOVNC_URL}"
    echo ""
    echo -e "${YELLOW}QR Code Connection:${NC}"
    echo "  1. Open ${PHONE_URL}/phone on your desktop"
    echo "  2. Scan the QR code with your phone camera"
    echo "  3. Grant sensor permissions when prompted"
    echo "  4. Tap 'Start Streaming' to begin sending data"
    echo ""
    echo -e "${YELLOW}Note:${NC} Make sure port 8081 is set to 'Public' in Codespace port settings"
else
    echo -e "${YELLOW}Local URLs:${NC}"
    echo ""
    echo -e "  ${CYAN}Phone Sensor Page:${NC}  http://localhost:8081/phone"
    echo -e "  ${CYAN}Phone Display:${NC}      http://localhost:8081/phone-display"
    echo -e "  ${CYAN}noVNC Desktop:${NC}      http://localhost:6080"
    echo ""
    echo -e "${YELLOW}QR Code Connection:${NC}"
    echo "  1. Open http://localhost:8081/phone on your desktop"
    echo "  2. Scan the QR code with your phone camera"
    echo "  3. Grant sensor permissions when prompted"
    echo "  4. Tap 'Start Streaming' to begin sending data"
    echo ""
    echo -e "${YELLOW}Note:${NC} Your phone and computer must be on the same network"
    echo "      For USB tethering, the phone connects via the computer's IP"
fi

echo ""
echo -e "${YELLOW}Quick Test:${NC}"
echo "  curl http://localhost:8081/health"
echo "  curl http://localhost:8081/api/sensors"
echo "  curl http://localhost:8081/api/inject/status"
echo ""
echo -e "${YELLOW}Logs:${NC}"
echo "  tail -f /tmp/phone_webui.log"
echo ""
