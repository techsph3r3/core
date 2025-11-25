# CORE MCP Server - Natural Language Topology Generation Guide

## Overview

The CORE MCP Server allows you to create complex network topologies using simple natural language descriptions. An LLM can understand your intent and generate the appropriate CORE topology with proper node placement, links, and services.

## ✅ Current Status

**Working:** All basic topology types and node types
**Tested:** Multiple natural language patterns
**Output:** Python scripts and XML files
**Integration:** Ready for LLM use via MCP protocol

---

## 📋 Supported Topology Types

### 1. Star Topology
**Pattern:** "star", "hub", "spoke", "hub and spoke"

**Examples:**
```
"Create a star with a switch and 5 hosts"
"Build a hub and spoke with 7 routers"
"Make a star topology with 3 hosts"
```

**Structure:**
```
        ┌────────┐
    ┌───┤ Switch ├───┐
    │   └────────┘   │
┌───┴───┐        ┌───┴───┐
│ Host1 │        │ Host2 │
└───────┘        └───────┘
```

**Generated:**
- 1 central node (switch or hub)
- N peripheral nodes (hosts or routers)
- N links connecting peripheral to central
- Appropriate services based on node type

---

### 2. Line/Chain Topology
**Pattern:** "line", "chain", "linear"

**Examples:**
```
"Create 3 routers in a line"
"Build a chain topology with 5 hosts"
"Make a linear network with 4 routers"
```

**Structure:**
```
┌────┐    ┌────┐    ┌────┐
│ R1 ├────┤ R2 ├────┤ R3 │
└────┘    └────┘    └────┘
```

**Generated:**
- N nodes in a horizontal line
- N-1 links connecting adjacent nodes
- IP addressing: 10.0.{i}.1 and 10.0.{i}.2

---

### 3. Ring Topology
**Pattern:** "ring", "circular"

**Examples:**
```
"Create a ring with 4 routers"
"Build a circular topology with 5 hosts"
"Make 6 routers in a ring"
```

**Structure:**
```
    ┌────┐
  ┌─┤ R1 ├─┐
  │ └────┘ │
┌─┴─┐   ┌──┴──┐
│R4 │   │ R2  │
└─┬─┘   └──┬──┘
  │ ┌────┐ │
  └─┤ R3 ├─┘
    └────┘
```

**Generated:**
- N nodes arranged in a circle
- N links (each node connected to neighbors)
- Last node links back to first (closes ring)

---

### 4. Wireless Mesh
**Pattern:** "wireless mesh", "wlan", "mdr"

**Examples:**
```
"Create a wireless mesh with 5 MDR nodes"
"Build a WLAN network with 6 nodes"
"Make a wireless mesh for mobile ad-hoc routing"
```

**Structure:**
```
      (WLAN)
     /  |  \
    /   |   \
[MDR1][MDR2][MDR3]
```

**Generated:**
- 1 WLAN node (central wireless network)
- N MDR nodes (Mobile Ad-hoc routing)
- N links (each MDR to WLAN)
- Services: zebra, OSPFv3MDR, IPForward
- WLAN configured with 500m range

---

### 5. Tailscale Mesh (Docker)
**Pattern:** "tailscale", "docker mesh"

**Examples:**
```
"Create a tailscale mesh with 4 docker nodes"
"Build a docker network with tailscale"
"Make 5 docker containers with tailscale"
```

**Structure:**
```
[Docker1]────────[Docker2]
    │                │
    │                │
[Docker3]────────[Docker4]
```

**Generated:**
- N Docker nodes (ubuntu:22.04 base image)
- No automatic links (Tailscale creates mesh)
- Nodes positioned in grid layout

**Note:** Requires Tailscale service configuration (see CORE_MCP_SOLUTION.md)

---

## 🔧 Supported Node Types

| Type | Description | Services | Use Case |
|------|-------------|----------|----------|
| **router** | L3 network router | zebra, OSPFv2, OSPFv3, IPForward | Routing between networks |
| **switch** | L2 network switch | None | Connecting hosts in LAN |
| **hub** | Network hub | None | Simple broadcast domain |
| **host** | Generic end host | DefaultRoute | Client/server machines |
| **pc** | Personal computer | DefaultRoute | Desktop endpoints |
| **mdr** | Mobile Ad-hoc node | zebra, OSPFv3MDR, IPForward | Wireless mesh routing |
| **wireless** | WLAN network | None | Wireless access point |
| **emane** | EMANE wireless | None | Advanced wireless simulation |
| **docker** | Docker container | Custom | Containerized services |

---

## 🛠️ Available Services

### Routing Services
- `zebra` - FRR routing manager (required for other routing protocols)
- `OSPFv2` - OSPF for IPv4
- `OSPFv3` - OSPF for IPv6
- `OSPFv3MDR` - OSPF for mobile ad-hoc networks
- `BGP` - Border Gateway Protocol
- `RIP` - Routing Information Protocol
- `RIPng` - RIP for IPv6

### Application Services
- `HTTP` - Apache2 web server
- `FTP` - vsftpd file server
- `SSH` - OpenSSH server
- `DHCP` - ISC DHCP server
- `DHCPClient` - DHCP client

### Utility Services
- `IPForward` - Enable IP forwarding (required for routers)
- `DefaultRoute` - Auto-configure default route (for hosts)
- `StaticRoute` - Static routing configuration

---

## 📝 Natural Language Patterns

### Number Extraction
The system understands both digits and words:
```
"3 routers"       → 3
"five hosts"      → 5
"ten nodes"       → 10
"4"               → 4
```

### Topology Keywords
- **Star:** star, hub, spoke, hub-and-spoke
- **Line:** line, chain, linear, series
- **Ring:** ring, circular, loop
- **Mesh:** mesh + wireless/mdr, mesh + tailscale/docker

### Node Type Keywords
- **Router:** router, routers
- **Host:** host, hosts, pc, computer
- **Wireless:** wireless, wlan, mdr
- **Docker:** docker, container

---

## 🎯 Usage Examples

### Example 1: Enterprise Network
```
Description: "Create a star with a switch and 10 hosts"

Generated:
- 1 switch (central)
- 10 hosts with DefaultRoute service
- 10 links to switch
- IP range: 10.0.1.x - 10.0.10.x
```

### Example 2: Backbone Network
```
Description: "Build a ring with 6 routers running OSPF"

Generated:
- 6 routers with zebra, OSPFv2, OSPFv3, IPForward
- 6 links forming ring
- Circular placement
```

### Example 3: Wireless Network
```
Description: "Create a wireless mesh with 8 MDR nodes"

Generated:
- 1 WLAN node (500m range, 54 Mbps)
- 8 MDR nodes with OSPFv3MDR
- 8 links (star pattern through WLAN)
```

### Example 4: Test Environment
```
Description: "Make 5 docker containers with tailscale"

Generated:
- 5 Docker nodes (ubuntu:22.04)
- Grid layout
- Ready for Tailscale configuration
```

---

## 🧪 Testing the Generator

### Method 1: Direct Python Test

```bash
cd /workspaces/core/core-mcp-server
python3 test_topology_gen.py
```

Output files: `/tmp/test_*.xml` and `/tmp/test_*.py`

### Method 2: Comprehensive Test

```bash
python3 << 'EOF'
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a ring with 5 routers")

# Get summary
print(gen.get_summary())

# Save outputs
with open('/tmp/my_topology.xml', 'w') as f:
    f.write(gen.to_xml())
EOF
```

### Method 3: In Docker Container

```bash
docker exec core-novnc bash -c "cd /opt/core-mcp-server && python3 test_topology_gen.py"
```

---

## 📦 Output Formats

### Python Script (gRPC API)
```python
#!/usr/bin/env python3
from core.api.grpc import client
from core.api.grpc.wrappers import NodeType, Position

core = client.CoreGrpcClient()
core.connect()
session = core.create_session()

# Create nodes
node1 = session.add_node(1, name="router1", ...)
# ... create links ...

core.start_session(session)
```

**Usage:** Execute with Python to create live topology

### XML File (CORE Native)
```xml
<?xml version="1.0" ?>
<scenario name="Generated Topology">
  <networks>
    <network id="1" name="switch1" type="SWITCH">
      <position x="300.0" y="300.0"/>
    </network>
  </networks>
  <devices>
    <device id="2" name="router1" type="router">
      <position x="500.0" y="300.0"/>
      <services>
        <service name="zebra"/>
        <service name="OSPFv2"/>
      </services>
    </device>
  </devices>
  <links>
    <link node1="1" node2="2"/>
  </links>
</scenario>
```

**Usage:** Open in CORE GUI (File → Open)

---

## 🔍 Current Capabilities

### ✅ Working Features
- [x] Star topology generation
- [x] Line/chain topology
- [x] Ring topology
- [x] Wireless mesh (WLAN + MDR)
- [x] Tailscale mesh (Docker nodes)
- [x] Number extraction (digits and words)
- [x] Node type detection (router/host/wireless/docker)
- [x] Service assignment based on node type
- [x] IP address allocation
- [x] Python script generation
- [x] XML file generation
- [x] Proper node positioning

### 🚧 Future Enhancements
- [ ] More complex topologies (tree, datacenter fabric, enterprise)
- [ ] EMANE network generation
- [ ] Custom service configuration
- [ ] Mobility scenarios
- [ ] Traffic generation patterns
- [ ] Security policies

---

## 🎓 Tips for Best Results

### 1. Be Specific About Numbers
```
✅ Good: "Create 5 routers in a ring"
❌ Vague: "Create some routers"
```

### 2. Specify Topology Type
```
✅ Good: "Build a star with 4 hosts"
❌ Vague: "Create a network"
```

### 3. Indicate Node Types
```
✅ Good: "Make a line of 3 routers"
✅ Good: "Create a hub with 6 hosts"
❌ Vague: "Connect some nodes"
```

### 4. Use Keywords for Wireless
```
✅ Good: "Create a wireless mesh with MDR nodes"
✅ Good: "Build a WLAN network"
```

---

## 📂 Generated Files Location

**In Development:**
- `/tmp/*.xml` - XML topology files
- `/tmp/*.py` - Python scripts

**In Docker Container:**
- `/root/topologies/*.xml` - Imported topologies
- `/tmp/*.xml` - Generated topologies

---

## 🔗 Integration with CORE GUI

### Loading Generated Topologies

1. **Via noVNC Browser:**
   - Open CORE GUI
   - File → Open
   - Navigate to `/root/topologies/`
   - Select XML file

2. **Via Python Script:**
   ```bash
   cd /opt/core-mcp-server
   python3 /tmp/my_topology.py
   ```

3. **Via Terminal:**
   ```bash
   core-gui /root/topologies/my_topology.xml
   ```

---

## 🤖 MCP Protocol Usage

### For LLMs Using MCP

```json
{
  "tool": "generate_topology",
  "arguments": {
    "description": "Create a wireless mesh with 5 MDR nodes",
    "output_format": "xml"
  }
}
```

**Response:** Complete XML topology ready to load

### Available MCP Tools

1. **generate_topology** - Generate from natural language
2. **create_node** - Add individual node
3. **create_link** - Connect nodes
4. **set_wlan_config** - Configure wireless parameters
5. **save_topology** - Save to file
6. **get_topology_summary** - Get human-readable summary
7. **clear_topology** - Start fresh

---

## ✅ Verification Checklist

After generating a topology:

- [ ] Open XML file to verify structure
- [ ] Check node IDs are sequential and unique
- [ ] Verify links reference existing nodes
- [ ] Confirm services match node types
- [ ] Test in CORE GUI (File → Open)
- [ ] Verify nodes appear in correct positions
- [ ] Check that links are properly connected

---

## 📖 Additional Resources

- **MCP Server Code:** `/workspaces/core/core-mcp-server/core_mcp/server.py`
- **Topology Generator:** `/workspaces/core/core-mcp-server/core_mcp/topology_generator.py`
- **Test Script:** `/workspaces/core/core-mcp-server/test_topology_gen.py`
- **Examples:** `/workspaces/core/core-mcp-server/examples/`

---

**Last Updated:** 2025-11-24
**Status:** ✅ Production Ready
**Tested:** Yes, multiple topology types
**LLM Compatible:** Yes, via MCP protocol
