# Deployment Guide for CORE MCP Server

## Overview

This guide explains how to deploy and use the CORE MCP Server in your Docker CORE environment with noVNC.

## What We Built

The CORE MCP Server consists of:

1. **MCP Server (`core_mcp/server.py`)**: Implements the Model Context Protocol to expose CORE topology generation tools to LLMs
2. **Topology Generator (`core_mcp/topology_generator.py`)**: Converts natural language descriptions into CORE network topologies
3. **Support for Multiple Formats**: Generates both Python scripts (using CORE gRPC API) and XML files (CORE native format)

## Features

- Natural language topology generation (e.g., "Create a wireless mesh with 5 MDR nodes")
- Support for all CORE node types (routers, switches, wireless, EMANE, Docker)
- Service configuration (OSPF, BGP, HTTP, FTP, SSH, DHCP, etc.)
- Link parameter configuration (bandwidth, delay, loss, jitter)
- WLAN/wireless network configuration
- Tailscale mesh topology templates

## Integration with Your Docker Environment

### Step 1: Add to Dockerfile

Add these lines to your `dockerfiles/Dockerfile.novnc`:

```dockerfile
# Install CORE MCP Server
COPY core-mcp-server /opt/core-mcp-server
RUN cd /opt/core-mcp-server && \
    /opt/core/venv/bin/pip install -e .
```

### Step 2: Rebuild Your Docker Image

```bash
cd /workspaces/core
docker build -t core-novnc -f dockerfiles/Dockerfile.novnc .
```

### Step 3: Using the MCP Server

#### Option A: Via Claude Desktop (Recommended)

1. Configure Claude Desktop to connect to the MCP server running in your container:

```json
{
  "mcpServers": {
    "core-topology": {
      "command": "docker",
      "args": [
        "exec",
        "-i",
        "core-novnc",
        "/opt/core/venv/bin/python",
        "-m",
        "core_mcp.server"
      ]
    }
  }
}
```

2. Start your CORE container:

```bash
docker run -d \
  --name core-novnc \
  --privileged \
  --init \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 50051:50051 \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  core-novnc:latest
```

3. Open Claude Desktop and start creating topologies!

#### Option B: Direct Python Usage

You can also use the topology generator directly without MCP:

```python
from core_mcp.topology_generator import TopologyGenerator

# Create generator
gen = TopologyGenerator()

# Generate from natural language
gen.generate_from_description("Create a wireless mesh with 4 MDR nodes")

# Save as Python script
script = gen.to_python_script()
with open("my_topology.py", "w") as f:
    f.write(script)

# Or save as XML
xml = gen.to_xml()
with open("my_topology.xml", "w") as f:
    f.write(xml)
```

## Example Conversations with Claude

Once connected via MCP, you can have natural conversations like:

### Example 1: Simple Network

**You:** "Create a simple network with a switch connecting 4 routers running OSPF"

**Claude:** "I'll create that network for you using the CORE topology tools."

[Claude uses the `generate_topology` tool]

**Claude:** "I've created a star topology with:
- 1 central switch
- 4 routers connected to the switch
- All routers running zebra, OSPFv2, OSPFv3, and IPForward services

Would you like me to save this as a Python script or XML file?"

**You:** "Save it as topology.py"

**Claude:** [Uses `save_topology` tool] "Saved to topology.py"

### Example 2: Wireless Mesh

**You:** "Build a wireless mesh network with 6 MDR nodes, 500 meter range"

**Claude:** [Uses tools to create WLAN and MDR nodes, configures wireless range]

"Created a wireless mesh with:
- 1 WLAN node (500m range)
- 6 MDR nodes running OSPF-MDR
- All nodes connected to the WLAN"

### Example 3: Tailscale Mesh (Work in Progress)

**You:** "Create a tailscale mesh with 5 docker nodes"

**Claude:** [Uses generate_topology tool]

"I've created a topology with 5 Docker nodes that can run Tailscale. Note: You'll need to configure Tailscale as a custom service in CORE. Each node uses the ubuntu:22.04 image which includes Tailscale in your Docker setup."

## Running Generated Topologies

### Python Scripts

```bash
# Inside the CORE container
/opt/core/venv/bin/python /path/to/topology.py
```

Or from the host if you have CORE installed:

```bash
python3 topology.py
```

### XML Files

Using CORE GUI:
```bash
core-gui -f topology.xml
```

Using CORE daemon directly:
```bash
# Start a session from XML
core-cli -f topology.xml
```

## Addressing the Tailscale "Unknown Node ID None" Error

The error you're experiencing likely comes from improper node ID management in custom topologies. The MCP server addresses this by:

1. **Explicit Node ID Assignment**: Every node gets a unique, explicit ID
2. **Proper Link References**: Links always reference nodes by their assigned IDs
3. **Correct Service Configuration**: Services are properly assigned to nodes before session start
4. **Sequential Node Creation**: Nodes are created in order before links are established

### Recommended Tailscale Mesh XML Structure

Here's a properly structured Tailscale mesh topology that avoids the node ID error:

```xml
<?xml version='1.0' encoding='UTF-8'?>
<scenario name="Tailscale Mesh">
  <networks>
    <!-- Optional: Add a management network for coordination -->
    <network id="100" name="mgmt" type="SWITCH">
      <position x="300.0" y="50.0" lat="0.0" lon="0.0" alt="0.0"/>
    </network>
  </networks>

  <devices>
    <!-- Tailscale Node 1 -->
    <device id="1" name="ts-node1" type="docker" class="" image="ubuntu:22.04">
      <position x="100.0" y="100.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="Tailscale"/>  <!-- Custom service -->
      </services>
    </device>

    <!-- Tailscale Node 2 -->
    <device id="2" name="ts-node2" type="docker" class="" image="ubuntu:22.04">
      <position x="300.0" y="100.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="Tailscale"/>
      </services>
    </device>

    <!-- Tailscale Node 3 -->
    <device id="3" name="ts-node3" type="docker" class="" image="ubuntu:22.04">
      <position x="500.0" y="100.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="Tailscale"/>
      </services>
    </device>
  </devices>

  <links>
    <!-- Optional: Management network links -->
    <link node1="100" node2="1">
      <iface2 id="0" name="eth0" ip4="192.168.1.1" ip4_mask="24"/>
    </link>
    <link node1="100" node2="2">
      <iface2 id="0" name="eth0" ip4="192.168.1.2" ip4_mask="24"/>
    </link>
    <link node1="100" node2="3">
      <iface2 id="0" name="eth0" ip4="192.168.1.3" ip4_mask="24"/>
    </link>
  </links>
</scenario>
```

## Creating a Tailscale Custom Service

To properly run Tailscale in CORE nodes, create a custom service:

1. Create `/opt/core/venv/lib/python3.*/site-packages/core/services/tailscale.py`:

```python
from core.services.coreservices import CoreService

class Tailscale(CoreService):
    name = "Tailscale"
    group = "VPN"
    executables = ("tailscaled", "tailscale")
    dependencies = ()
    dirs = ("/var/lib/tailscale", "/run/tailscale")
    configs = ("tailscale.sh",)
    startup = ("bash tailscale.sh",)
    validate = ("pidof tailscaled",)
    shutdown = ("killall tailscaled",)

    @classmethod
    def generate_config(cls, node, filename):
        return f"""#!/bin/bash
# Start Tailscale daemon
mkdir -p /var/lib/tailscale /run/tailscale
tailscaled --state=/var/lib/tailscale/tailscaled.state \\
           --socket=/run/tailscale/tailscaled.sock &

# Wait for daemon to start
sleep 2

# Connect to tailnet (you need to set TAILSCALE_AUTHKEY)
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    tailscale up --authkey=$TAILSCALE_AUTHKEY --hostname={node.name}
else
    echo "WARNING: TAILSCALE_AUTHKEY not set. Tailscale not authenticated."
    echo "Run: docker exec {node.name} tailscale up"
fi
"""
```

2. Register the service in CORE's service manager

3. Use environment variables to pass the Tailscale auth key:

```bash
docker run -d \
  --name core-novnc \
  --privileged \
  -e TAILSCALE_AUTHKEY=tskey-auth-xxxxx \
  ...
```

## Testing

Test the topology generator:

```bash
cd /workspaces/core/core-mcp-server
python test_topology_gen.py
```

This will create several test topologies in `/tmp/`:
- `test_star_topology.py` and `.xml`
- `test_wireless_mesh.py` and `.xml`
- `test_tailscale_mesh.py` and `.xml`

## Troubleshooting

### "Unknown node ID None" Error

**Cause**: Node IDs not properly assigned or referenced in links

**Solution**:
- Ensure all nodes have explicit integer IDs
- Ensure all links reference valid node IDs
- Use the MCP-generated topologies which handle this automatically

### MCP Server Not Connecting

**Check**:
1. Is the Docker container running? `docker ps | grep core-novnc`
2. Can you exec into the container? `docker exec -it core-novnc bash`
3. Is Python available? `docker exec -it core-novnc /opt/core/venv/bin/python --version`
4. Can you import the module? `docker exec -it core-novnc /opt/core/venv/bin/python -c "from core_mcp import server"`

### Generated Topology Doesn't Start

**Debug**:
1. Check CORE daemon logs: `docker exec -it core-novnc tail -f /var/log/core-daemon.log`
2. Validate the topology manually: `core-gui -f topology.xml`
3. Check for service errors: Ensure all referenced services exist

## Next Steps

1. **Add Tailscale Custom Service**: Implement the custom Tailscale service described above
2. **Test Generated Topologies**: Run the test topologies in your CORE container
3. **Extend Natural Language Parser**: Add more topology patterns (bus, tree, hierarchical)
4. **Add EMANE Support**: Extend the generator to handle EMANE configurations
5. **Integrate with Existing Tools**: Connect the MCP server to your Docker deployment workflows

## Resources

- [CORE Documentation](https://coreemu.github.io/core/)
- [Model Context Protocol](https://github.com/anthropics/anthropic-sdk-python/tree/main/examples/mcp)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [CORE gRPC API Examples](https://github.com/coreemu/core/tree/master/package/share/examples/grpc)
