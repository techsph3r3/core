# CORE MCP Server

A Model Context Protocol (MCP) server that enables LLMs to generate and manipulate CORE network topologies using natural language.

## Features

- **Natural Language Topology Generation**: Describe your network in plain English, and the LLM will generate it
- **Comprehensive Node Support**: Routers, switches, hubs, hosts, wireless networks, EMANE, Docker containers
- **Link Configuration**: Set bandwidth, delay, loss, and jitter for realistic network conditions
- **Service Configuration**: Automatically configure routing protocols (OSPF, BGP), servers (HTTP, FTP, SSH), DHCP, and more
- **Multiple Output Formats**: Generate Python scripts or CORE XML files
- **Interactive Topology Building**: Add nodes and links incrementally through conversation

## Installation

```bash
cd core-mcp-server
pip install -e .
```

## Usage

### 1. Start the MCP Server

```bash
core-mcp-server
```

Or run directly with Python:

```bash
python -m core_mcp.server
```

### 2. Connect with an MCP-Compatible LLM Client

The server implements the Model Context Protocol, allowing it to be used with Claude Desktop or other MCP-compatible clients.

#### Configure Claude Desktop

Add to your Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json` on macOS):

```json
{
  "mcpServers": {
    "core-topology": {
      "command": "python",
      "args": ["-m", "core_mcp.server"],
      "cwd": "/path/to/core-mcp-server"
    }
  }
}
```

### 3. Generate Topologies with Natural Language

Once connected, you can ask the LLM to create topologies:

**Example Prompts:**

- "Create a simple network with 3 routers connected in a line"
- "Build a star topology with a switch in the center and 5 hosts"
- "Make a wireless mesh network with 4 MDR nodes"
- "Create a ring topology with 6 routers running OSPF"
- "Build a tailscale mesh with 5 docker nodes"

## Available Tools

The MCP server provides these tools to LLMs:

### `create_node`
Create a network node (router, switch, host, wireless network, etc.)

**Parameters:**
- `node_id` (int): Unique node ID
- `name` (str): Node name
- `node_type` (str): One of: router, switch, hub, host, pc, mdr, wireless, emane, docker
- `x`, `y` (float): Position coordinates
- `model` (str, optional): Node model (e.g., 'mdr' for wireless)
- `image` (str, optional): Docker image for docker nodes
- `services` (list[str]): Services to run (zebra, OSPFv2, OSPFv3, IPForward, SSH, HTTP, etc.)

### `create_link`
Create a link between two nodes

**Parameters:**
- `node1_id`, `node2_id` (int): Node IDs to connect
- `bandwidth` (int): Bandwidth in bps (default: 100Mbps)
- `delay` (int): Delay in microseconds
- `loss` (float): Loss percentage (0-100)
- `jitter` (int): Jitter in microseconds

### `set_wlan_config`
Configure a WLAN node's wireless parameters

**Parameters:**
- `node_id` (int): WLAN node ID
- `range_meters` (int): Wireless range in meters
- `bandwidth` (int): Bandwidth in bps
- `delay`, `jitter`, `loss`: Network impairments

### `generate_topology`
Generate a complete topology from natural language description

**Parameters:**
- `description` (str): Natural language description
- `output_format` (str): 'python' or 'xml'

### `save_topology`
Save the current topology to a file

**Parameters:**
- `filename` (str): Output filename (.py or .xml)
- `format` (str): 'python' or 'xml'

### `get_topology_summary`
Get a summary of the current topology

### `clear_topology`
Clear the current topology and start fresh

## Examples

### Example 1: Simple Network

```python
# Through natural language with LLM:
"Create a simple network with 3 routers in a line, each running OSPF"

# Generated output: topology.py
```

### Example 2: Wireless Mesh

```python
# Through natural language:
"Build a wireless mesh network with 5 MDR nodes arranged in a circle, with a range of 500 meters"

# Saves as: wireless_mesh.py or wireless_mesh.xml
```

### Example 3: Complex Topology

```python
# Through conversation:
User: "Create a network with a central switch"
LLM: [creates switch node 1]

User: "Add 3 routers to it, all running OSPF"
LLM: [creates router nodes 2, 3, 4 and links them to the switch]

User: "Add a wireless network with 2 MDR nodes"
LLM: [creates WLAN node 5 and MDR nodes 6, 7]

User: "Save this as my_topology.py"
LLM: [saves the complete topology]
```

## Running Generated Topologies

### Python Script

```bash
# Run the generated Python script
python topology.py
```

### XML File

```bash
# Load in CORE GUI
core-gui -f topology.xml

# Or use CLI
core-cli -f topology.xml
```

## Integration with Docker CORE Container

To use this with your Docker CORE container:

1. Install the MCP server in the container:
```dockerfile
# Add to your Dockerfile.novnc
COPY core-mcp-server /opt/core-mcp-server
RUN cd /opt/core-mcp-server && pip install -e .
```

2. Run the MCP server inside the container:
```bash
docker exec -it core-novnc core-mcp-server
```

3. Or expose it via the gRPC API by integrating with CORE's existing API

## Tailscale Mesh Support

For Tailscale mesh networks, the topology generator creates Docker nodes. You'll need to:

1. Use a Docker image with Tailscale installed (like the one in your Dockerfile.novnc)
2. Configure a custom CORE service to start Tailscale on each node
3. Use the generated topology as a starting point

Example custom service configuration needed for Tailscale nodes (not generated automatically yet):

```python
# Would need to be added as a CORE custom service
startup = [
    "tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &",
    "sleep 2",
    "tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=${NODE_NAME}"
]
```

## Architecture

```
┌─────────────────┐
│  LLM (Claude)   │
│   via MCP       │
└────────┬────────┘
         │
         │ MCP Protocol
         │
┌────────▼────────────────┐
│   CORE MCP Server       │
│  ┌──────────────────┐   │
│  │ Topology         │   │
│  │ Generator        │   │
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │ Natural Language │   │
│  │ Parser           │   │
│  └──────────────────┘   │
└────────┬────────────────┘
         │
         │ Generates
         │
    ┌────▼─────┐
    │ Python   │
    │ Script   │
    └──────────┘
         OR
    ┌──────────┐
    │   XML    │
    │   File   │
    └──────────┘
         │
         │ Loaded by
         │
    ┌────▼─────────┐
    │ CORE Daemon  │
    │   (gRPC)     │
    └──────────────┘
```

## Development

### Running Tests

```bash
pytest
```

### Code Formatting

```bash
black core_mcp/
```

### Type Checking

```bash
mypy core_mcp/
```

## Future Enhancements

- [ ] EMANE configuration support
- [ ] Custom service templates
- [ ] Mobility scenario generation
- [ ] Integration with Tailscale API for automatic mesh setup
- [ ] Topology validation and error checking
- [ ] Import existing CORE XML files
- [ ] Visual topology preview generation
- [ ] Network simulation parameter tuning

## License

Apache 2.0 - Same as CORE

## Contributing

Contributions welcome! Please submit pull requests to the CORE repository.
