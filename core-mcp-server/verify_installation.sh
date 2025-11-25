#!/bin/bash
# Verification script for CORE MCP Server installation

echo "======================================================================"
echo "CORE MCP Server - Installation Verification"
echo "======================================================================"
echo ""

# Check Python version
echo "[1/6] Checking Python version..."
python3 --version
if [ $? -eq 0 ]; then
    echo "✓ Python 3 is installed"
else
    echo "✗ Python 3 is not installed"
    exit 1
fi
echo ""

# Check if we can import the module
echo "[2/6] Checking if core_mcp module is available..."
python3 -c "from core_mcp.topology_generator import TopologyGenerator; print('✓ Module import successful')" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ core_mcp module is available"
else
    echo "✗ core_mcp module is not installed"
    echo "  Run: pip install -e /workspaces/core/core-mcp-server"
    exit 1
fi
echo ""

# Check if MCP dependencies are available
echo "[3/6] Checking MCP dependencies..."
python3 -c "import mcp; print('✓ MCP installed')" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ MCP library is available"
else
    echo "⚠ MCP library is not installed (optional for direct Python usage)"
fi
echo ""

# Test topology generation
echo "[4/6] Testing topology generation..."
cd /workspaces/core/core-mcp-server
python3 test_topology_gen.py > /tmp/verify_output.txt 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Topology generation successful"
else
    echo "✗ Topology generation failed"
    cat /tmp/verify_output.txt
    exit 1
fi
echo ""

# Check generated files
echo "[5/6] Verifying generated topology files..."
FILES=(
    "/tmp/test_star_topology.py"
    "/tmp/test_star_topology.xml"
    "/tmp/test_wireless_mesh.py"
    "/tmp/test_wireless_mesh.xml"
    "/tmp/test_tailscale_mesh.py"
    "/tmp/test_tailscale_mesh.xml"
)

ALL_FOUND=true
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file not found"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = false ]; then
    exit 1
fi
echo ""

# Summary
echo "[6/6] Installation Summary"
echo "======================================================================"
echo "✓ CORE MCP Server is properly installed and working!"
echo ""
echo "Generated topology files:"
echo "  - /tmp/test_star_topology.py (and .xml)"
echo "  - /tmp/test_wireless_mesh.py (and .xml)"
echo "  - /tmp/test_tailscale_mesh.py (and .xml)"
echo ""
echo "Example topology (first 30 lines of wireless mesh):"
echo "----------------------------------------------------------------------"
head -30 /tmp/test_wireless_mesh.py
echo "..."
echo "----------------------------------------------------------------------"
echo ""
echo "Next Steps:"
echo "  1. Review the documentation:"
echo "     - README.md (complete documentation)"
echo "     - QUICKSTART.md (5-minute setup)"
echo "     - DEPLOYMENT.md (Docker integration)"
echo ""
echo "  2. Try generating a custom topology:"
echo "     python3 -c \"from core_mcp.topology_generator import TopologyGenerator; \\"
echo "       gen = TopologyGenerator(); \\"
echo "       gen.generate_from_description('Create a ring of 5 routers'); \\"
echo "       print(gen.get_summary())\""
echo ""
echo "  3. Integrate with your Docker CORE container"
echo "     See DEPLOYMENT.md for detailed instructions"
echo ""
echo "======================================================================"
