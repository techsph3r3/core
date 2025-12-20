#!/bin/bash
set -e

# Configuration
URL="http://localhost:8080"
USER="openplc"
PASS="openplc"
ST_FILE="/tmp/sorting_twin.st"
COOKIES="/tmp/cookies.txt"

echo "Logging in..."
curl -s -c $COOKIES -b $COOKIES -X POST "$URL/login" -d "username=$USER&password=$PASS"

echo "Uploading program..."
# Note: 'file' field name is usually 'file' or 'program_file'. 
# Based on OpenPLC webserver references, it's often 'file' in the form data.
curl -s -c $COOKIES -b $COOKIES -X POST "$URL/upload-program-action" \
  -F "file=@$ST_FILE" \
  -F "program_name=Sorting Facility" \
  -F "program_descr=Sorting Logic from API" \
  -F "program_file=sorting_twin.st"

echo "Compiling program..."
curl -s -c $COOKIES -b $COOKIES -X GET "$URL/compile-program?file=sorting_twin.st" > /dev/null

echo "Waiting for compilation..."
sleep 5
# Loop check logs
for i in {1..20}; do
    LOGS=$(curl -s -c $COOKIES -b $COOKIES "$URL/compilation-logs")
    if echo "$LOGS" | grep -q "Compilation finished successfully"; then
        echo "Compilation Success!"
        break
    fi
    if echo "$LOGS" | grep -q "Error"; then
        echo "Compilation Failed!"
        echo "$LOGS" | grep "Error"
        exit 1
    fi
    echo "Compiling..."
    sleep 2
done

echo "Starting PLC..."
curl -s -c $COOKIES -b $COOKIES "$URL/start_plc" > /dev/null
sleep 2

DASH=$(curl -s -c $COOKIES -b $COOKIES "$URL/dashboard")
if echo "$DASH" | grep -q -i "Running"; then
    echo "PLC is Running!"
else
    echo "Warning: PLC status unknown."
fi
