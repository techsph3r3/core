# Using CORE MCP Server with a Real LLM

## What is MCP?

**Model Context Protocol (MCP)** is Anthropic's protocol that allows **Large Language Models (LLMs)** to interact with external tools and data sources in real-time during conversations.

### Architecture

```
┌──────────────────┐                          ┌────────────────────┐
│                  │    MCP Protocol          │                    │
│   LLM Client     │   (JSON-RPC)             │   MCP Server       │
│                  │  ◄──────────────────►    │                    │
│  Claude Desktop  │     over stdio           │  core_mcp/server   │
│  or Other Client │                          │  .py               │
└──────────────────┘                          └────────────────────┘
         │                                             │
         │  User: "Create a star                      │
         │   with 5 hosts"                            │
         │                                             ▼
         │                                    ┌────────────────────┐
         │                                    │  Topology          │
         │  LLM: calls generate_topology()   │  Generator         │
         │                                    │  (Business Logic)  │
         └────────────────────────────────────┤                    │
                                              └────────────────────┘
```

## How MCP Works

1. **User** speaks in natural language to the LLM
   - "Create a ring with 6 routers"
   - "Build a wireless mesh with 8 nodes"

2. **LLM** sees available MCP tools and intelligently decides which to use
   - `generate_topology` - for complete topologies
   - `create_node` - for adding individual nodes
   - `create_link` - for connecting nodes
   - `get_topology_summary` - to check current state

3. **MCP Server** executes the tool and returns results
   - Generates XML or Python scripts
   - Returns topology summary

4. **LLM** receives results and presents them to the user
   - Shows the generated topology
   - Can iterate based on user feedback

---

## Setup Guide: Using with Claude Desktop

### Prerequisites

- Claude Desktop app installed
- Python 3.8+ with the MCP server
- CORE network emulator (for running generated topologies)

### Step 1: Install Dependencies

```bash
cd /workspaces/core/core-mcp-server

# Install Python dependencies
pip install mcp pydantic
```

### Step 2: Configure Claude Desktop

#### On macOS:

Edit the config file:
```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

#### On Linux:

```bash
nano ~/.config/Claude/claude_desktop_config.json
```

#### On Windows:

```
%APPDATA%\Claude\claude_desktop_config.json
```

### Step 3: Add MCP Server Configuration

Add this configuration to the JSON file:

```json
{
  "mcpServers": {
    "core-topology": {
      "command": "python3",
      "args": [
        "-m",
        "core_mcp.server"
      ],
      "cwd": "/workspaces/core/core-mcp-server",
      "env": {
        "PYTHONPATH": "/workspaces/core/core-mcp-server"
      }
    }
  }
}
```

**Adjust the `cwd` path to match your installation location.**

### Step 4: Restart Claude Desktop

Close and reopen Claude Desktop to load the MCP server.

### Step 5: Verify MCP Server is Loaded

In Claude Desktop, you should see:
- A small indicator showing MCP servers are available
- When you ask topology-related questions, Claude will use the MCP tools

---

## Usage Examples with LLM

### Example 1: Simple Network

**You:**
> Create a simple star topology with a switch and 5 hosts. Make sure they're on the same subnet.

**Claude (using MCP):**
- Calls `generate_topology` with description
- Returns XML and topology summary
- Shows you the generated network
- All hosts on 10.0.1.0/24 subnet (correct Layer 2 behavior)

### Example 2: Router Network

**You:**
> I need a ring of 6 routers running OSPF. Each link should be a separate subnet.

**Claude (using MCP):**
- Calls `generate_topology("Create a ring with 6 routers")`
- Returns topology with proper routing configuration
- Each router-to-router link on separate subnet (correct Layer 3 behavior)

### Example 3: Wireless Network

**You:**
> Build a wireless mesh network with 8 MDR nodes for ad-hoc routing.

**Claude (using MCP):**
- Calls `generate_topology` for wireless mesh
- Returns WLAN + MDR nodes configuration
- All MDR nodes on same subnet (correct wireless behavior)

### Example 4: Iterative Design

**You:**
> Create a basic network with 3 routers in a line.

**Claude:** (generates topology)

**You:**
> Now add a wireless access point connected to router 2, with 4 MDR nodes.

**Claude (using MCP):**
- Calls `create_node` to add WLAN
- Calls `create_link` to connect to router 2
- Calls `create_node` multiple times for MDR nodes
- Returns updated topology

---

## Available MCP Tools

The LLM has access to these tools:

### 1. `generate_topology`
```json
{
  "description": "Natural language description",
  "output_format": "xml" or "python"
}
```

Generates complete topology from description like:
- "Create a star with 5 hosts"
- "Build a ring with 6 routers"
- "Make a wireless mesh with 8 MDR nodes"

### 2. `create_node`
```json
{
  "node_id": 1,
  "name": "router1",
  "node_type": "router",
  "x": 100.0,
  "y": 100.0,
  "services": ["zebra", "OSPFv2", "IPForward"]
}
```

Adds individual nodes to the topology.

### 3. `create_link`
```json
{
  "node1_id": 1,
  "node2_id": 2,
  "ip4_1": "10.0.1.1",
  "ip4_2": "10.0.1.2",
  "bandwidth": 100000000,
  "delay": 0
}
```

Connects two nodes with specified network parameters.

### 4. `set_wlan_config`
```json
{
  "node_id": 1,
  "range_meters": 500,
  "bandwidth": 54000000
}
```

Configures wireless network parameters.

### 5. `get_topology_summary`
Returns human-readable summary of current topology.

### 6. `save_topology`
```json
{
  "filename": "my_network.xml",
  "format": "xml"
}
```

Saves topology to file.

### 7. `clear_topology`
Clears current topology to start fresh.

---

## Network Engineering Rules (Enforced)

The MCP server enforces proper network engineering principles:

### 1. Layer 2 Devices (Switches/Hubs)
- ✅ All connected devices on **SAME subnet**
- ❌ Cannot route between different subnets
- Example: Switch with 5 hosts → all use 10.0.1.0/24

### 2. Layer 3 Devices (Routers)
- ✅ Each router interface on **DIFFERENT subnet**
- ✅ Router-to-router links use separate subnets
- Example: R1-R2 on 10.0.1.0/24, R2-R3 on 10.0.2.0/24

### 3. Wireless Networks
- ✅ All nodes on WLAN use **SAME subnet**
- Wireless acts like Layer 2 (like a wireless switch)

### 4. Override Rules
You can explicitly specify different behavior:
> "Create a star with a center router and 3 hosts on different subnets"

---

## Testing the MCP Server

### Method 1: Direct Python Test

```bash
python3 << 'EOF'
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a star with a switch and 5 hosts")

# Save outputs
with open('/tmp/test_network.xml', 'w') as f:
    f.write(gen.to_xml())

print(gen.get_summary())
EOF
```

### Method 2: MCP Protocol Test (via LLM)

1. Configure Claude Desktop (see above)
2. Open Claude Desktop
3. Say: "Create a ring topology with 4 routers"
4. Claude will use MCP tools to generate it

### Method 3: Web UI (Coming Soon)

Browser-based interface for generating topologies without LLM.

---

## Troubleshooting

### MCP Server Not Loading

**Issue:** Claude Desktop doesn't show MCP tools

**Solutions:**
1. Check `claude_desktop_config.json` syntax (valid JSON)
2. Verify paths are correct (absolute paths recommended)
3. Ensure Python and dependencies are installed
4. Check Claude Desktop logs:
   - macOS: `~/Library/Logs/Claude/`
   - Linux: `~/.config/Claude/logs/`

### Import Errors

**Issue:** `ModuleNotFoundError: No module named 'mcp'`

**Solution:**
```bash
pip install mcp pydantic
```

### Wrong Subnet Configuration

**Issue:** Hosts on switch have different subnets

**Solution:**
- Update to latest version of `topology_generator.py`
- Network engineering rules are now enforced
- If needed, explicitly specify requirements to LLM

---

## Advanced Usage

### Custom Services

**You:**
> Create a network with a web server, database server, and load balancer.

**Claude (using MCP):**
- Creates nodes with appropriate services
- Web server: HTTP, SSH
- Database: Custom MySQL service
- Load balancer: HAProxy service

### Complex Topologies

**You:**
> Build a data center network with:
> - 2 core routers in a redundant pair
> - 4 distribution layer switches
> - 8 access layer switches
> - 32 hosts distributed evenly

**Claude (using MCP):**
- Uses multiple `create_node` and `create_link` calls
- Builds hierarchical topology
- Proper IP addressing for each layer

---

## Files Generated

### XML Format (CORE Native)
- Load directly in CORE GUI
- File → Open → select XML file

### Python Script Format (gRPC API)
- Execute to create live session
- Useful for automation

---

## Next Steps

1. **Test with Claude Desktop**: Generate your first topology
2. **Load in CORE GUI**: Open generated XML file
3. **Run simulation**: Start the network and test connectivity
4. **Iterate**: Ask Claude to modify the topology based on results

---

## Additional Resources

- [MCP Protocol Documentation](https://github.com/anthropics/anthropic-sdk-python/tree/main/src/anthropic/mcp)
- [CORE Network Emulator](https://coreemu.github.io/core/)
- [Natural Language Patterns](./NATURAL_LANGUAGE_GUIDE.md)
- [Topology Generator API](./README.md)

---

**Last Updated:** 2025-11-24
**Status:** ✅ Production Ready
**MCP Protocol Version:** 1.0
