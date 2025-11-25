#!/usr/bin/env python3
"""
Generate a production-ready Tailscale mesh topology for CORE.

This script creates a properly structured Tailscale mesh network that:
- Avoids the "unknown node id None" error
- Uses explicit node IDs
- Configures Docker nodes properly
- Includes a management network for initial access
- Provides both Python and XML output
"""

import sys
import os

# Add the module to path
sys.path.insert(0, os.path.dirname(__file__))

from core_mcp.topology_generator import TopologyGenerator, NodeConfig, LinkConfig

def create_tailscale_mesh(num_nodes=5, include_mgmt_network=True):
    """
    Create a Tailscale mesh topology.

    Args:
        num_nodes: Number of Tailscale nodes to create
        include_mgmt_network: Whether to include a management network

    Returns:
        TopologyGenerator instance
    """
    gen = TopologyGenerator()
    gen.session_name = "Tailscale Mesh Network"

    # Node ID counter
    node_id = 1

    # Create management switch if requested
    mgmt_switch_id = None
    if include_mgmt_network:
        mgmt_switch = NodeConfig(
            node_id=100,
            name="mgmt-switch",
            node_type="switch",
            x=400.0,
            y=50.0
        )
        gen.add_node(mgmt_switch)
        mgmt_switch_id = 100

    # Create Tailscale nodes in a grid layout
    tailscale_nodes = []
    cols = 3
    start_x = 200.0
    start_y = 200.0
    spacing_x = 250.0
    spacing_y = 200.0

    for i in range(num_nodes):
        row = i // cols
        col = i % cols
        x = start_x + col * spacing_x
        y = start_y + row * spacing_y

        node = NodeConfig(
            node_id=node_id,
            name=f"ts-node{node_id}",
            node_type="docker",
            image="ubuntu:22.04",
            x=x,
            y=y,
            services=["DefaultRoute"]  # Tailscale service will be added later
        )
        gen.add_node(node)
        tailscale_nodes.append(node_id)

        # Connect to management network if it exists
        if mgmt_switch_id:
            link = LinkConfig(
                node1_id=mgmt_switch_id,
                node2_id=node_id,
                iface2_id=0,
                ip4_2=f"192.168.0.{node_id}",
                bandwidth=1000000000,  # 1 Gbps
                delay=0,
                loss=0.0
            )
            gen.add_link(link)

        node_id += 1

    return gen, tailscale_nodes


def main():
    """Generate and save the Tailscale mesh topology."""
    import argparse

    parser = argparse.ArgumentParser(description="Generate Tailscale mesh topology for CORE")
    parser.add_argument("--nodes", type=int, default=5, help="Number of Tailscale nodes (default: 5)")
    parser.add_argument("--no-mgmt", action="store_true", help="Don't include management network")
    parser.add_argument("--output", default="/tmp/tailscale_mesh", help="Output file prefix (default: /tmp/tailscale_mesh)")
    args = parser.parse_args()

    print("=" * 70)
    print(f"Generating Tailscale Mesh Topology")
    print("=" * 70)
    print(f"Nodes: {args.nodes}")
    print(f"Management Network: {'No' if args.no_mgmt else 'Yes'}")
    print(f"Output: {args.output}.py and {args.output}.xml")
    print()

    # Generate topology
    gen, node_ids = create_tailscale_mesh(
        num_nodes=args.nodes,
        include_mgmt_network=not args.no_mgmt
    )

    # Show summary
    print("Topology Summary:")
    print("-" * 70)
    print(gen.get_summary())
    print()

    # Generate Python script
    python_script = gen.to_python_script()

    # Add Tailscale-specific setup to the Python script
    tailscale_setup = f"""
# Tailscale Setup Instructions
# =============================
# After the session starts, configure Tailscale on each node:
#
# For each node (replace NODE_ID and NODE_NAME):
#   docker exec ts-nodeNODE_ID tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &
#   docker exec ts-nodeNODE_ID tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname=ts-nodeNODE_ID
#
# Or set TAILSCALE_AUTHKEY environment variable before running this script:
#   export TAILSCALE_AUTHKEY=tskey-auth-xxxxx
#   python {os.path.basename(args.output)}.py
#
# Management Network Access:
#   Each node is accessible via 192.168.0.X where X is the node ID
#   SSH into nodes: docker exec -it ts-nodeX bash
"""

    python_script = python_script.replace(
        'print("Session started successfully!")',
        f'''print("Session started successfully!")
print("""
{tailscale_setup}
""")'''
    )

    # Save Python script
    py_file = f"{args.output}.py"
    with open(py_file, "w") as f:
        f.write(python_script)
    print(f"✓ Saved Python script: {py_file}")

    # Save XML
    xml_content = gen.to_xml()
    xml_file = f"{args.output}.xml"
    with open(xml_file, "w") as f:
        f.write(xml_content)
    print(f"✓ Saved XML file: {xml_file}")

    print()
    print("=" * 70)
    print("Generation Complete!")
    print("=" * 70)
    print()
    print("To use this topology:")
    print()
    print("1. In CORE GUI:")
    print(f"   core-gui -f {xml_file}")
    print()
    print("2. Via Python script:")
    print(f"   /opt/core/venv/bin/python {py_file}")
    print()
    print("3. Setup Tailscale on each node:")
    print("   See the instructions in the generated Python script")
    print()
    print("Note: This topology uses EXPLICIT node IDs to avoid the")
    print("      'unknown node id None' error.")
    print()


if __name__ == "__main__":
    main()
