# Quick Start Guide

## 5-Minute Setup

### 1. Install the MCP Server

```bash
cd /workspaces/core/core-mcp-server
pip install -e .
```

### 2. Generate a Topology

```bash
python test_topology_gen.py
```

This creates several example topologies in `/tmp/`:
- Star topology with switch and routers
- Wireless mesh with MDR nodes
- Tailscale mesh with Docker nodes

### 3. View Generated Files

```bash
cat /tmp/test_wireless_mesh.py
cat /tmp/test_wireless_mesh.xml
```

### 4. Run in CORE (if CORE is installed)

```bash
# If you're in the Docker container with CORE:
/opt/core/venv/bin/python /tmp/test_wireless_mesh.py

# Or load the XML in the GUI:
core-gui -f /tmp/test_wireless_mesh.xml
```

## Using with Claude Desktop

### 1. Add to Claude Desktop Config

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "core-topology": {
      "command": "python",
      "args": ["-m", "core_mcp.server"],
      "cwd": "/workspaces/core/core-mcp-server"
    }
  }
}
```

### 2. Restart Claude Desktop

The MCP server will now be available as a tool.

### 3. Try It Out

Ask Claude:

> "Create a wireless mesh network with 5 MDR nodes and save it as my_mesh.py"

Claude will use the MCP tools to generate the topology!

## Using Programmatically

```python
from core_mcp.topology_generator import TopologyGenerator

# Create generator
gen = TopologyGenerator()

# Method 1: Natural language
gen.generate_from_description("Create a ring of 6 routers running OSPF")
print(gen.get_summary())

# Method 2: Manual construction
from core_mcp.topology_generator import NodeConfig, LinkConfig

# Add nodes
gen.add_node(NodeConfig(
    node_id=1,
    name="router1",
    node_type="router",
    x=100, y=100,
    services=["zebra", "OSPFv2", "IPForward"]
))

gen.add_node(NodeConfig(
    node_id=2,
    name="router2",
    node_type="router",
    x=300, y=100,
    services=["zebra", "OSPFv2", "IPForward"]
))

# Add link
gen.add_link(LinkConfig(
    node1_id=1,
    node2_id=2,
    bandwidth=1000000000,  # 1 Gbps
    delay=5000  # 5ms
))

# Export
python_script = gen.to_python_script()
xml_content = gen.to_xml()

# Save
with open("my_topology.py", "w") as f:
    f.write(python_script)
```

## Common Natural Language Patterns

The topology generator understands these patterns:

### Star Topology
- "Create a star with a switch and 5 hosts"
- "Build a hub and spoke network with 4 routers"

### Line/Chain Topology
- "Create 5 routers in a line"
- "Build a chain of 3 routers running OSPF"

### Ring Topology
- "Create a ring of 6 routers"
- "Build a circular network with 4 hosts"

### Wireless Mesh
- "Create a wireless mesh with 5 MDR nodes"
- "Build a WLAN network with 4 wireless routers"

### Tailscale Mesh
- "Create a tailscale mesh with 3 docker nodes"
- "Build a docker mesh network for VPN testing"

## Next Steps

1. **Customize Topologies**: Modify the generated Python scripts to add custom configurations
2. **Create Templates**: Build common topology templates for reuse
3. **Integrate with CI/CD**: Automate topology generation in your testing pipeline
4. **Add Custom Services**: Create CORE custom services for Tailscale, monitoring tools, etc.

## Troubleshooting

**Q: "ModuleNotFoundError: No module named 'core'"**

A: You need to run the script with CORE's Python environment:
```bash
/opt/core/venv/bin/python script.py
```

**Q: "Connection refused to localhost:50051"**

A: The CORE daemon isn't running. Start it:
```bash
core-daemon
```

**Q: "Unknown node id None"**

A: This error occurs with improperly structured topologies. Use the MCP-generated topologies which handle node IDs correctly. See DEPLOYMENT.md for details.

## Examples Gallery

Check the `examples/` directory for:
- Simple 3-router network
- Complex enterprise topology
- Wireless sensor network
- Data center fabric
- Tailscale mesh VPN

## API Reference

See the full API documentation in the docstrings:

```python
from core_mcp.topology_generator import TopologyGenerator
help(TopologyGenerator)
```
