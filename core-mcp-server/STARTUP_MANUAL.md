# Startup Manual

This guide covers how to start all services for the CORE Network Emulator + IoT Digital Twin platform.

## Prerequisites

- Docker installed and running
- GitHub Codespaces or local environment with Docker support

## Quick Start (TL;DR)

```bash
# 1. Start the core-novnc container
docker start core-novnc

# 2. Fix VNC to listen on all interfaces and start CORE GUI
docker exec core-novnc bash -c "vncserver -kill :1 2>/dev/null; sleep 1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
docker exec core-novnc bash -c "export DISPLAY=:1 && nohup /opt/core/venv/bin/core-gui &"

# 3. Start the Web Dashboard
cd /workspaces/core/core-mcp-server
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
```

## Service URLs

### GitHub Codespaces

| Service | URL |
|---------|-----|
| **Web Dashboard** | `https://<codespace-name>-8080.app.github.dev` |
| **noVNC Desktop** | `https://<codespace-name>-6080.app.github.dev` |

### Local Development

| Service | URL |
|---------|-----|
| **Web Dashboard** | `http://localhost:8080` |
| **noVNC Desktop** | `http://localhost:6080` |

**VNC Password:** `core123`

### Important: Port Visibility for HMI VNC (Codespaces)

HMI workstation VNC uses ports **6081-6083**. In GitHub Codespaces, these ports must be set to **Public** for noVNC to work:

1. Open the **PORTS** panel in VS Code (bottom bar)
2. Find ports 6081, 6082, 6083
3. Right-click each → **Port Visibility** → **Public**

If ports are Private, the noVNC WebSocket connection will hang on "loading" because it can't complete through GitHub's authentication redirect.

---

## Detailed Startup Steps

### Step 1: Start the core-novnc Container

The `core-novnc` container provides:
- CORE Network Emulator daemon
- VNC server for remote desktop
- noVNC for browser-based access
- Docker-in-Docker for containerized network nodes

```bash
# Check if container exists
docker ps -a | grep core-novnc

# Start the container
docker start core-novnc

# Verify it's running
docker ps | grep core-novnc
```

### Step 2: Start VNC Server (Important!)

The VNC server may start with `-localhost=1` which prevents the dashboard from connecting. You must restart it with `-localhost no`:

```bash
# Kill existing VNC and restart with correct settings
docker exec core-novnc bash -c "vncserver -kill :1 2>/dev/null; sleep 1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
```

**Why this matters:** The dashboard's embedded VNC viewer connects via websocket proxy. If VNC only listens on localhost (127.0.0.1), the connection fails.

Verify VNC is listening on all interfaces:
```bash
docker exec core-novnc netstat -tlnp | grep 5901
# Should show: 0.0.0.0:5901 (not 127.0.0.1:5901)
```

### Step 3: Start CORE GUI

```bash
docker exec core-novnc bash -c "export DISPLAY=:1 && nohup /opt/core/venv/bin/core-gui &"
```

Verify CORE GUI is running:
```bash
docker exec core-novnc pgrep -a core-gui
```

### Step 4: Start the Web Dashboard

```bash
cd /workspaces/core/core-mcp-server
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
```

Check if it's running:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/
# Should return: 200
```

View logs if needed:
```bash
tail -f /tmp/webui.log
```

---

## Optional Services

These services are started **automatically when loading a topology** that requires them. You don't need to start them manually.

| Service | Started By | Purpose |
|---------|------------|---------|
| `mqtt-broker` | IoT topologies | MQTT message broker |
| `iot-sensor-server` | IoT topologies | Sensor data display |
| `hmi-workstation` | ICS topologies | HMI interface |

---

## Troubleshooting

### Problem: Dashboard shows blank/black VNC viewer

**Cause:** VNC server listening on localhost only

**Fix:**
```bash
docker exec core-novnc bash -c "vncserver -kill :1 2>/dev/null; sleep 1; vncserver :1 -geometry 1920x1080 -depth 24 -localhost no"
docker exec core-novnc bash -c "export DISPLAY=:1 && nohup /opt/core/venv/bin/core-gui &"
```

### Problem: "Connection refused" on port 6080

**Cause:** Container not running or websockify not started

**Fix:**
```bash
docker start core-novnc
# Wait a few seconds for supervisord to start services
sleep 5
```

### Problem: CORE GUI not visible in VNC

**Cause:** CORE GUI process not started

**Fix:**
```bash
docker exec core-novnc bash -c "export DISPLAY=:1 && /opt/core/venv/bin/core-gui &"
```

### Problem: Web dashboard not responding

**Cause:** web_ui.py not running

**Fix:**
```bash
cd /workspaces/core/core-mcp-server
pkill -f web_ui.py
nohup python3 web_ui.py --host 0.0.0.0 --port 8080 > /tmp/webui.log 2>&1 &
```

### Problem: Stale VNC lock files

**Cause:** Container was stopped ungracefully

**Fix:**
```bash
docker exec core-novnc rm -f /tmp/.X1-lock /tmp/.X11-unix/X1
docker exec core-novnc vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
```

---

## Verify All Services

Run this to check everything is working:

```bash
echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}" | grep core-novnc

echo ""
echo "=== VNC Server ==="
docker exec core-novnc netstat -tlnp 2>/dev/null | grep 5901

echo ""
echo "=== CORE GUI ==="
docker exec core-novnc pgrep -a core-gui || echo "NOT RUNNING"

echo ""
echo "=== Web Dashboard ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/ || echo "NOT RUNNING"

echo ""
echo "=== noVNC ==="
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:6080/ || echo "NOT RUNNING"
```

---

## HMI Workstation VNC Troubleshooting

HMI workstations (like `hmi1`, `phone-hmi1`) run inside CORE's Docker-in-Docker network. They require a special **two-layer proxy chain** to make VNC accessible from outside.

### Understanding the Architecture

The VNC proxy uses a two-layer chain for reliability (especially with GitHub Codespaces):

```
Browser → Port 6081 (websockify) → Port 16081 (socat)
                                        ↓
                                  nsenter -n -t PID
                                        ↓
                                  HMI container namespace
                                        ↓
                                  websockify :6080
                                        ↓
                                  x11vnc :5900
                                        ↓
                                  Xvfb display :1
```

**Two-Layer Proxy Chain:**
- **Layer 1 (websockify on 608X)**: Handles WebSocket protocol and serves noVNC web files
- **Layer 2 (socat on 1608X)**: Uses nsenter to bridge into container's network namespace

**Why two layers?**
- Raw socat doesn't properly handle WebSocket protocol through Codespaces port forwarding
- websockify provides the WebSocket layer and serves noVNC HTML/JS files
- socat handles the namespace bridging via nsenter

**Key Points:**
- HMI containers run with `network: none` (isolated from Docker networking)
- CORE attaches virtual interfaces with IPs like `10.0.1.50`
- These IPs are **not routable** from core-novnc's main namespace
- The two-layer proxy chain bridges the network namespace gap

### Quick Diagnostics

Use the diagnostic tool:
```bash
cd /workspaces/core/core-mcp-server
python3 vnc_diagnostics.py diagnose
```

### Common HMI VNC Issues

#### Issue: "Grey frowny face" or blank HMI VNC viewer

**Cause 1: VNC services not running inside HMI container**

Check:
```bash
docker exec core-novnc docker exec <hmi-container> pgrep -f supervisord
docker exec core-novnc docker exec <hmi-container> pgrep -f websockify
```

Fix:
```bash
docker exec core-novnc docker exec <hmi-container> supervisord -c /etc/supervisor/conf.d/desktop.conf &
```

**Cause 2: Stale socat proxy pointing to dead PID**

When you stop/restart a CORE session, the container PIDs change but the socat wrapper scripts still reference old PIDs.

Check:
```bash
# View wrapper script
docker exec core-novnc cat /tmp/ns_forward_6081.sh

# Check if PID is valid
docker exec core-novnc kill -0 <PID_FROM_SCRIPT> 2>/dev/null && echo "Valid" || echo "STALE"
```

Fix:
```bash
# Cleanup and re-setup
docker exec core-novnc pkill -f 'socat.*6081.*ns_forward'
docker exec core-novnc rm -f /tmp/ns_forward_6081.sh

# Then trigger VNC setup from dashboard or API
curl -X POST http://localhost:8080/api/start-host-vnc \
  -H "Content-Type: application/json" \
  -d '{"node_name": "hmi1"}'
```

**Cause 3: Wrong WebSocket path**

The VNC URL **must** include `&path=` (empty path) because websockify serves at root, not `/websockify`.

Correct: `https://...6081.../vnc_lite.html?scale=true&path=`
Wrong: `https://...6081.../vnc_lite.html?scale=true`

#### Issue: "No available proxy ports" error

**Cause:** All 3 proxy ports (6081-6083) are occupied by stale proxies.

Fix:
```bash
# Force cleanup all proxies
python3 vnc_diagnostics.py cleanup

# Or manually:
docker exec core-novnc pkill -f 'socat.*TCP-LISTEN:608'
docker exec core-novnc rm -f /tmp/ns_forward_*.sh
```

#### Issue: HMI VNC works initially but fails after session restart

**Cause:** Session restart changes container PIDs, invalidating existing proxies.

**Best Practice:** Always run cleanup before starting a new session:
```bash
python3 vnc_diagnostics.py cleanup
# Then start your topology
```

Or use the automatic repair:
```bash
python3 vnc_diagnostics.py repair
```

### Manual HMI VNC Setup

If automatic setup fails, manually set up VNC for an HMI node:

```bash
# 1. Find the container name
docker exec core-novnc docker ps --format '{{.Names}}' | grep hmi

# 2. Get container PID
CONTAINER=hmi1.12345  # Replace with actual name
PID=$(docker exec core-novnc docker inspect $CONTAINER --format '{{.State.Pid}}')
echo "Container PID: $PID"

# 3. Start VNC services inside container
docker exec core-novnc docker exec $CONTAINER supervisord -c /etc/supervisor/conf.d/desktop.conf &
sleep 5

# 4. Verify services are running
docker exec core-novnc docker exec $CONTAINER pgrep -f websockify

# 5. Create wrapper script
PORT=6081
docker exec core-novnc bash -c "echo '#!/bin/bash
exec nsenter -t $PID -n socat STDIO TCP:localhost:6080' > /tmp/ns_forward_$PORT.sh && chmod +x /tmp/ns_forward_$PORT.sh"

# 6. Start socat proxy
docker exec core-novnc bash -c "nohup socat TCP-LISTEN:$PORT,fork,reuseaddr EXEC:/tmp/ns_forward_$PORT.sh > /tmp/socat_$PORT.log 2>&1 &"

# 7. Test connection
docker exec core-novnc bash -c "timeout 2 bash -c 'echo | /tmp/ns_forward_$PORT.sh' && echo 'SUCCESS' || echo 'FAILED'"
```

### Verify Complete HMI VNC Stack

```bash
echo "=== HMI VNC Status ==="

# 1. Check HMI containers
echo "--- HMI Containers ---"
docker exec core-novnc docker ps --format 'table {{.Names}}\t{{.Image}}' | grep -i hmi

# 2. Check VNC services inside each HMI
for container in $(docker exec core-novnc docker ps --format '{{.Names}}' | grep -i hmi); do
    echo ""
    echo "--- $container ---"
    docker exec core-novnc docker exec $container pgrep -af "supervisord|websockify|x11vnc" 2>/dev/null || echo "VNC services not running"
done

# 3. Check socat proxies
echo ""
echo "--- Socat Proxies ---"
docker exec core-novnc pgrep -af 'socat.*TCP-LISTEN:608[1-3]' || echo "No proxies running"

# 4. Check wrapper scripts
echo ""
echo "--- Wrapper Scripts ---"
docker exec core-novnc ls -la /tmp/ns_forward_608*.sh 2>/dev/null || echo "No wrapper scripts"
```

---

## CORE Session Hooks (Automation)

CORE supports session hooks - shell scripts that run automatically at specific session states. This is useful for automating setup tasks like VNC proxy configuration.

### Session States

| State | Value | When it Runs |
|-------|-------|--------------|
| DEFINITION | 1 | Session created, clearing backend |
| CONFIGURATION | 2 | User pressed Start or customizing |
| INSTANTIATION | 3 | Just before node creation |
| **RUNTIME** | **4** | **All nodes operational** |
| DATACOLLECT | 5 | After Stop, before shutdown |
| SHUTDOWN | 6 | Nodes destroyed |

### Hook Naming Convention

Hook scripts are named with the format: `<state>:<script_name>.sh`

Example: `4:vnc_proxy_setup.sh` runs at RUNTIME state (4)

### VNC Proxy Setup Hook

The `hooks/4:vnc_proxy_setup.sh` script automatically sets up VNC proxies for HMI workstations when a session starts:

```bash
# Location: hooks/4:vnc_proxy_setup.sh
# Runs at: RUNTIME_STATE (4) - when all nodes are operational
# Purpose: Automatically configure VNC proxies for HMI nodes
```

### Session Event Listener (Alternative)

For more control, use `core_session_listener.py` which listens for session state changes via gRPC:

```bash
# Run alongside web_ui.py
nohup python3 core_session_listener.py > /tmp/session_listener.log 2>&1 &
```

This daemon:
- Monitors for new CORE sessions
- Automatically sets up VNC proxies when sessions enter RUNTIME
- Cleans up proxies when sessions shut down

### Embedding Hooks in Topology XML

Hooks can be embedded directly in topology XML files:

```xml
<session_hooks>
  <hook name="4:vnc_proxy_setup.sh" state="4">#!/bin/bash
# Your script content here
curl -X POST http://localhost:8080/api/start-host-vnc \
  -H "Content-Type: application/json" \
  -d '{"node_name": "hmi1"}'
  </hook>
</session_hooks>
```

---

## Stopping Services

```bash
# Stop web dashboard
pkill -f web_ui.py

# Stop the container (preserves state)
docker stop core-novnc

# Remove container completely (loses state)
docker rm core-novnc
```

---

## Architecture Reference

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Codespaces Host                    │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                 core-novnc Container                    │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐ │ │
│  │  │ supervisord │  │ core-daemon │  │   Xtigervnc    │ │ │
│  │  │   (PID 1)   │  │  (gRPC API) │  │  (Display :1)  │ │ │
│  │  └─────────────┘  └─────────────┘  └────────────────┘ │ │
│  │                                           │            │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────┴──────────┐ │ │
│  │  │  websockify │  │  core-gui   │  │    Fluxbox     │ │ │
│  │  │ (port 6080) │  │  (Tk GUI)   │  │ (Window Mgr)   │ │ │
│  │  └─────────────┘  └─────────────┘  └────────────────┘ │ │
│  │         │                                              │ │
│  │         │ Port 6080 (noVNC)                           │ │
│  └─────────┼──────────────────────────────────────────────┘ │
│            │                                                 │
│  ┌─────────┼──────────────────────────────────────────────┐ │
│  │         │            Web Dashboard                      │ │
│  │         │           (web_ui.py)                        │ │
│  │         │            Port 8080                          │ │
│  │         │                                               │ │
│  │  ┌──────┴───────┐  ┌─────────────┐  ┌────────────────┐ │ │
│  │  │ Embedded VNC │  │  Topology   │  │   Micro:bit    │ │ │
│  │  │   Viewer     │  │  Templates  │  │   WebSerial    │ │ │
│  │  └──────────────┘  └─────────────┘  └────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```
