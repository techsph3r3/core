#!/bin/bash
# Enable local scaling by default in noVNC
# This makes the remote desktop automatically scale to fit the browser window

echo "🎨 Enabling local scaling by default in noVNC..."

# Modify vnc.html to have "Local scaling" selected by default
sed -i 's/<option value="scale">Local scaling<\/option>/<option value="scale" selected>Local scaling<\/option>/' \
    /opt/noVNC/vnc.html

if [ $? -eq 0 ]; then
    echo "✅ Local scaling enabled successfully"
else
    echo "❌ Failed to enable local scaling"
    exit 1
fi

# Verify the change
if grep -q '<option value="scale" selected>Local scaling</option>' /opt/noVNC/vnc.html; then
    echo "✅ Verified: Local scaling is now the default"
else
    echo "⚠️  Warning: Could not verify the change"
fi
