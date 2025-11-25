# How to Use the MCP Server

## 🎯 Quick Start (3 Methods)

### Method 1: Direct Python (Easiest)

Perfect for testing and learning:

```python
#!/usr/bin/env python3
from core_mcp.topology_generator import TopologyGenerator

# Create generator
gen = TopologyGenerator()

# Generate topology from natural language
gen.generate_from_description("Create a star with 5 routers")

# Save XML file
with open('my_topology.xml', 'w') as f:
    f.write(gen.to_xml())

print("✅ Created my_topology.xml")
```

**Run it:**
```bash
cd /workspaces/core/core-mcp-server
python3 your_script.py
```

---

### Method 2: Using the Test Script

Pre-built script that generates multiple examples:

```bash
cd /workspaces/core/core-mcp-server
python3 test_topology_gen.py
```

**Output:**
- `/tmp/test_star_topology.xml`
- `/tmp/test_wireless_mesh.xml`
- `/tmp/test_tailscale_mesh.xml`
- Plus Python scripts for each

---

### Method 3: Via MCP Protocol with an LLM

Use Claude Desktop (or any MCP-compatible LLM) to generate topologies naturally.

#### Setup Claude Desktop

1. **Edit Claude Desktop config:**

**Mac:**
```bash
nano ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Linux:**
```bash
nano ~/.config/Claude/claude_desktop_config.json
```

2. **Add MCP server:**
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

3. **Restart Claude Desktop**

4. **Use it in conversation:**
```
You: "Generate a network topology with 5 routers in a ring"

Claude: [Uses MCP tools to generate topology]
        Here's your ring topology with 5 routers...
        [Shows XML and summary]
```

---

## 📖 Detailed Usage Examples

### Example 1: Create and Load in CORE GUI

```python
#!/usr/bin/env python3
from core_mcp.topology_generator import TopologyGenerator

# Create a wireless network
gen = TopologyGenerator()
gen.generate_from_description("Create a wireless mesh with 8 MDR nodes")

# Save to container's topology directory
with open('/root/topologies/my_wireless_network.xml', 'w') as f:
    f.write(gen.to_xml())

print("✅ Ready to load in CORE GUI!")
print("   File → Open → /root/topologies/my_wireless_network.xml")
```

---

### Example 2: Build Custom Topology

```python
#!/usr/bin/env python3
from core_mcp.topology_generator import TopologyGenerator, NodeConfig, LinkConfig

gen = TopologyGenerator()

# Add nodes manually
gen.add_node(NodeConfig(
    node_id=1,
    name="router1",
    node_type="router",
    x=100.0,
    y=100.0,
    services=["zebra", "OSPFv2", "IPForward"]
))

gen.add_node(NodeConfig(
    node_id=2,
    name="router2",
    node_type="router",
    x=300.0,
    y=100.0,
    services=["zebra", "OSPFv2", "IPForward"]
))

# Add link
gen.add_link(LinkConfig(
    node1_id=1,
    node2_id=2,
    ip4_1="10.0.1.1",
    ip4_2="10.0.1.2",
    bandwidth=100000000,  # 100 Mbps
    delay=5000            # 5ms
))

# Save
with open('custom_topology.xml', 'w') as f:
    f.write(gen.to_xml())
```

---

### Example 3: Generate Multiple Topologies

```python
#!/usr/bin/env python3
from core_mcp.topology_generator import TopologyGenerator

topologies = [
    ("Create a ring with 5 routers", "ring_5.xml"),
    ("Make a star with a switch and 10 hosts", "star_10.xml"),
    ("Build a wireless mesh with 6 MDR nodes", "wireless_6.xml"),
]

for description, filename in topologies:
    gen = TopologyGenerator()
    gen.generate_from_description(description)

    with open(f'/tmp/{filename}', 'w') as f:
        f.write(gen.to_xml())

    print(f"✅ Created {filename}")
```

---

## 🎯 Natural Language Patterns

### Topology Types

| Pattern | Example | Result |
|---------|---------|--------|
| Star | "Create a star with 5 hosts" | 1 switch + 5 hosts |
| Line | "Build 4 routers in a line" | 4 routers connected linearly |
| Ring | "Make a ring with 6 routers" | 6 routers in circular topology |
| Wireless | "Create wireless mesh with 8 MDR nodes" | 1 WLAN + 8 MDR nodes |
| Docker | "Build tailscale mesh with 5 docker nodes" | 5 Docker containers |

### Number Recognition

```python
"3 routers"     → 3
"five hosts"    → 5
"ten nodes"     → 10
```

### Node Type Keywords

```python
"router" / "routers"           → Router nodes
"host" / "hosts" / "pc"        → Host nodes
"switch"                       → Switch node
"wireless" / "wlan" / "mdr"    → Wireless nodes
"docker" / "container"         → Docker nodes
```

---

## 🔧 In Docker Container

### Option 1: Copy MCP Server to Container

Already done! The MCP server is installed in the container.

```bash
# Inside container
docker exec -it core-novnc bash

# Use the MCP server
cd /opt/core-mcp-server
python3 test_topology_gen.py

# Or create custom
python3 << 'EOF'
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a ring with 8 routers")

with open('/root/topologies/my_ring.xml', 'w') as f:
    f.write(gen.to_xml())

print("✅ Created /root/topologies/my_ring.xml")
EOF
```

### Option 2: Via Menu in noVNC

1. Right-click desktop
2. 🌐 Network Simulation → 🤖 MCP Topology Generator
3. Click "Test Generator"
4. Files created in `/tmp/`

---

## 📂 Loading Generated Topologies in CORE

### Method 1: GUI File Open

1. Open CORE GUI (desktop shortcut or Super+C)
2. File → Open
3. Navigate to `/root/topologies/`
4. Select XML file
5. Topology loads!

### Method 2: Command Line

```bash
# Open with specific file
core-gui /root/topologies/my_topology.xml

# Or run Python script
python3 /tmp/my_topology.py
```

### Method 3: Drag and Drop

In noVNC:
1. Open file manager (desktop shortcut)
2. Navigate to `/root/topologies/`
3. Drag XML file to CORE GUI window

---

## 🤖 MCP Tools Available

When using via MCP protocol (e.g., with Claude):

### 1. generate_topology
```json
{
  "tool": "generate_topology",
  "arguments": {
    "description": "Create a wireless mesh with 5 MDR nodes",
    "output_format": "xml"
  }
}
```

### 2. create_node
```json
{
  "tool": "create_node",
  "arguments": {
    "node_id": 1,
    "name": "router1",
    "node_type": "router",
    "x": 100.0,
    "y": 100.0,
    "services": ["zebra", "OSPFv2", "IPForward"]
  }
}
```

### 3. create_link
```json
{
  "tool": "create_link",
  "arguments": {
    "node1_id": 1,
    "node2_id": 2,
    "bandwidth": 100000000,
    "delay": 5000
  }
}
```

### 4. set_wlan_config
```json
{
  "tool": "set_wlan_config",
  "arguments": {
    "node_id": 1,
    "range_meters": 500,
    "bandwidth": 54000000
  }
}
```

### 5. get_topology_summary
```json
{
  "tool": "get_topology_summary",
  "arguments": {}
}
```

### 6. save_topology
```json
{
  "tool": "save_topology",
  "arguments": {
    "filename": "my_topology.xml",
    "format": "xml"
  }
}
```

### 7. clear_topology
```json
{
  "tool": "clear_topology",
  "arguments": {}
}
```

---

## 💡 Tips & Best Practices

### 1. Be Specific
```
✅ Good: "Create a ring with 5 routers"
❌ Vague: "Make a network"
```

### 2. Specify Node Types
```
✅ Good: "Build a star with a switch and 8 hosts"
❌ Vague: "Connect some nodes"
```

### 3. Use Clear Numbers
```
✅ Good: "Create 6 routers in a line"
✅ Good: "Make five hosts"
❌ Vague: "Create several routers"
```

### 4. Check Generated Files
```bash
# View XML structure
cat /tmp/my_topology.xml

# Validate in CORE
core-gui /tmp/my_topology.xml
```

---

## 🐛 Troubleshooting

### Issue: "Module not found: core_mcp"

**Solution:**
```bash
cd /workspaces/core/core-mcp-server
export PYTHONPATH=/workspaces/core/core-mcp-server:$PYTHONPATH
python3 your_script.py
```

### Issue: "No such file: /tmp/my_topology.xml"

**Solution:**
Check the actual output location:
```bash
ls -la /tmp/*.xml
```

### Issue: XML doesn't load in CORE

**Solution:**
Validate XML structure:
```bash
python3 << 'EOF'
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a star with 3 hosts")

# Check summary
print(gen.get_summary())

# Verify XML
xml = gen.to_xml()
print("XML length:", len(xml))
print("First 500 chars:", xml[:500])
EOF
```

### Issue: Topology loads but nodes overlap

**Solution:**
The generator uses calculated positions. To customize:
```python
gen = TopologyGenerator()
gen.generate_from_description("Create a ring with 5 routers")

# Adjust positions in generated topology
for node_id, node in gen.nodes.items():
    node.x += 100  # Shift all nodes right
    node.y += 50   # Shift all nodes down

# Save
with open('adjusted.xml', 'w') as f:
    f.write(gen.to_xml())
```

---

## 📖 Complete Example Workflow

```bash
# 1. Create the topology
cd /workspaces/core/core-mcp-server

python3 << 'EOF'
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
result = gen.generate_from_description(
    "Create a wireless mesh with 6 MDR nodes"
)

print("Generated:", result)
print(gen.get_summary())

with open('/tmp/wireless_network.xml', 'w') as f:
    f.write(gen.to_xml())
EOF

# 2. Copy to container
docker cp /tmp/wireless_network.xml core-novnc:/root/topologies/

# 3. Load in CORE GUI
# - Open noVNC in browser
# - Open CORE GUI
# - File → Open → /root/topologies/wireless_network.xml
# - Start the simulation!
```

---

## 🎓 Learning Path

### Beginner
1. Run `test_topology_gen.py`
2. Look at generated XML files
3. Load them in CORE GUI

### Intermediate
1. Write custom Python scripts
2. Modify generated topologies
3. Add custom services

### Advanced
1. Use MCP protocol with LLM
2. Create complex multi-tier topologies
3. Integrate with automation workflows

---

## 📚 Additional Resources

- **Full Guide:** `NATURAL_LANGUAGE_GUIDE.md`
- **API Reference:** `README.md`
- **Examples:** `examples/README.md`
- **Source Code:** `core_mcp/topology_generator.py`

---

**Last Updated:** 2025-11-24
**Status:** ✅ Production Ready
