# Caldera + Sandcat Auto-Deployment System

## Overview

This system provides automated deployment of MITRE Caldera adversary emulation platform and Sandcat agents within NRL CORE network emulation sessions. When a CORE session with a Caldera Docker container starts, the system automatically:

1. Starts the Caldera server
2. Waits for it to become ready
3. Deploys Sandcat agents on target hosts

## Architecture

### Components

1. **`caldera-mcp-core` Docker Image** (`/workspaces/core/caldera-latest/Dockerfile.core`)
   - CORE-compatible Caldera image with networking tools (iproute2, ethtool, etc.)
   - No ENTRYPOINT (required for CORE Docker nodes)
   - Built-in scripts: `/start-caldera.sh`, `/deploy-sandcat.sh`
   - Plugins: access, atomic, compass, debrief, fieldmanual, human, magma, manx, response, sandcat, stockpile, training

2. **Topology Generator** (`/workspaces/core/core-mcp-server/core_mcp/topology_generator.py`)
   - Generates CORE XML topologies from natural language
   - Auto-generates startup scripts for Caldera deployments
   - Tracks Caldera server IP and target hosts

3. **Session Watcher** (`/workspaces/core/core-mcp-server/caldera_session_watcher.py`)
   - Daemon that monitors CORE sessions for Caldera containers
   - Auto-deploys when sessions enter RUNTIME state
   - Uses `docker exec` for Caldera (Docker node) and `vcmd` for targets (host nodes)

4. **Web UI** (`/workspaces/core/core-mcp-server/web_ui.py`)
   - API endpoints for topology generation and deployment
   - `/api/generate` - Generate topology from description
   - `/api/copy-to-core` - Send topology to CORE container
   - `/api/start-and-deploy` - Manual deployment trigger

## How It Works

### Automatic Deployment Flow

1. User generates a Caldera topology:
   ```
   "Create a caldera server with 5 target hosts"
   ```

2. Topology generator creates:
   - 1 switch (switch1)
   - 1 Caldera Docker node (caldera1) @ 10.0.1.2
   - N target hosts (target1, target2, ...) @ 10.0.1.3+
   - Startup scripts for auto-deployment

3. User sends topology to CORE and starts the session

4. Session watcher detects:
   - Session in RUNTIME state
   - Docker node with `caldera` in image name
   - Target hosts (nodes named target*, host*, client*, victim*)

5. Watcher auto-deploys:
   - Starts Caldera via `docker exec caldera1 /start-caldera.sh`
   - Waits up to 120s for Caldera to respond on port 8888
   - Deploys Sandcat agents on targets via `vcmd`

### Key Files Modified/Created

```
core-mcp-server/
├── core_mcp/
│   └── topology_generator.py    # Startup scripts, auto_deploy flag
├── web_ui.py                    # API endpoints for deployment
├── caldera_session_watcher.py   # Auto-deployment daemon
├── start_and_deploy.py          # Manual deployment script
├── load_topology.py             # CORE XML loader
└── scripts/
    ├── deploy-caldera-agents.sh # Shell-based deployment
    └── deploy-sandcat.sh        # Standalone Sandcat deployer

caldera-latest/
├── Dockerfile.core              # CORE-compatible Caldera image
└── conf/default.yml             # Caldera config with plugins
```

## Usage

### Option 1: Automatic (Recommended)

1. Start the session watcher in the CORE container:
   ```bash
   docker exec -d core-novnc bash -c 'cd /opt/core && ./venv/bin/python3 /opt/core/caldera_session_watcher.py --interval 5 > /tmp/caldera_watcher.log 2>&1'
   ```

2. Generate and deploy a Caldera topology via Web UI or API:
   ```bash
   curl -X POST http://localhost:8080/api/generate \
     -H "Content-Type: application/json" \
     -d '{"description": "caldera with 5 targets"}'

   curl -X POST http://localhost:8080/api/copy-to-core \
     -H "Content-Type: application/json" \
     -d '{"auto_open": true}'
   ```

3. Click **Start** in CORE GUI

4. Wait ~2 minutes for agents to appear in Caldera UI

### Option 2: Manual Deployment

After starting a Caldera session in CORE:

```bash
# Inside CORE container
/opt/core/venv/bin/python3 /tmp/start_and_deploy.py <SESSION_ID>

# Or use the shell script
/workspaces/core/core-mcp-server/scripts/deploy-caldera-agents.sh <SESSION_ID> caldera1 10.0.1.2
```

### Accessing Caldera

- **URL**: http://10.0.1.2:8888 (from inside CORE network)
- **Credentials**:
  - Red team: `red` / `admin`
  - Blue team: `blue` / `admin`

## Pending Work

### Known Issues

1. **Session watcher needs manual start**: Currently must be started manually in CORE container. Could be added to supervisord config for auto-start.

2. **vcmd path for targets**: Target hosts use `/tmp/pycore.<SESSION_ID>/<node_name>` socket. Verify this path exists when session starts.

### Future Improvements

1. **Add watcher to supervisord**: Make watcher auto-start with CORE container
2. **Web UI button**: Add "Deploy Now" button to web interface
3. **Status monitoring**: Show deployment status in web UI
4. **Multiple Caldera support**: Handle multiple Caldera nodes in same session

## Debugging

### Check watcher log
```bash
docker exec core-novnc cat /tmp/caldera_watcher.log
```

### Check if watcher is running
```bash
docker exec core-novnc ps aux | grep caldera_session
```

### Check Caldera startup log
```bash
docker exec caldera1 cat /tmp/caldera.log
```

### Check Sandcat agent log (on target)
```bash
vcmd -c /tmp/pycore.1/target1 -- cat /tmp/sandcat.log
```

### Manually start Caldera
```bash
docker exec caldera1 /start-caldera.sh
```

### Manually deploy Sandcat
```bash
vcmd -c /tmp/pycore.1/target1 -- bash -c '
  curl -s -X POST -H "file:sandcat.go" -H "platform:linux" "http://10.0.1.2:8888/file/download" -o /tmp/sandcat
  chmod +x /tmp/sandcat
  /tmp/sandcat -server "http://10.0.1.2:8888" -group red -v
'
```

## Technical Details

### CORE Docker Node Execution

- **Docker nodes**: Use `docker exec <node_name> bash -c "<command>"`
- **Host nodes**: Use `vcmd -c /tmp/pycore.<session_id>/<node_name> -- bash -c "<command>"`

### IP Address Assignment

- Switch: Node 1 (no IP)
- Caldera: Node 2 @ 10.0.1.2
- Targets: Node 3+ @ 10.0.1.3, 10.0.1.4, ...

### Sandcat Agent Deployment

1. Download agent binary from Caldera: `POST /file/download` with headers `file:sandcat.go`, `platform:linux`
2. Make executable: `chmod +x /tmp/sandcat`
3. Run with server URL: `/tmp/sandcat -server http://<caldera_ip>:8888 -group red -v`
