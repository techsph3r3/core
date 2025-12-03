#!/bin/bash
# IoT Sensor System - Complete Startup Script
# This script starts all services needed for the micro:bit IoT system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  IoT Sensor System - Startup Script   ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Step 1: Check if core-novnc container is running
echo -e "${YELLOW}[1/5] Checking core-novnc container...${NC}"
if docker ps --format '{{.Names}}' | grep -q "^core-novnc$"; then
    echo -e "  ✓ core-novnc is running"
else
    echo -e "  ${RED}✗ core-novnc not running. Starting...${NC}"
    docker start core-novnc || docker run -d --name core-novnc --privileged \
        -p 6080:6080 -p 5901:5901 -p 50051:50051 \
        core-novnc:latest
    sleep 5
fi

# Step 2: Load IoT topology into CORE
echo -e "${YELLOW}[2/5] Loading IoT topology into CORE...${NC}"
if [ -f "/tmp/iot_topology.xml" ]; then
    docker cp /tmp/iot_topology.xml core-novnc:/tmp/iot_topology.xml
    docker cp load_topology.py core-novnc:/tmp/load_topology.py
    docker exec core-novnc /opt/core/venv/bin/python3 /tmp/load_topology.py /tmp/iot_topology.xml 2>/dev/null || true
    echo -e "  ✓ Topology loaded"
else
    echo -e "  ${RED}✗ No topology file found at /tmp/iot_topology.xml${NC}"
    echo -e "  Generate one using the Web UI at /topology-generator"
fi

# Step 3: Verify CORE nodes are running
echo -e "${YELLOW}[3/5] Verifying CORE nodes...${NC}"
sleep 3
NODES=$(docker exec core-novnc docker ps --format '{{.Names}}' 2>/dev/null | grep -E "mqtt-broker|sensor-server|hmi1" | wc -l)
if [ "$NODES" -ge 3 ]; then
    echo -e "  ✓ All CORE nodes running ($NODES/3)"
    docker exec core-novnc docker ps --format '  - {{.Names}}: {{.Status}}' 2>/dev/null | grep -E "mqtt-broker|sensor-server|hmi1"
else
    echo -e "  ${YELLOW}⚠ Only $NODES/3 nodes running${NC}"
fi

# Step 4: Start Web UI
echo -e "${YELLOW}[4/5] Starting Web UI (port 8080)...${NC}"
pkill -f "web_ui.py" 2>/dev/null || true
sleep 1
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
sleep 2
if pgrep -f "web_ui.py" > /dev/null; then
    echo -e "  ✓ Web UI running on port 8080"
else
    echo -e "  ${RED}✗ Web UI failed to start${NC}"
    tail -5 /tmp/webui.log
fi

# Step 5: Start MQTT Injector
echo -e "${YELLOW}[5/5] Starting MQTT Injector (port 8089)...${NC}"
pkill -f "core_mqtt_injector.py" 2>/dev/null || true
sleep 1
nohup python3 core_mqtt_injector.py \
    --session 1 \
    --broker-node mqtt-broker \
    --broker-ip 10.0.1.10 \
    --docker-host core-novnc \
    --port 8089 > /tmp/injector.log 2>&1 &
sleep 2
if pgrep -f "core_mqtt_injector.py" > /dev/null; then
    echo -e "  ✓ MQTT Injector running on port 8089"
else
    echo -e "  ${RED}✗ MQTT Injector failed to start${NC}"
    tail -5 /tmp/injector.log
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  System Started!                      ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Detect environment and show URLs
if [ -n "$CODESPACE_NAME" ]; then
    echo -e "${YELLOW}GitHub Codespace URLs:${NC}"
    echo "  Micro:bit Page:  https://$CODESPACE_NAME-8080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/microbit"
    echo "  Sensor Display:  https://$CODESPACE_NAME-8080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/sensor-display"
    echo "  noVNC Desktop:   https://$CODESPACE_NAME-6080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
    echo "  Injector Status: https://$CODESPACE_NAME-8089.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN/status"
    echo ""
    echo -e "${YELLOW}Note:${NC} Make sure ports 6080, 8080, 8089 are set to 'Public' in Codespace port settings"
else
    echo -e "${YELLOW}Local URLs:${NC}"
    echo "  Micro:bit Page:  http://localhost:8080/microbit"
    echo "  Sensor Display:  http://localhost:8080/sensor-display"
    echo "  noVNC Desktop:   http://localhost:6080"
    echo "  Injector Status: http://localhost:8089/status"
fi

echo ""
echo -e "${YELLOW}Quick Test:${NC}"
echo "  curl http://localhost:8089/status"
echo "  curl -X POST http://localhost:8089/inject/test -H 'Content-Type: application/json' -d '{\"x\":1,\"y\":2,\"z\":3}'"
echo ""
