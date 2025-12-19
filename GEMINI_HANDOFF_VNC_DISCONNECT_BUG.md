# VNC Disconnect Bug - Handoff Document for Google Gemini

## Problem Summary
When a user deploys a template in the CORE network emulator web UI, the VNC connection to the CORE GUI disconnects. The VNC tab shows "Connecting..." indefinitely and never reconnects, even though the container restarts automatically.

## Critical Finding: X Session Dies with SIGKILL
The VNC logs show the root cause:
```
The X session died with signal 9!
Killing Xtigervnc process ID 381477...
```

This happens during template deployment. Something is sending SIGKILL (signal 9) to the X session, which kills the VNC server.

## Environment Details

### GCP VM
- IP: 136.116.14.145
- Instance: makau-core (us-central1-a)
- Access: `gcloud compute ssh makau-core --zone=us-central1-a`

### Container Configuration
```yaml
services:
  core-novnc:
    image: core-novnc:latest
    container_name: core-novnc
    privileged: true
    init: true
    pid: host  # IMPORTANT: Container shares host PID namespace
    ports:
      - "6080:6080"   # noVNC web interface
      - "6081-6085:6081-6085"  # HMI VNC proxies
      - "5901:5901"   # VNC server
      - "50051:50051" # CORE gRPC API
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock  # Docker socket mounted from HOST
    restart: unless-stopped
```

### Key Architectural Issues Identified

1. **`pid: host`**: The container shares the host PID namespace. When `pkill` commands run inside the container, they affect HOST processes.

2. **Docker socket mounted**: `/var/run/docker.sock` is mounted from host. Docker commands inside core-novnc operate on the HOST Docker daemon, NOT Docker-in-Docker.

3. **SIGTERM Pattern**: Container logs show repeated SIGTERM followed by restart:
   - 15:38:55 - SIGTERM received
   - 16:31:58 - SIGTERM received
   - 16:39:26 - SIGTERM received
   - 17:11:55 - SIGTERM received
   - 17:19:27 - SIGTERM received
   - 17:48:40 - SIGTERM received

## VNC Architecture

### Process Stack
1. **supervisord** - Process manager (PID 1 in container)
2. **Xtigervnc** - VNC server on display :1, port 5901
3. **websockify** - WebSocket proxy on port 6080, connects to localhost:5901
4. **core-gui** - CORE GUI application running on the X display

### Failure Mode
1. User clicks "Deploy" button in web UI
2. `/api/templates/<id>/deploy` endpoint is called
3. `load_topology.py` script runs inside container
4. Something sends SIGKILL to the X session
5. Xtigervnc dies, taking core-gui with it
6. websockify loses connection to VNC server
7. Browser shows "Connecting..." forever
8. Container eventually receives SIGTERM and restarts
9. After restart, VNC works until next deploy

## Key Files

### 1. load_topology.py (runs INSIDE core-novnc)
**Path**: `/opt/core/load_topology.py` (in container)
**Local**: `core-mcp-server/load_topology.py`

Key functions:
- `load_and_start()` - Main entry point for deployment
- `cleanup_vnc_proxies()` - Kills websockify/socat on ports 6081-6089
- `cleanup_docker_containers()` - Now a no-op (was causing issues)
- `full_cleanup()` - Calls the above cleanup functions

**pkill commands in this file**:
```python
# Line 92: Kill websockify on HMI ports (NOT 6080)
subprocess.run("pkill -f 'websockify.* 608[1-9]' 2>/dev/null", shell=True, ...)

# Line 96: Kill socat on internal ports
subprocess.run("pkill -f 'socat.*TCP-LISTEN:160' 2>/dev/null", shell=True, ...)

# Line 100: Kill socat on HMI ports
subprocess.run("pkill -f 'socat.*TCP-LISTEN:608[1-9]' 2>/dev/null", shell=True, ...)

# Line 631: Kill core-gui
subprocess.run("pkill -9 core-gui", shell=True, capture_output=True)
```

### 2. web_ui.py (runs on HOST)
**Path**: `core-mcp-server/web_ui.py`

Key endpoints:
- `/api/templates/<id>/deploy` - Template deployment
- `/api/builder/load-in-core` - ICS builder deployment

Both call `load_topology.py` via:
```python
load_cmd = f"""docker exec core-novnc bash -c '
    cd /opt/core &&
    ./venv/bin/python3 /opt/core/load_topology.py --start {container_path}
'"""
```

Pre-deploy cleanup in web_ui.py:
```python
vnc_cleanup_cmd = '''docker exec core-novnc bash -c '
    pkill -9 socat 2>/dev/null || true
    pkill -9 -f "websockify.* 608[1-9]" 2>/dev/null || true
    rm -f /tmp/ns_forward_*.sh 2>/dev/null || true
' '''
```

### 3. supervisord.conf (inside container)
**Path**: `/etc/supervisor/conf.d/supervisord.conf`
```ini
[program:core-daemon]
command=/opt/core/venv/bin/core-daemon
autorestart=true

[program:vnc]
command=/opt/start-vnc.sh
autorestart=true

[program:novnc]
command=/opt/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080
autorestart=true
```

### 4. start-vnc.sh (VNC startup script)
**Path**: `/opt/start-vnc.sh` (in container)
Starts Xtigervnc on display :1

## What We've Already Tried

1. **Removed VNC recovery code from web_ui.py** - Was spawning duplicate x11vnc/websockify processes

2. **Fixed cleanup_docker_containers()** - Changed to no-op because Docker commands were operating on HOST Docker, not Docker-in-Docker

3. **Fixed setup_vnc_proxies_for_hmi_nodes()** - Was trying to run `docker exec core-novnc` FROM INSIDE core-novnc (self-referential)

4. **Ensured pkill patterns don't match main VNC** - `608[1-9]` pattern should NOT match `6080`

## Suspected Root Causes (Unresolved)

### Hypothesis 1: CORE Session Cleanup Kills X
When `core.delete_session()` is called via gRPC, CORE might be killing processes that include the X session. The VNC log shows:
```
session(1) state(SessionState.DATACOLLECT)
session(1) state(SessionState.SHUTDOWN)
The X session died with signal 9!
```

The session state changes to SHUTDOWN right before the X session dies.

### Hypothesis 2: pid: host Causes pkill Collateral Damage
With `pid: host`, any `pkill` command inside the container affects host processes. Although patterns look safe, there might be an edge case.

### Hypothesis 3: CORE's core-cleanup or Similar
The blackbox.sh reference shows the traditional approach:
```bash
/usr/local/sbin/core-cleanup
pkill wish8.5
/etc/init.d/core-daemon restart
```

Maybe something is calling core-cleanup which kills VNC.

## Debugging Commands

### Check VNC status
```bash
docker exec core-novnc ps aux | grep -E 'Xtigervnc|websockify|supervisor'
docker exec core-novnc ss -tlnp | grep -E '590|608'
```

### View VNC logs
```bash
docker exec core-novnc cat /var/log/supervisor/vnc.log | tail -50
docker exec core-novnc cat /var/log/supervisor/vnc-error.log
```

### View container logs
```bash
docker logs core-novnc 2>&1 | tail -100
```

### Test VNC connectivity
```bash
curl -s -o /dev/null -w '%{http_code}' http://localhost:6080/vnc.html
```

### Monitor for SIGTERM during deploy
```bash
docker events --filter container=core-novnc
```

## Possible Solutions to Investigate

1. **Remove `pid: host`** - Isolate container PID namespace to prevent pkill collateral damage

2. **Trace SIGKILL source** - Use `strace` or audit logging to find what sends SIGKILL to Xtigervnc

3. **Modify CORE session handling** - Check if `delete_session()` or session state changes kill the X server

4. **Separate VNC from CORE** - Run VNC in a separate container that doesn't get affected by CORE operations

5. **Add VNC process protection** - Modify cleanup scripts to explicitly exclude VNC PIDs

## File Locations Summary

| File | Location | Purpose |
|------|----------|---------|
| load_topology.py | core-mcp-server/load_topology.py | Topology loading script |
| web_ui.py | core-mcp-server/web_ui.py | Flask web UI server |
| Dockerfile.novnc | dockerfiles/Dockerfile.novnc | Container build file |
| docker-compose.novnc.yml | dockerfiles/docker-compose.novnc.yml | Container configuration |
| supervisord.conf | dockerfiles/novnc/supervisord.conf | Process management |
| start-vnc.sh | dockerfiles/novnc/start-vnc.sh | VNC startup script |
| dashboard.html | core-mcp-server/templates/dashboard.html | Web UI frontend |

## Reproduction Steps

1. Access web UI at http://136.116.14.145:8080
2. Verify CORE tab shows VNC connection (desktop visible)
3. Go to Templates tab
4. Click Deploy on any template (e.g., "ICS Sorting Facility")
5. Watch CORE tab - it will disconnect
6. After deployment completes, CORE tab shows "Connecting..." forever
7. Check container logs - will show SIGTERM received and restart

## Expected Behavior

VNC connection should remain stable throughout topology deployment. The user should be able to watch the CORE GUI load the new topology without disconnection.
