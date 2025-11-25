# Using Docker Nodes and Wireshark in CORE

This guide explains how to use Docker-based nodes in CORE and how to run Wireshark for packet analysis.

## Docker Node Support

CORE can create nodes using Docker containers, allowing you to use custom Docker images with specific software and configurations.

### Prerequisites

✅ **Already configured in this container:**
- Docker CLI installed
- Docker socket mounted (`/var/run/docker.sock`)
- Host PID namespace shared (`--pid=host`) - **Required for Docker nodes**
- Base node image (`core-node:latest`) with all tools

**Why `--pid=host` is required:**
When CORE creates Docker containers, it needs to access their process information via `/proc/<PID>/`. Without host PID namespace sharing, CORE cannot see the Docker container processes and will fail with "No such file or directory" errors.

### Using Docker Nodes in CORE

#### Method 1: Using the Base Node Image (Recommended)

The `core-node:latest` image includes all services and tools:

1. **Open CORE GUI** (http://localhost:6080)
2. **Create a Docker node:**
   - Click on "Docker" node type in the toolbar
   - Place it on the canvas
3. **Configure the node:**
   - Right-click the node → "Configure"
   - Set **Image:** `core-node:latest`
   - Leave other settings as default
4. **Add services** (optional):
   - Right-click → "Services..."
   - Select services like FRRzebra, FRROspfv2, HTTP, etc.
5. **Start the session**

The node will have access to:
- All routing protocols (FRR, Quagga OSPF MDR)
- Web servers (Apache2, vsftpd)
- Network tools (iperf, nmap, traceroute)
- **Wireshark** (GUI and TShark)
- All utilities (vim, nano, htop)

#### Method 2: Using Custom Docker Images

You can use any Docker image:

1. **Pull or build your custom image:**
   ```bash
   # Example: pull Ubuntu
   docker exec core-novnc docker pull ubuntu:latest
   ```

2. **Create Docker node in CORE:**
   - Use Docker node type
   - Configure with your image name (e.g., `ubuntu:latest`)

3. **Requirements for custom images:**
   - Must have `iproute2` and `ethtool` installed
   - Should have networking tools for proper CORE operation

**Example Dockerfile for custom nodes:**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y iproute2 ethtool iputils-ping \
    wireshark tshark iperf3 && \
    rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]
```

## Using Wireshark in CORE Nodes

### Option 1: Wireshark GUI (In-Node Analysis)

**Step-by-step:**

1. **Create your network topology** in CORE
2. **Use Docker nodes** with `core-node:latest` image
3. **Start the session**
4. **Open a terminal on the node:**
   - Right-click the node → "Shell Window" → "bash"
5. **Launch Wireshark:**
   ```bash
   wireshark &
   ```
6. **Select interface** to capture (e.g., `eth0`, `eth1`)
7. **Start packet capture**

**Note:** Wireshark will open in the noVNC browser window.

### Option 2: TShark (Command-Line)

For command-line packet analysis:

```bash
# Capture on eth0
tshark -i eth0

# Capture and save to file
tshark -i eth0 -w /tmp/capture.pcap

# Capture with display filter
tshark -i eth0 -f "tcp port 80"

# Read from file
tshark -r /tmp/capture.pcap
```

### Option 3: tcpdump (Lightweight Capture)

For basic packet capture:

```bash
# Capture on eth0
tcpdump -i eth0

# Save to file
tcpdump -i eth0 -w /tmp/capture.pcap

# Read from file
tcpdump -r /tmp/capture.pcap
```

## Complete Example: Web Server with Packet Analysis

This example creates a client-server topology with packet capture.

### Topology Setup

1. **Create nodes:**
   - Router (Docker, `core-node:latest`)
   - Server (Docker, `core-node:latest`)
   - Client (Docker, `core-node:latest`)

2. **Connect them:**
   - Client ↔ Router
   - Router ↔ Server

3. **Configure services:**
   - **Router:** FRRzebra + FRROspfv2 + IPForward
   - **Server:** HTTP
   - **Client:** (no services needed)

4. **Start the session**

### Testing and Analysis

**On Server node:**
```bash
# Verify Apache is running
pidof apache2

# Check IP address
ip addr show eth0
```

**On Client node:**
```bash
# Start Wireshark for analysis
wireshark &

# In Wireshark: select eth0, start capture

# Generate HTTP traffic (in terminal)
curl http://<server-ip>

# Generate multiple requests
for i in {1..10}; do curl http://<server-ip>; done
```

**In Wireshark:**
- Apply filter: `http`
- You'll see HTTP GET requests and responses
- Right-click packet → "Follow HTTP Stream" to see full conversation

## Troubleshooting

### Docker Nodes Not Starting

**Error:** "No such file or directory" or "cat: /proc/<PID>/environ: No such file or directory"

**Cause:** Container not running with host PID namespace.

**Solution:** Restart container with `--pid=host`:
```bash
docker stop core-novnc && docker rm core-novnc
docker run -d --name core-novnc --privileged --init --pid=host \
  -p 6080:6080 -p 5901:5901 -p 50051:50051 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --cap-add NET_ADMIN --cap-add SYS_ADMIN \
  core-novnc:latest
```

**Or use Docker Compose:** (already configured)
```bash
cd dockerfiles
docker-compose -f docker-compose.novnc.yml up -d
```

**Or use the build script:** (already configured)
```bash
cd dockerfiles/novnc
./build-and-run.sh start
```

### Image Not Found

**Error:** "Unable to find image 'core-node:latest' locally"

**Solution:** Build the image:
```bash
cd /workspaces/core
docker build -f dockerfiles/Dockerfile.core-node -t core-node:latest .
```

**Or use the build script:**
```bash
cd dockerfiles/novnc
./build-and-run.sh build
```

### Wireshark Not Found in Node

**Error:** "wireshark: command not found"

**Solution:** Use the `core-node:latest` image, which includes Wireshark:
1. Right-click node → "Configure"
2. Set Image to `core-node:latest`
3. Restart session

### Wireshark Permission Denied

**Error:** "Couldn't run /usr/bin/dumpcap in child process"

**Solution:** The `core-node` image is pre-configured for this. If using custom image:
```bash
# In your Dockerfile
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | \
    debconf-set-selections && \
    dpkg-reconfigure -f noninteractive wireshark-common
```

### Display Not Set for Wireshark GUI

**Error:** "cannot connect to X server"

**Solution:** The DISPLAY variable is automatically set. If issues occur:
```bash
# Check DISPLAY
echo $DISPLAY

# Should show :1

# If not set:
export DISPLAY=:1
wireshark &
```

## Advanced Usage

### Capture from Multiple Interfaces

```bash
# Start Wireshark
wireshark &

# In Wireshark: Capture → Options
# Select multiple interfaces (eth0, eth1, etc.)
# Start capture
```

### Export Captures

```bash
# Capture to file with tshark
tshark -i eth0 -w /tmp/capture.pcap

# Later, copy file from container
docker cp <container-id>:/tmp/capture.pcap ./
```

### Remote Capture (from one node, analyze on another)

**On capture node:**
```bash
tcpdump -i eth0 -w - | nc <analyzer-ip> 9999
```

**On analyzer node:**
```bash
nc -l 9999 | wireshark -k -i -
```

### Filter Examples

**In Wireshark or TShark:**

```bash
# HTTP only
http

# Specific IP
ip.addr == 10.0.0.1

# TCP port 80
tcp.port == 80

# OSPF packets
ospf

# ICMP (ping)
icmp

# BGP
bgp
```

## Performance Tips

1. **Use TShark for large captures** - Less overhead than GUI
2. **Use capture filters** - Reduce captured data
3. **Limit capture size** - Use `-w` with rotation:
   ```bash
   tcpdump -i eth0 -w capture.pcap -C 10 -W 5
   # Captures 5 files of 10MB each
   ```

## Best Practices

1. **Always use `core-node:latest`** for full tool availability
2. **Start small** - Test with 2-3 nodes before scaling
3. **Use TShark** for automated analysis and scripting
4. **Save captures** for later analysis
5. **Use filters** to focus on relevant traffic

## Available Tools in core-node:latest

### Network Analysis
- Wireshark (GUI)
- TShark (CLI)
- tcpdump

### Routing
- FRR (OSPFv2, OSPFv3, BGP, RIP, RIPng, IS-IS)
- Quagga OSPF MDR

### Application Services
- Apache2 (HTTP)
- vsftpd (FTP)
- OpenSSH
- ISC DHCP

### Testing
- iperf / iperf3
- nmap
- traceroute
- netcat

### Utilities
- vim, nano
- htop
- bind9-utils (dig, nslookup)

## Additional Resources

- [Wireshark User Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
- [TShark Manual](https://www.wireshark.org/docs/man-pages/tshark.html)
- [CORE Documentation](https://coreemu.github.io/core/)
- [Docker Documentation](https://docs.docker.com/)
