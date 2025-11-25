#!/usr/bin/env python3
"""
Test script for topology generator - generates a sample topology
without needing the MCP server running.
"""

import sys
sys.path.insert(0, '/workspaces/core/core-mcp-server')

from core_mcp.topology_generator import TopologyGenerator

# Create generator
generator = TopologyGenerator()

# Test 1: Generate a simple star topology
print("=" * 60)
print("Test 1: Generating star topology from natural language")
print("=" * 60)
result = generator.generate_from_description(
    "Create a star topology with a switch in the center and 4 routers"
)
print(f"Result: {result}")
print(f"\nSummary:\n{generator.get_summary()}")

# Save as Python script
python_script = generator.to_python_script()
with open("/tmp/test_star_topology.py", "w") as f:
    f.write(python_script)
print("\nSaved Python script to: /tmp/test_star_topology.py")

# Save as XML
xml_content = generator.to_xml()
with open("/tmp/test_star_topology.xml", "w") as f:
    f.write(xml_content)
print("Saved XML to: /tmp/test_star_topology.xml")

# Test 2: Generate a wireless mesh
print("\n" + "=" * 60)
print("Test 2: Generating wireless mesh topology")
print("=" * 60)
generator.clear()
result = generator.generate_from_description(
    "Create a wireless mesh network with 5 MDR nodes"
)
print(f"Result: {result}")
print(f"\nSummary:\n{generator.get_summary()}")

# Save as Python script
python_script = generator.to_python_script()
with open("/tmp/test_wireless_mesh.py", "w") as f:
    f.write(python_script)
print("\nSaved Python script to: /tmp/test_wireless_mesh.py")

# Save as XML
xml_content = generator.to_xml()
with open("/tmp/test_wireless_mesh.xml", "w") as f:
    f.write(xml_content)
print("Saved XML to: /tmp/test_wireless_mesh.xml")

# Test 3: Generate a Tailscale mesh
print("\n" + "=" * 60)
print("Test 3: Generating Tailscale mesh topology")
print("=" * 60)
generator.clear()
result = generator.generate_from_description(
    "Create a tailscale mesh with 3 docker nodes"
)
print(f"Result: {result}")
print(f"\nSummary:\n{generator.get_summary()}")

# Save as Python script
python_script = generator.to_python_script()
with open("/tmp/test_tailscale_mesh.py", "w") as f:
    f.write(python_script)
print("\nSaved Python script to: /tmp/test_tailscale_mesh.py")

# Save as XML
xml_content = generator.to_xml()
with open("/tmp/test_tailscale_mesh.xml", "w") as f:
    f.write(xml_content)
print("Saved XML to: /tmp/test_tailscale_mesh.xml")

print("\n" + "=" * 60)
print("All tests completed successfully!")
print("=" * 60)
print("\nGenerated files:")
print("  - /tmp/test_star_topology.py")
print("  - /tmp/test_star_topology.xml")
print("  - /tmp/test_wireless_mesh.py")
print("  - /tmp/test_wireless_mesh.xml")
print("  - /tmp/test_tailscale_mesh.py")
print("  - /tmp/test_tailscale_mesh.xml")
