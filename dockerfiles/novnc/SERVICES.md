# CORE Services and Applications Guide

This guide describes all available services and applications in the CORE noVNC Docker container.

## Available Services

The container includes all CORE service dependencies, allowing you to configure nodes with various network services and applications.

### Routing Services

#### FRR (Free Range Routing)
FRR provides modern routing protocol implementations:

- **FRRzebra** - Base routing manager (required for other FRR services)
- **FRROspfv2** - OSPF version 2 for IPv4
- **FRROspfv3** - OSPF version 3 for IPv6
- **FRRBgp** - Border Gateway Protocol
- **FRRRip** - Routing Information Protocol (IPv4)
- **FRRRipng** - RIP next generation (IPv6)
- **FRRISIS** - IS-IS routing protocol

**Executables installed:**
- `/usr/lib/frr/zebra`
- `/usr/lib/frr/ospfd`
- `/usr/lib/frr/ospf6d`
- `/usr/lib/frr/bgpd`
- `/usr/lib/frr/ripd`
- `/usr/lib/frr/ripngd`
- `/usr/lib/frr/isisd`

**Configuration:** All FRR daemons are pre-configured and enabled in `/etc/frr/daemons`

#### Quagga OSPF MDR (Mobile Ad-hoc Network Routing)
Quagga with MANET extensions for mobile networks:

- **Ospfv2** - OSPF version 2 with MANET extensions
- **Ospfv3** - OSPF version 3 with MANET extensions
- **Zebra** - Quagga routing manager
- **Bgp** - BGP routing
- **Rip** - RIP routing
- **Ripng** - RIPng routing

**Executables installed:**
- `/usr/local/sbin/zebra`
- `/usr/local/sbin/ospfd`
- `/usr/local/sbin/ospf6d`
- `/usr/local/sbin/bgpd`
- `/usr/local/sbin/ripd`
- `/usr/local/sbin/ripngd`

### Application Services

#### HTTP Server (Apache2)
Full-featured HTTP server for hosting web applications.

- **Service name:** HTTP
- **Executable:** `/usr/sbin/apache2`
- **Default port:** 80
- **Document root:** `/var/www/html`

**Usage in CORE:**
1. Add "HTTP" service to a node
2. The service will create a default index.html
3. Access via node's IP address on port 80

#### FTP Server (vsftpd)
FTP server for file transfers.

- **Service name:** FTP
- **Executable:** `/usr/sbin/vsftpd`
- **Default port:** 21

#### SSH Server (OpenSSH)
Secure shell server for remote access.

- **Service name:** SSH
- **Executable:** `/usr/sbin/sshd`
- **Default port:** 22

**Usage:**
- Access nodes via SSH from other nodes or the host
- SSH keys are automatically generated

### Network Services

#### DHCP Server
ISC DHCP server for dynamic IP address assignment.

- **Service name:** DHCP
- **Executable:** `/usr/sbin/dhcpd`
- **Lease file:** `/var/lib/dhcp/dhcpd.leases`

#### DHCP Client
DHCP client for obtaining IP addresses automatically.

- **Service name:** DHCPClient
- **Executable:** `/usr/sbin/dhclient`

#### IPv6 Router Advertisement (radvd)
Router advertisement daemon for IPv6 autoconfiguration.

- **Service name:** radvd
- **Executable:** `/usr/sbin/radvd`
- **Config:** `/etc/radvd/radvd.conf`

### Utility Services

#### IP Forwarding
Enables IP packet forwarding on routers.

- **Service name:** IPForward
- Uses `sysctl` to enable forwarding

#### Default Route
Automatically configures default routes.

- **Service name:** DefaultRoute

#### Static Route
Configures static routing entries.

- **Service name:** StaticRoute

#### Packet Capture (pcap)
Captures network traffic using tcpdump.

- **Service name:** pcap
- **Executable:** `/usr/bin/tcpdump`

#### At Daemon
Schedule commands to run at specific times.

- **Service name:** atd
- **Executable:** `/usr/bin/atd`

## Network Analysis Tools

### Wireshark
Full-featured network protocol analyzer with GUI.

**Launch Wireshark:**
1. Right-click on a node in CORE GUI
2. Select "Shell Window" → "bash"
3. In the terminal, run: `wireshark &`
4. Wireshark GUI will open in the VNC session

**Executable:** `/usr/bin/wireshark`

**Features:**
- Deep packet inspection
- Protocol analysis
- Live capture and offline analysis
- Export capabilities

### TShark
Command-line network protocol analyzer (Wireshark CLI).

**Usage:**
```bash
# Capture on interface eth0
tshark -i eth0

# Capture and save to file
tshark -i eth0 -w capture.pcap

# Read from file
tshark -r capture.pcap
```

**Executable:** `/usr/bin/tshark`

## Additional Network Utilities

### Performance Testing

#### iperf / iperf3
Network bandwidth measurement tool.

```bash
# Server mode
iperf3 -s

# Client mode
iperf3 -c <server-ip>
```

**Executables:**
- `/usr/bin/iperf`
- `/usr/bin/iperf3`

### Network Diagnostics

#### Traceroute
Trace packet route to destination.

```bash
traceroute <destination>
```

#### Nmap
Network scanner and security auditing tool.

```bash
# Scan a host
nmap <target-ip>

# Port scan
nmap -p 1-1000 <target-ip>
```

#### Netcat
Networking utility for TCP/UDP connections.

```bash
# Listen on port
nc -l 1234

# Connect to port
nc <host> 1234
```

#### DNS Utilities
- `dig` - DNS lookup utility
- `nslookup` - Query DNS servers
- `host` - DNS lookup

**Package:** bind9-utils, dnsutils

### Text Editors

- **vim** - Advanced text editor
- **nano** - Simple text editor

### System Monitoring

- **htop** - Interactive process viewer
- **net-tools** - Network utilities (ifconfig, netstat, route)

## Using Services in CORE

### Adding Services to Nodes

1. **Create a node** in the CORE GUI (router, host, etc.)
2. **Right-click the node** → "Services..."
3. **Select services** from the available list:
   - Routing services (FRR, Quagga)
   - Application services (HTTP, FTP, SSH)
   - Network services (DHCP, radvd)
   - Utility services (IPForward, DefaultRoute)
4. **Configure service** if needed (optional)
5. **Start the session** - services will start automatically

### Example: Web Server with OSPF Routing

1. Create a router node
2. Add services:
   - FRRzebra (required)
   - FRROspfv2 (for routing)
   - HTTP (for web server)
3. Start the session
4. Access the web server from other nodes

### Example: Network Capture with Wireshark

1. Create your network topology
2. Start the session
3. Right-click on a node → "Shell Window" → "bash"
4. Run `wireshark &` in the terminal
5. Select interface to capture (e.g., eth0)
6. Start capturing packets

### Example: Performance Testing

1. Create two nodes
2. On server node: `iperf3 -s`
3. On client node: `iperf3 -c <server-ip>`
4. View bandwidth results

## Service Configuration Files

Service configuration files are automatically generated by CORE when you start a session. You can customize them in the GUI:

1. Right-click node → "Services..."
2. Select service → Click "Files" button
3. Edit configuration files
4. Apply changes

## Verifying Services

### Check if a service is running:
```bash
# Inside a node terminal
pidof <service-name>

# Examples:
pidof ospfd
pidof apache2
pidof zebra
```

### View service logs:
```bash
# FRR logs
cat /var/log/frr/*.log

# Apache logs
cat /var/log/apache2/error.log
```

### Test connectivity:
```bash
# Ping another node
ping <ip-address>

# Test HTTP server
curl http://<node-ip>

# Test SSH
ssh <node-ip>
```

## Troubleshooting

### Service not starting
1. Check service configuration in CORE GUI
2. View service startup commands
3. Check system logs in `/var/log/`

### Routing not working
1. Verify routing service is enabled (FRRzebra or Zebra)
2. Check routing tables: `ip route show`
3. Verify IP forwarding: `sysctl net.ipv4.ip_forward`

### Wireshark permission issues
Wireshark is configured to allow non-root capture. If issues occur:
```bash
# Run with sudo
sudo wireshark
```

## Package Versions

- **FRR:** 8.1
- **Wireshark:** 3.6.2
- **Apache2:** 2.4.52
- **OpenSSH:** 8.9p1
- **ISC DHCP:** 4.4.1
- **iperf3:** 3.9

## Additional Resources

- [CORE Documentation](https://coreemu.github.io/core/)
- [FRR Documentation](https://docs.frrouting.org/)
- [Wireshark User Guide](https://www.wireshark.org/docs/wsug_html_chunked/)
- [Apache2 Documentation](https://httpd.apache.org/docs/2.4/)
