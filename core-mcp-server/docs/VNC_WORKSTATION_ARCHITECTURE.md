# VNC/noVNC Workstation Architecture for CORE Network Emulator

## Overview

This document describes the architecture for providing remote desktop access (via noVNC) to Docker-based workstation nodes running inside CORE network emulation. **This is critical infrastructure - do not modify without understanding the full flow.**

## The Problem

CORE Docker nodes run in isolated network namespaces. When you deploy an HMI or Engineering workstation as a Docker node in CORE:

1. The container runs with `network: none` (no Docker networking)
2. CORE attaches virtual ethernet interfaces to the container's network namespace
3. The container gets an IP like `10.0.1.50` which is **only routable within the emulated network**
4. The `core-novnc` container **cannot directly reach** these IPs

```
┌─────────────────────────────────────────────────────────────────┐
│                     core-novnc container                        │
│  ┌─────────────────┐                                            │
│  │ Web UI :8080    │                                            │
│  │ noVNC :6080     │   Cannot reach 10.0.1.50 directly!         │
│  └─────────────────┘                                            │
│           │                                                     │
│  ┌────────┴────────────────────────────────────────────┐        │
│  │           Docker-in-Docker (DinD)                    │        │
│  │  ┌──────────────────┐    ┌──────────────────┐       │        │
│  │  │  hmi1 container  │    │  hmi2 container  │       │        │
│  │  │  network: none   │    │  network: none   │       │        │
│  │  │  (isolated ns)   │    │  (isolated ns)   │       │        │
│  │  │                  │    │                  │       │        │
│  │  │  eth0: 10.0.1.50 │    │  eth0: 10.0.1.51 │       │        │
│  │  │  VNC: 5900       │    │  VNC: 5900       │       │        │
│  │  │  noVNC: 6080     │    │  noVNC: 6080     │       │        │
│  │  └──────────────────┘    └──────────────────┘       │        │
│  │         ↑ CORE veth          ↑ CORE veth            │        │
│  └─────────┴────────────────────┴──────────────────────┘        │
│                      CORE Network Emulation                     │
└─────────────────────────────────────────────────────────────────┘
```

## The Solution: nsenter + socat Bridge

The solution uses Linux namespace tools to bridge the network gap:

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     core-novnc container                        │
│                                                                 │
│  Browser → :6081 → socat → nsenter -n -t PID → localhost:6080   │
│                              ↓                                  │
│                    (enters hmi1's network namespace)            │
│                              ↓                                  │
│                    hmi1's websockify on :6080                   │
│                              ↓                                  │
│                    hmi1's x11vnc on :5900                       │
│                              ↓                                  │
│                    hmi1's Xvfb display :1                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Inside the HMI container:**
   - `supervisord` manages: Xvfb, fluxbox, x11vnc, websockify
   - `websockify` listens on `localhost:6080` and forwards to `localhost:5900` (VNC)
   - This is all within the container's isolated network namespace

2. **The bridge (in core-novnc's namespace):**
   - A wrapper script is created: `/tmp/ns_forward_608X.sh`
   - This script uses `nsenter -n -t <PID>` to enter the container's network namespace
   - Then runs `socat STDIO TCP:localhost:6080` to connect to the HMI's websockify

3. **The proxy (accessible from outside):**
   - `socat TCP-LISTEN:608X,fork,reuseaddr EXEC:/tmp/ns_forward_608X.sh`
   - Listens on port 608X in core-novnc's main namespace
   - Each connection forks and executes the wrapper script
   - This bridges outside traffic to the isolated HMI container

## Required Components

### 1. HMI/Workstation Dockerfile Requirements

The Docker image MUST include:

```dockerfile
# REQUIRED: supervisord to manage desktop services
supervisor \

# REQUIRED: X11 virtual framebuffer
xvfb \

# REQUIRED: VNC server
x11vnc \

# REQUIRED: Window manager
fluxbox \

# REQUIRED: noVNC websocket bridge (inside container)
novnc \
websockify \

# OPTIONAL but helps debugging:
socat \
```

### 2. Supervisord Configuration

The container MUST have `/etc/supervisor/conf.d/desktop.conf`:

```ini
[supervisord]
nodaemon=true
logfile=/var/log/supervisor/supervisord.log

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1280x720x24
autorestart=true
priority=100

[program:fluxbox]
command=/usr/bin/fluxbox
environment=DISPLAY=":1"
autorestart=true
priority=200

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -forever -shared -rfbport 5900 -nopw
autorestart=true
priority=300

[program:novnc]
command=/usr/bin/websockify --web=/usr/share/novnc/ 6080 localhost:5900
autorestart=true
priority=400
```

### 3. Startup Entrypoint

The container MUST start supervisord on boot:

```bash
#!/bin/bash
# Start supervisord in background
nohup /usr/bin/supervisord -c /etc/supervisor/conf.d/desktop.conf > /var/log/supervisor/supervisord.log 2>&1 &
```

## Port Mapping

The `core-novnc` container only exposes specific ports:

| Port | Usage |
|------|-------|
| 6080 | Main core-novnc desktop |
| 6081 | HMI workstation proxy #1 |
| 6082 | HMI workstation proxy #2 |
| 6083 | HMI workstation proxy #3 |

**IMPORTANT:** Only ports 6081-6083 are available for HMI proxies. If you need more, update the core-novnc Docker run command.

## API Endpoint

The VNC proxy is set up via `POST /api/start-host-vnc`:

```json
{
  "node_name": "hmi1",
  "proxy_port": 6081  // optional, auto-assigned if not provided
}
```

Response:
```json
{
  "success": true,
  "container": "hmi1",
  "node_ip": "10.0.1.50",
  "proxy_port": 6081,
  "vnc_url": "https://<codespace>-6081.app.github.dev/vnc_lite.html?scale=true&path="
}
```

**IMPORTANT:** The `&path=` parameter is required because websockify serves the WebSocket at the root path `/`, not at `/websockify` (the noVNC default). Without this parameter, the connection will fail.

## Common Issues and Solutions

### Issue: "Grey frowny face" or "Connection failed" in noVNC

**Cause:** VNC server not running, proxy not connected, or WebSocket path misconfigured.

**Solution:**
1. Check if supervisord is running in the HMI container:
   ```bash
   docker exec core-novnc docker exec hmi1 pgrep supervisord
   ```
2. If not, start it:
   ```bash
   docker exec core-novnc docker exec hmi1 supervisord -c /etc/supervisor/conf.d/desktop.conf &
   ```
3. Check if the socat proxy is running:
   ```bash
   docker exec core-novnc pgrep -af socat
   ```
4. Call the VNC start API to set up the proxy
5. **Verify the URL includes `&path=`** - The vnc_lite.html URL MUST include `?...&path=` to override the default `/websockify` path

### Issue: WebSocket connection fails but HTML loads

**Cause:** The noVNC `vnc_lite.html` defaults to connecting to the WebSocket path `/websockify`, but websockify inside the HMI container serves the WebSocket at the root path `/`.

**Solution:** Ensure the VNC URL includes `&path=` (empty path):
```
# Correct URL format:
https://<codespace>-6081.app.github.dev/vnc_lite.html?scale=true&path=

# Incorrect (will fail):
https://<codespace>-6081.app.github.dev/vnc_lite.html?scale=true
```

### Issue: "fbsetbg: I can't find an app to set the wallpaper"

**Cause:** Fluxbox tries to set wallpaper but no tool is installed.

**Solution:** Install `feh` in the Dockerfile and create `/root/.fluxbox/startup`:
```bash
# In Dockerfile
RUN apt-get install -y feh

RUN mkdir -p /root/.fluxbox && \
    echo 'fbsetbg -solid "#2d2d2d"' > /root/.fluxbox/startup && \
    echo 'exec fluxbox' >> /root/.fluxbox/startup
```

### Issue: "No available proxy ports" error

**Cause:** Stale VNC proxies from previous topology sessions are occupying ports 6081-6083. The wrapper scripts point to PIDs of containers that no longer exist.

**Solution:** The API now auto-cleans stale proxies (as of 2025-12-01). If you still encounter this:
```bash
# Manually clean up stale socat proxies
docker exec core-novnc pkill -f 'socat.*608' 2>/dev/null
docker exec core-novnc rm -f /tmp/ns_forward_608*.sh 2>/dev/null
```

### Issue: Container name conflict on redeploy

**Cause:** Previous CORE session left Docker containers that weren't cleaned up.

**Solution:** Use the cleanup API before deploying:
```bash
curl -X POST http://localhost:8080/api/docker/cleanup -H "Content-Type: application/json" -d '{"all_stopped": true}'
```

## Do NOT Break These Things

1. **Do NOT remove `websockify` from the HMI Dockerfile** - It's required for the noVNC bridge inside the container

2. **Do NOT change the supervisord port configuration** - x11vnc MUST be on 5900, websockify MUST be on 6080

3. **Do NOT assume core-novnc can reach container IPs directly** - The nsenter+socat bridge is required

4. **Do NOT use ports outside 6081-6083 for proxies** - They aren't exposed from the container

5. **Do NOT start websockify in core-novnc pointing to container IPs** - It won't work due to network namespace isolation

## Code References

- VNC proxy setup: `web_ui.py:start_host_vnc()` (lines 2334-2500)
- HMI Dockerfile: `dockerfiles/Dockerfile.hmi-workstation`
- Engineering Workstation: `dockerfiles/Dockerfile.engineering-workstation`
