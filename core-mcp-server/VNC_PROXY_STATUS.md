# VNC WebSocket Proxy - WORKING (2025-12-09)

## Goal - ACHIEVED
Make HMI VNC (phone-hmi1, hmi-workstation, etc.) work through port 8080 ONLY.
All VNC traffic is now proxied through the Flask web dashboard on port 8080.
No separate port forwarding for ports 6081-6089 is required.

## Working Architecture

```
Browser (noVNC)
    |
    v
WebSocket to :8080/hmi-vnc/<port>/websockify
    |
    v
VNCWebSocketMiddleware (web_ui.py:5056)
    |
    v
vnc_websocket_proxy_handler() (web_ui.py:3271)
    - Creates backend WebSocket to localhost:<port>/websockify
    - Bidirectional data forwarding using gevent greenlets
    |
    v
websockify on port 608X (inside core-novnc)
    - e.g., websockify:6081 -> localhost:16081
    |
    v
socat on port 1608X -> nsenter into container namespace
    - CRITICAL: connects to x11vnc port 5900, NOT websockify port 6080
    |
    v
x11vnc on container's localhost:5900
```

## Key Fix Applied

The ns_forward script was connecting to the container's websockify (port 6080), but websockify expects WebSocket protocol, not raw TCP. The fix was to connect to x11vnc directly on port 5900.

Before (broken):
```sh
#!/bin/sh
exec nsenter -n -t <PID> socat STDIO TCP:localhost:6080  # Wrong!
```

After (working):
```sh
#!/bin/sh
exec nsenter -n -t <PID> socat STDIO TCP:localhost:5900  # Correct!
```

## Verification Test

```python
# This test passes - VNC handshake received through port 8080
import websocket
ws = websocket.create_connection('ws://localhost:8080/hmi-vnc/6081/websockify')
data = ws.recv()  # Returns b'RFB 003.008\n'
```

## Key Files

1. **`/workspaces/core/core-mcp-server/web_ui.py`**
   - `VNCWebSocketMiddleware` class (~line 5056) - Intercepts WebSocket requests at WSGI level
   - `vnc_websocket_proxy_handler()` (~line 3271) - Bidirectional WebSocket proxy using gevent

2. **Inside core-novnc container**:
   - `/tmp/ns_forward_608X.sh` - nsenter script connecting to container's x11vnc (port 5900)
   - websockify listening on ports 6081-6089
   - socat on ports 16081-16089 forwarding via nsenter

## Browser Access

For Codespaces:
```
https://<codespace-name>-8080.app.github.dev/hmi-vnc/6081/vnc_lite.html?path=hmi-vnc/6081/websockify
```

For local development:
```
http://localhost:8080/hmi-vnc/6081/vnc_lite.html?path=hmi-vnc/6081/websockify
```

## Notes

- The web_ui.py proxy handler works with gevent-websocket
- Werkzeug 3.x compatibility issues were solved by using WSGI middleware instead of flask-sockets
- The proxy supports both binary and text WebSocket frames for noVNC compatibility

## Troubleshooting

### "Something went wrong" error in browser

If noVNC shows "Something went wrong, connection is closed" but the server-side test passes, the issue is on the browser side.

**Server-side test** (should see RFB version and security handshake):
```python
import websocket
ws = websocket.create_connection('ws://localhost:8080/hmi-vnc/6081/websockify')
print(ws.recv())  # Should print: b'RFB 003.008\n'
ws.send_binary(b'RFB 003.008\n')
print(ws.recv())  # Should print: b'\x01\x01' (security types)
ws.close()
```

**Common causes:**
1. Port 8080 not public in Codespaces - Make port 8080 **public** in Codespace port settings
2. VNC proxy chain not started - Run `./setup_hmi_vnc_proxies.sh`
3. Container PID changed - The VNC proxy uses container PID. If session restarted, re-run proxy setup

### VNC proxy chain must be re-created when:
- CORE session is stopped and restarted
- Container is recreated
- Container PID changes

To re-setup VNC proxies after session restart:
```bash
./setup_hmi_vnc_proxies.sh
```

Or manually:
```bash
# Get current container PID
PID=$(docker exec core-novnc docker inspect phone-hmi1 --format '{{.State.Pid}}')

# Create nsenter script
docker exec core-novnc bash -c "cat > /tmp/ns_forward_6081.sh << EOFSCRIPT
#!/bin/sh
exec nsenter -n -t $PID socat STDIO TCP:localhost:5900
EOFSCRIPT
chmod +x /tmp/ns_forward_6081.sh"

# Start proxy chain
docker exec core-novnc pkill -f 'websockify.*6081' || true
docker exec core-novnc pkill -f 'socat.*16081' || true
sleep 1
docker exec -d core-novnc socat TCP-LISTEN:16081,fork,reuseaddr EXEC:/tmp/ns_forward_6081.sh
docker exec -d core-novnc python3 -m websockify --web /opt/noVNC 6081 localhost:16081
```
