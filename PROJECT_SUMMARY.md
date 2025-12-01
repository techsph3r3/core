# CORE Network Emulator + Caldera Integration Project

## Quick Start

### Option 1: Docker Container with noVNC (Recommended)

```bash
# Build and run the CORE container with noVNC
cd /workspaces/core/dockerfiles
docker build -t core-novnc -f Dockerfile.novnc ..
docker run -d --name core-novnc --privileged \
    -p 6080:6080 -p 5000:5000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    core-novnc

# Access noVNC desktop in browser
open http://localhost:6080
# Password: core123
```

### Option 2: Web UI for Topology Generation

```bash
# Install dependencies (first time only)
cd /workspaces/core/core-mcp-server
pip install flask flask-cors openai pyyaml

# Start the Web UI server
python3 web_ui.py --host 0.0.0.0 --port 5000

# Access in browser
open http://localhost:5000
```

### Option 3: Command Line Topology Generation

```bash
cd /workspaces/core/core-mcp-server

# Run test to generate sample topologies
python3 test_topology_gen.py

# Generated files appear in /tmp/:
#   /tmp/test_star_topology.py
#   /tmp/test_wireless_mesh.py
#   /tmp/test_tailscale_mesh.py
```

### Option 4: Python API

```python
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create 3 routers in a triangle with OSPF")

# Export as XML (for CORE GUI)
with open("my_topology.xml", "w") as f:
    f.write(gen.to_xml())

# Export as Python script (for automation)
with open("my_topology.py", "w") as f:
    f.write(gen.to_python_script())
```

### GitHub Codespaces URLs

If running in GitHub Codespaces, access via:
- **noVNC**: `https://<codespace-name>-6080.app.github.dev`
- **Web UI**: `https://<codespace-name>-5000.app.github.dev`

---

## Project Overview

This project extends the [CORE Network Emulator](https://github.com/coreemu/core) with:
1. **Natural Language Topology Generation** - Create network topologies using plain English
2. **MITRE Caldera Integration** - Adversary emulation and red team automation
3. **Web-based UI** - Browser interface for topology design
4. **Docker/noVNC Infrastructure** - Containerized environment with remote desktop access
5. **MCP (Model Context Protocol) Server** - LLM integration for AI-assisted network design

---

## What Was Built

### 1. CORE MCP Server (`core-mcp-server/`)

A complete Python package enabling LLMs to generate CORE network topologies from natural language.

#### Core Components

| File | Purpose |
|------|---------|
| `core_mcp/server.py` | MCP server implementation with topology tools |
| `core_mcp/topology_generator.py` | Natural language → CORE topology engine (1100+ lines) |
| `web_ui.py` | Flask web application for browser-based topology generation |
| `caldera_session_watcher.py` | Daemon that auto-deploys Caldera agents when CORE sessions start |
| `llm_generator.py`, `llm_generator_v2.py`, `llm_generator_v3.py` | LLM-powered topology generation iterations |
| `load_topology.py` | Utility to load topologies into running CORE sessions |
| `start_and_deploy.py` | Orchestration script for Caldera deployment |

#### Key Features

**Natural Language Parsing:**
```python
# Examples of supported descriptions:
"Create a star topology with 4 routers connected to a central switch"
"Build a wireless mesh with 5 MDR nodes running OSPF"
"Make a network with 3 nginx web servers behind a router"
"Deploy Caldera C2 server with 3 target hosts"
```

**Network Engineering Rules Enforced:**
- Layer 2 devices (switches/hubs) keep all nodes on same subnet
- Layer 3 devices (routers) create separate subnets per link
- Proper IP address assignment and subnet management
- Correct service configuration order

**Output Formats:**
- Python scripts (using CORE gRPC API)
- XML files (CORE native format)
- Both can be loaded directly into CORE

**Docker Image Registry:**
Pre-configured images for CORE compatibility:
- `nginx-core` - Web server
- `ubuntu:22.04` - General purpose
- `alpine:latest` - Lightweight containers
- `caldera-mcp-core` - MITRE Caldera with MCP plugin

---

### 2. Docker Infrastructure (`dockerfiles/`)

#### Custom Dockerfiles

| File | Purpose |
|------|---------|
| `Dockerfile.novnc` | Full CORE environment with noVNC remote desktop (292 lines) |
| `Dockerfile.caldera-core` | MITRE Caldera wrapped for CORE compatibility |
| `Dockerfile.core-node` | Base image for CORE container nodes |
| `Dockerfile.nginx-core` | Nginx wrapped for CORE networking |
| `docker-compose.novnc.yml` | Docker Compose for easy deployment |

#### Dockerfile.novnc Features

This is the primary container providing:

**Base System:**
- Ubuntu 22.04
- CORE 9.2.0 network emulator
- EMANE 1.5.1 (wireless emulation)
- OSPF-MDR (mobile ad-hoc routing)

**Remote Desktop:**
- TigerVNC server
- noVNC (browser-based VNC client)
- Fluxbox window manager
- Resolution: 1920x1080

**Networking Tools:**
- FRR (Free Range Routing) - BGP, OSPF, RIP, IS-IS
- Wireshark/tshark
- iperf/iperf3
- nmap, tcpdump, traceroute

**Services:**
- Apache2 web server
- vsftpd FTP server
- OpenSSH server
- ISC DHCP server/client
- radvd (IPv6 router advertisements)

**Special Features:**
- Docker-in-Docker support (for Docker nodes in CORE)
- Tailscale VPN pre-installed
- Clipboard tools (autocutsel, xclip, xsel)

#### noVNC Support Files (`dockerfiles/novnc/`)

| File | Purpose |
|------|---------|
| `xstartup` | VNC session startup script |
| `start-vnc.sh` | VNC server launcher |
| `supervisord.conf` | Process supervisor configuration |
| `build-and-run.sh` | Build and launch script |
| `enable-scaling.sh` | Display scaling configuration |

**Documentation:**
- `README.md` - Complete noVNC setup guide
- `SERVICES.md` - Available network services documentation
- `DOCKER-NODES.md` - Using Docker nodes in CORE
- `COPY-PASTE.md` - Clipboard functionality guide
- `CHROME-CLIPBOARD.md` - Browser clipboard support
- `SCALING-INTEGRATION.md` - Display scaling guide

#### Theme System (`dockerfiles/novnc/themes/`)

Customizable UI themes for CORE GUI:

| File | Purpose |
|------|---------|
| `apply-theme.py` | Python theme application script |
| `apply-theme.sh` | Shell wrapper for theme application |
| `theme-config.yaml` | Theme configuration schema |
| `preset-light.yaml` | Light theme preset |
| `preset-nord.yaml` | Nord color scheme preset |
| `preset-highcontrast.yaml` | High contrast accessibility preset |

---

### 3. Caldera Integration

#### Caldera Submodule (`caldera-latest/`)

MITRE Caldera is included as a git submodule pointing to `https://github.com/mitre/caldera.git`

#### Auto-Deployment System

The `caldera_session_watcher.py` daemon provides automatic Caldera deployment:

1. **Watches** for CORE sessions entering RUNTIME state
2. **Detects** Caldera Docker containers in the topology
3. **Starts** Caldera server on the C2 node
4. **Deploys** Sandcat agents to target hosts after configurable delay

**Deployment Scripts:**
- `scripts/deploy-caldera-agents.sh` - Full agent deployment
- `scripts/deploy-sandcat.sh` - Sandcat-specific deployment

#### Caldera Web UI Access

- **Port:** 8888
- **Default credentials:** `red/admin` or `blue/admin`
- **Features:** Adversary emulation, agent management, operation planning

---

### 4. Web UI (`core-mcp-server/web_ui.py` + `templates/`)

Browser-based interface for topology generation:

**Features:**
- Natural language input field
- Real-time topology preview
- Download as XML or Python
- OpenAI integration for enhanced interpretation
- Image upload for diagram-to-topology conversion

**Endpoints:**
| Route | Method | Purpose |
|-------|--------|---------|
| `/` | GET | Main interface |
| `/api/generate` | POST | Generate topology from description |
| `/api/download/xml` | GET | Download XML file |
| `/api/download/python` | GET | Download Python script |
| `/api/interpret` | POST | AI interpretation of description |
| `/api/interpret-image` | POST | Convert diagram image to topology |

---

### 5. Documentation Created

#### Root Level
- `CORE_MCP_SOLUTION.md` - Solution overview and architecture

#### core-mcp-server/
| File | Purpose |
|------|---------|
| `README.md` | Complete MCP server documentation |
| `QUICKSTART.md` | 5-minute setup guide |
| `DEPLOYMENT.md` | Docker integration guide |
| `HOW_TO_USE.md` | Usage instructions |
| `CALDERA_DEPLOYMENT.md` | Caldera-specific deployment |
| `NATURAL_LANGUAGE_GUIDE.md` | Supported NL patterns |
| `MCP_WITH_LLM_GUIDE.md` | LLM integration guide |
| `WEB_UI_GUIDE.md` | Web interface documentation |
| `IMPLEMENTATION_STATUS.md` | Feature completion status |
| `COMPLETE_SOLUTION_SUMMARY.md` | Full technical summary |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Interfaces                              │
├─────────────────┬─────────────────┬─────────────────────────────────┤
│  Claude/LLM     │   Web Browser   │       noVNC Desktop             │
│  (MCP Client)   │   (Web UI)      │       (CORE GUI)                │
└────────┬────────┴────────┬────────┴────────────┬────────────────────┘
         │                 │                      │
         │ MCP Protocol    │ HTTP/REST           │ VNC
         │                 │                      │
┌────────▼─────────────────▼──────────────────────▼────────────────────┐
│                     Docker Container (core-novnc)                     │
│                                                                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │   MCP Server    │  │    Web UI       │  │   CORE Daemon       │  │
│  │  (server.py)    │  │   (Flask)       │  │   (core-daemon)     │  │
│  └────────┬────────┘  └────────┬────────┘  └──────────┬──────────┘  │
│           │                    │                       │             │
│           └────────────────────┼───────────────────────┘             │
│                                │                                      │
│  ┌─────────────────────────────▼─────────────────────────────────┐  │
│  │              Topology Generator Engine                         │  │
│  │  • Natural language parsing                                    │  │
│  │  • Network engineering rules                                   │  │
│  │  • Node/Link/Service configuration                             │  │
│  │  • Python & XML output generation                              │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │              Caldera Session Watcher                            ││
│  │  • Monitors CORE sessions                                       ││
│  │  • Auto-deploys Caldera server                                  ││
│  │  • Deploys Sandcat agents to targets                            ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │              Network Emulation Layer                            ││
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          ││
│  │  │ Routers  │ │ Switches │ │  WLAN    │ │  Docker  │          ││
│  │  │ (OSPF,   │ │ (L2)     │ │  (MDR)   │ │  Nodes   │          ││
│  │  │  BGP)    │ │          │ │          │ │ (Caldera)│          ││
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘          ││
│  └─────────────────────────────────────────────────────────────────┘│
└───────────────────────────────────────────────────────────────────────┘
```

---

## Key Problems Solved

### 1. "Unknown Node ID None" Error
The topology generator ensures:
- Every node has an explicit integer ID
- Nodes are created before links reference them
- All link references use valid node IDs
- Services are assigned after node creation

### 2. Complex Topology Generation
Instead of manually writing XML or Python:
```
"Create a mesh of 5 routers with OSPF"
```
Generates a complete, valid topology with proper subnetting.

### 3. Caldera Integration
Automated deployment of adversary emulation:
- No manual Caldera setup required
- Agents auto-deploy to target nodes
- C2 infrastructure ready automatically

### 4. Remote Access
noVNC provides browser-based access to CORE GUI without local installation.

---

## File Inventory

### Files to Copy to makau_dt

```
# Core functionality (REQUIRED)
core-mcp-server/              # Entire directory
dockerfiles/                   # Entire directory
caldera-latest/               # Git submodule reference

# Documentation
CORE_MCP_SOLUTION.md
PROJECT_SUMMARY.md            # This file

# Configuration
.gitmodules                   # Submodule configuration
```

### Files to NOT copy (optional/temporary)

```
# Screenshots (development artifacts)
Screenshot*.png

# Build artifacts
*.egg-info/
__pycache__/
```

---

## Dependencies

### Python Packages
```
# core-mcp-server/pyproject.toml
mcp                    # Model Context Protocol
flask                  # Web framework
flask-cors             # CORS support
openai                 # OpenAI API (optional, for AI features)
pyyaml                 # YAML parsing
```

### System Dependencies (in Docker)
- CORE 9.2.0
- EMANE 1.5.1
- Python 3.10+
- Docker (for Docker nodes)
- TigerVNC + noVNC

### External Repositories
- `https://github.com/coreemu/core` - Upstream CORE (reference)
- `https://github.com/mitre/caldera` - MITRE Caldera (submodule)

---

## Usage Quick Reference

### Start the Environment
```bash
cd dockerfiles
./novnc/build-and-run.sh
# Access via http://localhost:6080
```

### Generate Topology via Web UI
```bash
# Inside container
cd /path/to/core-mcp-server
python3 web_ui.py
# Access via http://localhost:5000
```

### Generate Topology via CLI
```python
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()
gen.generate_from_description("Create a star topology with 4 hosts and a router")
xml = gen.to_xml()
python_script = gen.to_python_script()
```

### Configure MCP for Claude Desktop
```json
{
  "mcpServers": {
    "core-topology": {
      "command": "docker",
      "args": ["exec", "-i", "core-novnc", "/opt/core/venv/bin/python", "-m", "core_mcp.server"]
    }
  }
}
```

---

## Recommended makau_dt Structure

```
makau_dt/
├── README.md
├── docker-compose.yml           # Orchestrates all services
├── .gitmodules
│
├── core/                        # Git submodule → coreemu/core
│
├── caldera/                     # Git submodule → mitre/caldera
│
├── extensions/
│   ├── core-mcp-server/         # From this repo
│   │   ├── core_mcp/
│   │   ├── web_ui.py
│   │   ├── caldera_session_watcher.py
│   │   └── ...
│   │
│   └── dockerfiles/             # From this repo
│       ├── Dockerfile.novnc
│       ├── Dockerfile.caldera-core
│       ├── novnc/
│       └── ...
│
└── docs/
    ├── PROJECT_SUMMARY.md       # This file
    └── CORE_MCP_SOLUTION.md
```

---

## Version History

| Date | Commit | Description |
|------|--------|-------------|
| 2025-11-24 | `a6ca7e62` | Add CORE MCP Server with Caldera auto-deployment system |
| 2025-11-24 | `b5e5b71a` | Add project screenshots |

---

## Credits

- **CORE Network Emulator**: US Naval Research Laboratory / coreemu
- **MITRE Caldera**: MITRE Corporation
- **This Integration**: Built with Claude Code

---

## License

This project extends CORE which is licensed under BSD-2-Clause.
Caldera is licensed under Apache 2.0.
Custom extensions follow the CORE license.
