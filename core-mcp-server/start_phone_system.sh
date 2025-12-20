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

# Step 4: Start Phone Web UI Service
echo -e "${YELLOW}[4/4] Starting Phone Web UI Service...${NC}"
sudo systemctl enable core-phone-ui
sudo systemctl restart core-phone-ui
sleep 2

if systemctl is-active --quiet core-phone-ui; then
    echo -e "  ✓ Phone Web UI service running"
else
    echo -e "  ${RED}✗ Phone Web UI service failed to start${NC}"
    sudo journalctl -u core-phone-ui -n 10 --no-pager
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Phone Sensor System Started!         ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Detect environment and show URLs
VNC_PASSWORD="core123"

# Detect External IP (GCP Metadata)
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip || echo "")
INTERNAL_IP=$(hostname -I | awk '{print $1}')

if [ -n "$CODESPACE_NAME" ]; then
    PHONE_URL="https://$CODESPACE_NAME-8081.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
    NOVNC_URL="https://$CODESPACE_NAME-6080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/vnc.html?autoconnect=true&password=${VNC_PASSWORD}"
    
    echo -e "${YELLOW}GitHub Codespace URLs:${NC}"
    echo -e "  ${CYAN}Phone Sensor Page:${NC}  ${PHONE_URL}/phone"
elif [ -n "$EXTERNAL_IP" ]; then
    # Force HTTPS for Phone Sensor on GCE
    PHONE_URL="https://${EXTERNAL_IP}:8081"
    NOVNC_URL="http://${EXTERNAL_IP}:6080/vnc.html?autoconnect=true&password=${VNC_PASSWORD}"

    echo -e "${YELLOW}GCP External IP URLs:${NC}"
    echo -e "  ${CYAN}Phone Sensor Page:${NC}  ${PHONE_URL}/phone"
    echo -e "  ${CYAN}Phone Display:${NC}      ${PHONE_URL}/phone-display (Accept Warning)"
    echo -e "  ${CYAN}noVNC Desktop:${NC}      ${NOVNC_URL}"
else
    PHONE_URL="http://${INTERNAL_IP}:8081"
    NOVNC_URL="http://${INTERNAL_IP}:6080/vnc.html?autoconnect=true&password=${VNC_PASSWORD}"

    echo -e "${YELLOW}Local/Internal URLs:${NC}"
    echo -e "  ${CYAN}Phone Sensor Page:${NC}  ${PHONE_URL}/phone"
    echo -e "  ${CYAN}Phone Display:${NC}      ${PHONE_URL}/phone-display" 
fi

echo ""
echo -e "${YELLOW}QR Code Connection:${NC}"
echo "  1. Open the Phone Sensor Page on your phone"
echo "  2. Grant permissions and click Start"
echo ""

echo ""
echo -e "${YELLOW}Quick Test:${NC}"
echo "  curl http://localhost:8081/health"
echo "  curl http://localhost:8081/api/sensors"
echo "  curl http://localhost:8081/api/inject/status"
echo ""
echo -e "${YELLOW}Logs:${NC}"
echo "  tail -f /tmp/phone_webui.log"
echo ""
