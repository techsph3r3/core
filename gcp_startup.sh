#!/bin/bash
# gcp_startup.sh - Robust startup script for Makau CORE on GCP

ZONE="us-central1-a"
INSTANCE="makau-core"

echo "=== Makau CORE GCP Startup ==="

# 1. Start VM
echo "Step 1: Checking VM status..."
STATUS=$(gcloud compute instances describe $INSTANCE --zone=$ZONE --format='get(status)' 2>/dev/null)

if [ "$STATUS" == "RUNNING" ]; then
    echo "  VM is already running."
elif [ "$STATUS" == "TERMINATED" ]; then
    echo "  Starting VM..."
    gcloud compute instances start $INSTANCE --zone=$ZONE
    echo "  Waiting for VM to initialize (30s)..."
    sleep 30
else
    echo "  VM status is $STATUS. Attempting start..."
    gcloud compute instances start $INSTANCE --zone=$ZONE
fi

# 2. Get IP
IP=$(gcloud compute instances describe $INSTANCE --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "  VM External IP: $IP"

# 3. Check/Start Services via SSH
echo "Step 2: verifying Services on VM..."

COMMAND="
    # Check Docker
    if ! docker ps >/dev/null 2>&1; then
        echo '  Starting Docker...'
        sudo service docker start
        sleep 5
    fi

    # Check Core Container
    if ! docker ps --format '{{.Names}}' | grep -q 'core-novnc'; then
        echo '  Starting CORE container...'
        cd ~/makau_core/core/dockerfiles
        docker-compose -f docker-compose.novnc.yml up -d
        sleep 10
    else
        echo '  CORE container is running.'
    fi

    # Check Web UI
    if ! pgrep -f 'web_ui.py' >/dev/null; then
        echo '  Starting Web UI...'
        cd ~/makau_core/core/core-mcp-server
        nohup python3 web_ui.py > ../web_ui.log 2>&1 &
        sleep 2
    else
        echo '  Web UI is running.'
    fi
"

gcloud compute ssh $INSTANCE --zone=$ZONE --command "$COMMAND"

echo ""
echo "=== Startup Complete ==="
echo "Access the Dashboard at: http://$IP:8080"
echo "If the GUI is blank, refresh the browser page."
