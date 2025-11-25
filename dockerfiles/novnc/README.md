# CORE with noVNC - Web-Based GUI Access

This setup allows you to run CORE with a GUI accessible through a web browser using noVNC.

## Overview

- **VNC Server**: TigerVNC provides the X11 display server
- **Window Manager**: Fluxbox (lightweight)
- **noVNC**: Web-based VNC client accessible via browser
- **CORE GUI**: Runs automatically on VNC startup
- **CORE Daemon**: Runs in background via supervisor

## Architecture

```
Browser (port 6080) -> noVNC -> Websockify -> VNC Server (port 5901) -> X11 Display :1 -> CORE GUI
```

## Quick Start

### Using Docker Compose (Recommended)

1. Build and start the container:
```bash
cd /workspaces/core/dockerfiles
docker-compose -f docker-compose.novnc.yml up -d
```

2. Access the GUI:
- Open your browser to: `http://localhost:6080`
- Click "Connect"
- Enter password: `core123`
- The CORE GUI will be running

3. Stop the container:
```bash
docker-compose -f docker-compose.novnc.yml down
```

### Using Docker Build Manually

1. Build the image:
```bash
cd /workspaces/core
docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest .
```

2. Run the container:
```bash
docker run -d \
  --name core-novnc \
  --privileged \
  --init \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 50051:50051 \
  -e VNC_RESOLUTION=1920x1080 \
  -e VNC_DEPTH=24 \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  core-novnc:latest
```

3. Access via browser: `http://localhost:6080`

## Ports

- **6080**: noVNC web interface (HTTP)
- **5901**: VNC server (for native VNC clients)
- **50051**: CORE gRPC API

## Environment Variables

- `VNC_RESOLUTION`: Display resolution (default: `1920x1080`)
- `VNC_DEPTH`: Color depth (default: `24`)
- `DISPLAY`: X11 display (default: `:1`)

## Default Credentials

- **VNC Password**: `core123`

To change the password, modify the Dockerfile:
```dockerfile
RUN echo "your_password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd
```

## Accessing from Remote Hosts

If running on a remote server, access via:
```
http://<server-ip>:6080
```

For secure access, consider using SSH tunnel:
```bash
ssh -L 6080:localhost:6080 user@remote-host
```
Then access via: `http://localhost:6080`

## Using Native VNC Clients

You can also connect using native VNC clients (like TigerVNC Viewer, RealVNC, etc.):

```bash
# Connection string
localhost:5901
# or
localhost:1
```

## Troubleshooting

### GUI not appearing
Check logs:
```bash
docker logs core-novnc
```

Or check individual service logs:
```bash
docker exec -it core-novnc cat /var/log/supervisor/vnc.log
docker exec -it core-novnc cat /var/log/supervisor/novnc.log
docker exec -it core-novnc cat /var/log/supervisor/core-daemon.log
```

### Restart services inside container
```bash
docker exec -it core-novnc supervisorctl restart all
```

Or restart individual services:
```bash
docker exec -it core-novnc supervisorctl restart vnc
docker exec -it core-novnc supervisorctl restart novnc
docker exec -it core-novnc supervisorctl restart core-daemon
```

### Black screen or VNC connection issues
1. Check VNC is running:
```bash
docker exec -it core-novnc ps aux | grep vnc
```

2. Try restarting VNC:
```bash
docker exec -it core-novnc supervisorctl restart vnc
```

3. Check display:
```bash
docker exec -it core-novnc echo $DISPLAY
```

### CORE GUI not starting
1. Check if core-daemon is running:
```bash
docker exec -it core-novnc supervisorctl status core-daemon
```

2. Manually start CORE GUI:
```bash
docker exec -it core-novnc /opt/core/venv/bin/core-gui
```

3. Check CORE GUI logs:
```bash
docker exec -it core-novnc cat /root/.coregui/gui.log
```

## Customization

### Change Resolution
Set environment variable when running:
```bash
docker run -e VNC_RESOLUTION=1600x900 ...
```

Or in docker-compose.novnc.yml:
```yaml
environment:
  - VNC_RESOLUTION=1600x900
```

### Auto-start different application
Edit `/root/.vnc/xstartup` in the container or modify `dockerfiles/novnc/xstartup` before building:
```bash
# Instead of core-gui, run something else
/path/to/your/app &
```

### Change Window Manager
Edit Dockerfile to install different window manager:
```dockerfile
# Replace fluxbox with openbox, xfce4, etc.
RUN apt-get install -y openbox
```

Then update xstartup script accordingly.

## Persistence

To persist CORE configurations and saved topologies, mount a volume:

Docker Compose (already configured):
```yaml
volumes:
  - core-data:/root/.coregui
```

Docker run:
```bash
docker run -v core-data:/root/.coregui ...
```

## Performance Tips

1. **Adjust resolution**: Lower resolutions improve performance over slow connections
2. **Compression**: noVNC automatically uses compression
3. **Local network**: Best performance on local network
4. **Network optimization**: If on slow connection, use quality settings in noVNC sidebar

## Security Considerations

1. **Change default password**: Modify VNC password in Dockerfile
2. **Use HTTPS**: Consider reverse proxy (nginx, traefik) with SSL for production
3. **Firewall**: Restrict port 6080 to trusted IPs
4. **SSH tunneling**: Use SSH tunnel for remote access instead of exposing port
5. **VNC password**: The default password is for testing only

## Advanced Usage

### Using CORE API
The gRPC API is exposed on port 50051:
```python
from core.api.grpc import client

# Connect from host or other containers
core_client = client.CoreGrpcClient("localhost:50051")
```

### Running without GUI
To run only the daemon without VNC:
```bash
docker exec -it core-novnc supervisorctl stop vnc novnc
```

### Multiple instances
To run multiple instances, change port mappings:
```bash
docker run -p 6081:6080 -p 5902:5901 ...
```

## Available Services

This container includes comprehensive networking and application services:

### Routing Protocols
- **FRR** - OSPFv2, OSPFv3, BGP, RIP, RIPng, IS-IS
- **Quagga OSPF MDR** - MANET-optimized OSPF routing

### Application Services
- **HTTP** - Apache2 web server
- **FTP** - vsftpd file server
- **SSH** - OpenSSH server
- **DHCP** - Server and client

### Network Analysis
- **Wireshark** - Full GUI network analyzer
- **TShark** - Command-line packet analyzer
- **tcpdump** - Packet capture utility

### Testing Tools
- **iperf/iperf3** - Bandwidth testing
- **nmap** - Network scanner
- **traceroute** - Route tracing
- **netcat** - Network utility

See [SERVICES.md](SERVICES.md) for complete documentation on all available services and how to use them.

## Copy-Paste Support

Full clipboard synchronization between your computer and the noVNC session:

**Copy from your computer to CORE:**
1. Copy text on your computer (Ctrl+C / Cmd+C)
2. In noVNC, click the **sidebar arrow** → **clipboard icon** 📋
3. Paste in the clipboard panel (Ctrl+V / Cmd+V)
4. In CORE, paste with Ctrl+V or Shift+Insert

**Copy from CORE to your computer:**
1. In CORE, copy text (Ctrl+C or select with mouse)
2. Open noVNC clipboard panel (sidebar → clipboard icon)
3. Copy text from the panel to your computer

See [COPY-PASTE.md](COPY-PASTE.md) for detailed instructions and troubleshooting.

## Using Wireshark in CORE

1. Start the CORE noVNC container and access via browser
2. Create your network topology in CORE
3. Start the session
4. Right-click a node → "Shell Window" → "bash"
5. Run: `wireshark &`
6. Select interface to capture (e.g., eth0)
7. Start packet capture

Wireshark runs with full GUI support in the noVNC browser interface.

## Files

- `Dockerfile.novnc`: Main Dockerfile with VNC and noVNC
- `xstartup`: VNC session startup script
- `start-vnc.sh`: VNC server launcher
- `supervisord.conf`: Supervisor configuration for all services
- `docker-compose.novnc.yml`: Docker Compose configuration
- `SERVICES.md`: Complete guide to all available services

## Additional Resources

- [CORE Documentation](https://coreemu.github.io/core/)
- [CORE Services Guide](SERVICES.md)
- [noVNC GitHub](https://github.com/novnc/noVNC)
- [TigerVNC](https://tigervnc.org/)
- [FRR Documentation](https://docs.frrouting.org/)
- [Wireshark User Guide](https://www.wireshark.org/docs/)
