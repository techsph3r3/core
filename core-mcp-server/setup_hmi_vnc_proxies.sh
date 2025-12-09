#!/bin/bash
# HMI VNC Proxy Setup Script
# Sets up websockify/socat proxy chain for Docker containers with VNC inside CORE
#
# Architecture:
#   Browser -> :8080/hmi-vnc/<port>/websockify -> web_ui.py
#   -> websockify (608X) -> socat (1608X) -> nsenter -> x11vnc (5900)
#
# This script finds HMI containers (containers with x11vnc running) and creates
# proxy chains for each one.

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  HMI VNC Proxy Setup                  ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if core-novnc is running
if ! docker ps --format '{{.Names}}' | grep -q "^core-novnc$"; then
    echo -e "${RED}Error: core-novnc container is not running${NC}"
    exit 1
fi

# Get list of HMI containers (those running x11vnc on port 5900)
# Excludes the core-novnc container itself which is the CORE GUI host
echo -e "${YELLOW}Finding HMI containers with VNC...${NC}"
HMI_CONTAINERS=$(docker exec core-novnc docker ps --format '{{.Names}}' 2>/dev/null | while read container; do
    # Skip the core-novnc container itself (that's the CORE GUI, not an HMI)
    if [ "$container" = "core-novnc" ]; then
        continue
    fi
    # Check if container has x11vnc running (indicates VNC capability)
    if docker exec core-novnc docker exec "$container" pgrep -f "x11vnc" >/dev/null 2>&1; then
        echo "$container"
    fi
done)

if [ -z "$HMI_CONTAINERS" ]; then
    echo -e "${YELLOW}No HMI containers found with VNC${NC}"
    echo "Looking for containers with x11vnc or Xvfb..."
    docker exec core-novnc docker ps --format '{{.Names}}: {{.Image}}'
    exit 0
fi

echo -e "${GREEN}Found HMI containers:${NC}"
echo "$HMI_CONTAINERS" | while read c; do echo "  - $c"; done
echo ""

# Port mapping: each HMI gets a websockify port starting at 6081
PORT=6081
SOCAT_PORT=16081

echo "$HMI_CONTAINERS" | while read CONTAINER; do
    echo -e "${YELLOW}Setting up proxy for $CONTAINER on port $PORT...${NC}"

    # Get container PID
    PID=$(docker exec core-novnc docker inspect "$CONTAINER" --format '{{.State.Pid}}' 2>/dev/null)
    if [ -z "$PID" ] || [ "$PID" == "<no value>" ]; then
        echo -e "  ${RED}Could not get PID for $CONTAINER, skipping${NC}"
        PORT=$((PORT + 1))
        SOCAT_PORT=$((SOCAT_PORT + 1))
        continue
    fi
    echo "  Container PID: $PID"

    # Kill any existing proxy for this port
    docker exec core-novnc pkill -f "websockify.*$PORT" 2>/dev/null || true
    docker exec core-novnc pkill -f "socat.*$SOCAT_PORT" 2>/dev/null || true
    sleep 0.5

    # Create nsenter script that connects to x11vnc (port 5900)
    docker exec core-novnc bash -c "cat > /tmp/ns_forward_$PORT.sh << 'EOFSCRIPT'
#!/bin/sh
exec nsenter -n -t $PID socat STDIO TCP:localhost:5900
EOFSCRIPT
chmod +x /tmp/ns_forward_$PORT.sh"

    echo "  Created /tmp/ns_forward_$PORT.sh"

    # Start socat to forward to nsenter script
    docker exec -d core-novnc socat TCP-LISTEN:$SOCAT_PORT,fork,reuseaddr EXEC:/tmp/ns_forward_$PORT.sh
    echo "  Started socat on port $SOCAT_PORT"

    # Start websockify to connect to socat
    docker exec -d core-novnc python3 -m websockify --web /opt/noVNC $PORT localhost:$SOCAT_PORT
    echo "  Started websockify on port $PORT"

    echo -e "  ${GREEN}Proxy ready: ws://localhost:8080/hmi-vnc/$PORT/websockify${NC}"
    echo ""

    PORT=$((PORT + 1))
    SOCAT_PORT=$((SOCAT_PORT + 1))
done

# Verify processes
echo -e "${YELLOW}Verifying proxy processes...${NC}"
sleep 1
docker exec core-novnc pgrep -af "websockify.*608[1-9]" || echo "No websockify processes for HMI ports"
docker exec core-novnc pgrep -af "socat.*1608" || echo "No socat processes for HMI ports"
echo ""

# Show access URLs
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  VNC Proxy Setup Complete             ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ -n "$CODESPACE_NAME" ]; then
    BASE_URL="https://$CODESPACE_NAME-8080.$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN"
else
    BASE_URL="http://localhost:8080"
fi

echo -e "${CYAN}Access HMI VNC through port 8080:${NC}"
PORT=6081
echo "$HMI_CONTAINERS" | while read CONTAINER; do
    echo "  $CONTAINER: $BASE_URL/hmi-vnc/$PORT/vnc_lite.html?path=hmi-vnc/$PORT/websockify"
    PORT=$((PORT + 1))
done
echo ""
