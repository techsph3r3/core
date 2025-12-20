#!/bin/bash
set -e

# Configuration
URL="http://localhost:8080"
COOKIES="/tmp/cookies.txt"
FILE="sorting_twin.st" # Must match what was injected
LOGFILE="/tmp/autostart.log"

echo "[AutoStart] Starting sequence for $FILE..." > $LOGFILE

# Function to check if OpenPLC is up
wait_for_service() {
    for i in {1..30}; do
        if curl -s "$URL/login" >/dev/null; then
            echo "[AutoStart] Webserver Ready" >> $LOGFILE
            return 0
        fi
        echo "[AutoStart] Waiting for webserver..." >> $LOGFILE
        sleep 2
    done
    return 1
}

wait_for_service || exit 1

# Login
echo "[AutoStart] Logging in..." >> $LOGFILE
curl -s -c $COOKIES -b $COOKIES -X POST "$URL/login" -d "username=openplc&password=openplc" >/dev/null

# Compile
echo "[AutoStart] Compiling $FILE..." >> $LOGFILE
curl -s -c $COOKIES -b $COOKIES "$URL/compile-program?file=$FILE" >/dev/null

# Wait for compilation
echo "[AutoStart] Waiting for compilation..." >> $LOGFILE
for i in {1..30}; do
    LOGS=$(curl -s -c $COOKIES -b $COOKIES "$URL/compilation-logs")
    if echo "$LOGS" | grep -q "Compilation finished successfully"; then
        echo "[AutoStart] Compilation SUCCESS" >> $LOGFILE
        break
    fi
    if echo "$LOGS" | grep -q "Error"; then
        echo "[AutoStart] Compilation FAILED"
        echo "=== COMPILATION ERROR LOG ==="
        echo "$LOGS"
        echo "============================="
        exit 1
    fi
    sleep 2
done

# Start PLC
echo "[AutoStart] Starting PLC..." >> $LOGFILE
curl -s -c $COOKIES -b $COOKIES "$URL/start_plc" >/dev/null
sleep 2

# Verify
DASH=$(curl -s -c $COOKIES -b $COOKIES "$URL/dashboard")
if echo "$DASH" | grep -q -i "Running"; then
    echo "PLC_RUNNING"
    echo "[AutoStart] PLC is RUNNING" >> $LOGFILE
else
    echo "PLC_UNKNOWN_STATUS"
    echo "[AutoStart] PLC status unknown" >> $LOGFILE
fi
