#!/bin/bash
# CORE Runtime Hook: Automatic VNC Proxy Setup
# This script is executed when a CORE session enters RUNTIME_STATE
# It sets up VNC proxy chains for all HMI/workstation nodes
#
# Session States (from CORE's EventTypes):
#   1 = DEFINITION_STATE
#   2 = CONFIGURATION_STATE
#   3 = INSTANTIATION_STATE
#   4 = RUNTIME_STATE (this is when we run)
#   5 = DATACOLLECT_STATE
#   6 = SHUTDOWN_STATE

LOG_FILE="/tmp/vnc_proxy_setup.log"
WEB_UI_URL="http://localhost:8080"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== VNC Proxy Setup Hook Started ==="
log "Session directory: $SESSION_DIR"
log "Session ID: $SESSION"

# Wait for containers to fully initialize
log "Waiting 5 seconds for containers to initialize..."
sleep 5

# Find VNC-capable containers (HMI, workstation, desktop, kali nodes)
VNC_PATTERNS="hmi|workstation|desktop|kali|engineering"

log "Searching for VNC-capable containers..."
CONTAINERS=$(docker ps --format '{{.Names}}' | grep -iE "$VNC_PATTERNS" | grep -v "core-novnc")

if [ -z "$CONTAINERS" ]; then
    log "No VNC-capable containers found"
    exit 0
fi

log "Found VNC-capable containers:"
echo "$CONTAINERS" | while read container; do
    log "  - $container"
done

# Set up VNC proxy for each container via the web UI API
PORT=6081
echo "$CONTAINERS" | while read container; do
    if [ -z "$container" ]; then
        continue
    fi

    log "Setting up VNC proxy for $container on port $PORT..."

    # Call the web UI API to set up the VNC proxy
    RESPONSE=$(curl -s -X POST "$WEB_UI_URL/api/start-host-vnc" \
        -H "Content-Type: application/json" \
        -d "{\"node_name\": \"$container\"}" \
        2>&1)

    if echo "$RESPONSE" | grep -q '"success":\s*true'; then
        VNC_PORT=$(echo "$RESPONSE" | grep -oP '"proxy_port":\s*\K\d+')
        log "  SUCCESS: VNC proxy for $container on port $VNC_PORT"
    else
        log "  WARNING: Failed to set up VNC for $container: $RESPONSE"
    fi

    PORT=$((PORT + 1))

    # Don't exceed port 6089
    if [ $PORT -gt 6089 ]; then
        log "WARNING: Exceeded maximum VNC proxy ports (6089)"
        break
    fi
done

log "=== VNC Proxy Setup Hook Complete ==="
exit 0
