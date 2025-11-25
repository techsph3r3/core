#!/bin/bash
# Start the CORE Topology Generator Web UI

# Set up environment
export PYTHONPATH="/workspaces/core/core-mcp-server:$PYTHONPATH"

cd "$(dirname "$0")"

echo "🌐 Starting CORE Topology Generator Web UI..."
echo "================================================"
echo ""
echo "Access the Web UI at:"
echo "  • Local: http://localhost:8080"
echo "  • Network: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "Press Ctrl+C to stop"
echo "================================================"
echo ""

# Start the server
python3 web_ui.py
