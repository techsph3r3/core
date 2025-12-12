# CORE MCP Server

A Model Context Protocol (MCP) server and web dashboard for the CORE Network Emulator + IoT Digital Twin platform.

## Overview

This project provides:
- **Natural Language Topology Generation**: Describe networks in plain English
- **Web Dashboard**: Browser-based interface with embedded VNC viewer
- **IoT Integration**: Connect physical micro:bit devices to virtual networks
- **ICS/SCADA Simulation**: Industrial control system scenarios with HMIs

## Quick Start

### 1. Start All Services

```bash
# Start the core-novnc container
docker start core-novnc

# Start VNC server and CORE GUI
docker exec core-novnc bash -c "vncserver -kill :1 2>/dev/null; rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null; sleep 1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
sleep 2
docker exec core-novnc bash -c "export DISPLAY=:1 && nohup /opt/core/venv/bin/core-gui > /tmp/core-gui.log 2>&1 &"

# Start the Web Dashboard
cd /workspaces/core/core-mcp-server
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
```

See [STARTUP_MANUAL.md](STARTUP_MANUAL.md) for detailed instructions and troubleshooting.

### 2. Access URLs

| Service | GitHub Codespaces | Local |
|---------|-------------------|-------|
| **Web Dashboard** | `https://<codespace>-8080.app.github.dev` | `http://localhost:8080` |
| **noVNC Desktop** | `https://<codespace>-6080.app.github.dev` | `http://localhost:6080` |

**VNC Password:** `core123`

## Features

### Topology Generator

Generate CORE network topologies using natural language:

```python
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a ring with 6 routers running OSPF")

# Save as XML
with open('my_topology.xml', 'w') as f:
    f.write(gen.to_xml())
```

**Supported Patterns:**
- Star: `"Create a star with a switch and 5 hosts"`
- Line: `"Build a chain of 3 routers"`
- Ring: `"Create a ring with 4 routers"`
- Wireless: `"Make a wireless mesh with 6 MDR nodes"`
- Docker: `"Create a tailscale mesh with 4 docker nodes"`

### Web Dashboard

Access at `http://localhost:8080`:
- Embedded VNC viewer for CORE desktop
- Pre-built topology templates (IoT, Enterprise, ICS/SCADA)
- Micro:bit WebSerial integration
- HMI workstation VNC access

### MCP Protocol (for LLM Integration)

Configure Claude Desktop (`~/Library/Application Support/Claude/claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "core-topology": {
      "command": "python3",
      "args": ["-m", "core_mcp.server"],
      "cwd": "/workspaces/core/core-mcp-server",
      "env": {
        "PYTHONPATH": "/workspaces/core/core-mcp-server"
      }
    }
  }
}
```

Then ask Claude: "Create a wireless mesh network with 5 MDR nodes"

## API Reference

### MCP Tools

| Tool | Description |
|------|-------------|
| `generate_topology` | Generate from natural language description |
| `create_node` | Add individual node |
| `create_link` | Connect two nodes |
| `set_wlan_config` | Configure wireless parameters |
| `save_topology` | Save to file |
| `get_topology_summary` | Get human-readable summary |
| `clear_topology` | Clear current topology |

### REST API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/generate` | POST | Generate topology from description |
| `/api/templates` | GET | List available templates |
| `/api/start-host-vnc` | POST | Start VNC proxy for HMI node |
| `/api/inject/{sensor_id}` | POST | Inject sensor data into CORE network |
| `/health` | GET | Health check |

## Node Types

| Type | Description | Services |
|------|-------------|----------|
| `router` | L3 router | zebra, OSPFv2, OSPFv3, IPForward |
| `switch` | L2 switch | None |
| `host` | End host | DefaultRoute |
| `mdr` | Mobile ad-hoc | zebra, OSPFv3MDR, IPForward |
| `docker` | Container | Custom |

## Documentation

| Document | Description |
|----------|-------------|
| [STARTUP_MANUAL.md](STARTUP_MANUAL.md) | How to start all services |
| [QUICKSTART.md](QUICKSTART.md) | 5-minute setup guide |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Docker deployment guide |
| [IOT_QUICKSTART.md](IOT_QUICKSTART.md) | IoT sensor system guide |
| [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | Project overview |
| [CALDERA_DEPLOYMENT.md](CALDERA_DEPLOYMENT.md) | MITRE Caldera setup |

### Architecture Docs (in docs/)

| Document | Description |
|----------|-------------|
| [MICROBIT_IOT_ARCHITECTURE.md](docs/MICROBIT_IOT_ARCHITECTURE.md) | Micro:bit data flow |
| [VNC_WORKSTATION_ARCHITECTURE.md](docs/VNC_WORKSTATION_ARCHITECTURE.md) | HMI VNC proxy architecture |
| [APPLIANCE_ARCHITECTURE.md](docs/APPLIANCE_ARCHITECTURE.md) | Network appliance system |
| [VYOS_CONFIGURATION.md](docs/VYOS_CONFIGURATION.md) | VyOS config generator |

## Installation

```bash
cd /workspaces/core/core-mcp-server
pip install -e .
```

## Testing

```bash
# Generate test topologies
python test_topology_gen.py

# View generated files
ls -la /tmp/test_*.xml
```

## Troubleshooting

### CORE GUI not loading
```bash
docker exec core-novnc bash -c "vncserver -kill :1 2>/dev/null; rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; sleep 1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
sleep 2
docker exec core-novnc bash -c "export DISPLAY=:1 && nohup /opt/core/venv/bin/core-gui > /tmp/core-gui.log 2>&1 &"
```

### Web dashboard not responding
```bash
pkill -f web_ui.py
cd /workspaces/core/core-mcp-server
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
```

### Module not found
```bash
export PYTHONPATH=/workspaces/core/core-mcp-server:$PYTHONPATH
```

## License

Apache 2.0 - Same as CORE
