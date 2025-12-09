# ICS Cybersecurity Training Platform - Implementation Plan

## Overview

This document outlines the migration of CybatiWorks Blackbox ICS training capabilities to the new Docker/noVNC/Web architecture. The goal is to replicate and enhance the educational platform while leveraging modern containerization and web technologies.

---

## Architecture Comparison

### Legacy CybatiWorks Blackbox
- **Platform**: Native VM with CORE GUI
- **GUI**: Local X11 / Zenity dialogs / pygame
- **Topology**: IMN files (CORE-native format)
- **Deployment**: Shell scripts with GUI wizards
- **Node Types**: CORE network namespaces
- **HMI**: Native GTK/pygame applications

### New Architecture
- **Platform**: Docker containers inside CORE + noVNC
- **GUI**: Browser-based (Flask web UI, Vue.js dashboard)
- **Topology**: Python/XML generated from natural language
- **Deployment**: Web UI + Docker Compose + REST API
- **Node Types**: Docker containers in CORE
- **HMI**: Web applications + noVNC desktop access

---

## Capability Mapping

### ✅ Phase 1: Core Network Infrastructure (READY)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| Multi-zone topology (Industrial/Corporate/Internet) | `blackbox/blackbox_network.imn:1-1939` | `topology_generator.py` with zone annotations | Ready |
| OSPF/BGP Routing | `blackbox/blackbox_network.imn:294-717` (router configs) | FRR container in `appliance_registry.py:248-285` | Ready |
| DHCP Services | `blackbox/blackbox_network.imn:119-231` (DHCP configs) | DHCP service in topology generator | Ready |
| Firewall Policies | `blackbox/Blackbox_Industrial_FW.fwb`, `blackbox/Blackbox_Border_FW.fwb` | VyOS appliance in `appliance_registry.py:209-246` | Ready |
| DNS Services | `blackbox/blackbox_network.imn:1156-1166` (dnsmasq on n17) | Add dnsmasq container | Easy |

**Existing New Architecture Files:**
- `core-mcp-server/core_mcp/topology_generator.py` - Natural language topology generation
- `core-mcp-server/core_mcp/appliance_registry.py` - VyOS, FRR, iptables-firewall defined
- `dockerfiles/Dockerfile.alpine-firewall-core` - Lightweight iptables firewall

---

### ✅ Phase 2: Industrial Protocol Servers (PARTIALLY READY)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| Modbus TCP Server | `blackbox/bottle-filling/world.py:333-351` | OpenPLC container | Ready |
| Modbus TCP Client | `blackbox/datastreams/modbus.sh:1-7` | pymodbus in attack containers | Easy |
| EtherNet/IP Server | `blackbox/server_enip.sh:1-3` | Create enip-server container | Medium |
| EtherNet/IP Client | `blackbox/client_enip.sh:1-6` | Create enip-client container | Medium |
| DNP3 Slave | `blackbox/server_slave_dnp3.sh:1-5` | Create dnp3-server container | Medium |
| DNP3 Master | `blackbox/client_master_dnp3.sh:1-5` | Create dnp3-client container | Medium |

**Blackbox Reference - Modbus Server (world.py:333-351):**
```python
store = ModbusSlaveContext(
    di = ModbusSequentialDataBlock(0, [0]*100),
    co = ModbusSequentialDataBlock(0, [0]*100),
    hr = ModbusSequentialDataBlock(0, [0]*100),
    ir = ModbusSequentialDataBlock(0, [0]*100))
context = ModbusServerContext(slaves=store, single=True)
# Starts on port 502
StartTcpServer(context, identity=identity, address=("172.16.192.2", MODBUS_SERVER_PORT))
```

**Existing New Architecture Files:**
- `dockerfiles/Dockerfile.openplc-core` - OpenPLC with Modbus TCP on port 502
- `core-mcp-server/examples/plc_programs/water_tank_control.st` - Sample PLC program
- `core-mcp-server/core_mqtt_injector.py` - Protocol injection framework (can be extended)

---

### ✅ Phase 3: VirtuaPlant Process Simulation (REQUIRES PORTING)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| Bottle-filling physics | `blackbox/bottle-filling/world.py:46-327` | HTML5 Canvas + matter.js | Port Required |
| HMI GTK Interface | `blackbox/bottle-filling/hmi.py:1-181` | Vue.js web HMI | Port Required |
| Process Control Logic | `blackbox/bottle-filling/world.py:260-284` | OpenPLC + Web HMI | Port Required |
| Attack Scripts | `blackbox/bottle-filling/attacks/*.py` | Web attack console | Port Required |

**Blackbox Reference - Process Tags (world.py:54-58):**
```python
PLC_TAG_LEVEL_SENSOR = 0x1
PLC_TAG_LIMIT_SWITCH = 0x2
PLC_TAG_MOTOR = 0x3
PLC_TAG_NOZZLE = 0x4
PLC_TAG_RUN = 0x10
```

**Blackbox Reference - Motor Control Logic (world.py:260-284):**
```python
if PLCGetTag(PLC_TAG_RUN):
    # Motor Logic
    if (PLCGetTag(PLC_TAG_LIMIT_SWITCH) == 1):
        PLCSetTag(PLC_TAG_MOTOR, 0)
    if (PLCGetTag(PLC_TAG_LEVEL_SENSOR) == 1):
        PLCSetTag(PLC_TAG_MOTOR, 1)
    # ... nozzle control, etc.
```

**Blackbox Reference - Attack Examples:**

1. **Move and Fill Attack** (`attacks/attack_move_and_fill.py:17-24`):
```python
# Forces motor ON + nozzle OPEN simultaneously = overflow
rq = client.write_register(0x3, 1)  # Motor ON
rq = client.write_register(0x4, 1)  # Nozzle OPEN
```

2. **Stop All Attack** (`attacks/attack_stop_all.py:20-24`):
```python
# Stops all operations
rq = client.write_register(0x3, 0)  # Motor OFF
rq = client.write_register(0x4, 0)  # Nozzle CLOSED
```

3. **Stop and Fill Attack** (`attacks/attack_stop_and_fill.py:22-24`):
```python
# Stops conveyor while filling = overflow
rq = client.write_register(0x3, 0)  # Motor OFF
rq = client.write_register(0x4, 1)  # Nozzle OPEN
```

**New Architecture Approach:**
- Port pygame physics to HTML5 Canvas with matter.js or p2.js
- Create Vue.js HMI component in dashboard
- Use existing MQTT injection for sensor simulation
- Create web-based attack console

---

### ✅ Phase 4: Traffic Generation & Network Services (EASY TO PORT)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| HTTP Traffic | `blackbox/datastreams/http.sh:1-11` | curl/wget in traffic container | Easy |
| FTP Traffic | `blackbox/datastreams/ftp.sh:1-11`, `ftp_script.sh:1-7` | ftp client in container | Easy |
| SMB Traffic | `blackbox/datastreams/smbclient.sh:1-12` | smbclient in container | Easy |
| VoIP Traffic | `blackbox/datastreams/voip.sh:1-11` (ITGSend/Recv) | iperf3 or D-ITG container | Medium |
| Modbus Polling | `blackbox/datastreams/modbus.sh:1-7` | pymodbus client container | Easy |

**Blackbox Reference - Traffic Generator Patterns:**

```bash
# HTTP Traffic (http.sh)
wget http://73.9.7.10/
wget http://73.9.5.10/
wget http://73.9.14.10/engineering_invoice.docx

# SMB Traffic (smbclient.sh)
smbget -w CYBATIWORKS -a smb://10.0.11.10/ftpshare/engineering_invoice.docx

# FTP Traffic (ftp_script.sh)
ftp -in 10.0.11.10 << SCRIPTEND
user anonymous engineering@cybatiworks.local
mget PASSWORD.RSS
SCRIPTEND

# Modbus Polling (modbus.sh)
modbus read --modicon 10.0.0.30 400001 4
```

---

### ✅ Phase 5: Security Analysis Tools (READY)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| Wireshark Analysis | `blackbox/mirror.sh:60-78` | hmi-workstation container | Ready |
| Port Mirroring | `blackbox/mirror.sh:70-77` (brctl setageing 0) | CORE bridge config | Ready |
| Active Scanning | `blackbox/active_scan.sh:1-4` (zenmap) | nmap in kali container | Ready |
| ARP Spoofing | `blackbox/datastreams/data.sh:1-3` (ettercap) | ettercap in kali container | Ready |

**Blackbox Reference - Port Mirroring (mirror.sh:70-77):**
```bash
MIRRORING_SWITCH=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $bridge)
brctl setageing $MIRRORING_SWITCH 0  # Makes switch act like hub
wireshark -i $CYBATIWORKS_INTERFACE -k &
```

**Existing New Architecture Files:**
- `dockerfiles/Dockerfile.hmi-workstation` - Firefox + Wireshark + noVNC
- `dockerfiles/Dockerfile.kali-novnc-core` - Full Kali with attack tools
- `core-mcp-server/core_mcp/appliance_registry.py:325-363` - Suricata IDS defined

---

### ✅ Phase 6: HMI & Engineering Workstations (READY)

| Blackbox Capability | Reference File | New Implementation | Status |
|---------------------|----------------|-------------------|--------|
| Engineering Desktop | `blackbox/quick_PI_start.sh:46-85` (RexDraw via Wine) | hmi-workstation container | Ready |
| HMI Browser Access | N/A (used GTK) | Firefox in hmi-workstation | Ready |
| VNC Remote Desktop | N/A | noVNC on port 6080 | Ready |

**Existing New Architecture Files:**
- `dockerfiles/Dockerfile.hmi-workstation:1-145` - Full desktop with browsers
- `dockerfiles/Dockerfile.engineering-workstation` - Engineering tools
- `core-mcp-server/templates/vnc_desktop.html` - VNC viewer template
- `core-mcp-server/templates/dashboard.html` - Unified dashboard with VNC tabs

---

### ⚠️ Phase 7: Physical Hardware Integration (FUTURE)

| Blackbox Capability | Reference File | Challenge | Approach |
|---------------------|----------------|-----------|----------|
| Raspberry Pi PLC | `blackbox/quick_PI_start.sh:29-37` | Physical hardware | USB/Serial passthrough or TCP bridge |
| GPIO Traffic Light | `blackbox/American_Traffic_light_GPIO_Modbus_rev2/` | Physical I/O | Create Pi simulator container |
| Mini Kit Integration | `blackbox/blackbox_runtime.sh:13-14` | VLAN bridging | Docker network bridging to physical |

**Blackbox Reference - Pi Integration (quick_PI_start.sh:35-37):**
```bash
plink -ssh -pw cybati pi@10.0.0.30 sudo service rexcore stop
plink -ssh -pw cybati pi@10.0.0.30 sudo service rexcore start
```

---

## Implementation Details

### 1. Create VirtuaPlant Web Application

**New File: `core-mcp-server/templates/virtuaplant.html`**

Port the pygame bottle-filling simulation to HTML5 Canvas:

```javascript
// Reference: blackbox/bottle-filling/world.py

// Process constants (from world.py:54-58)
const PLC_TAGS = {
    LEVEL_SENSOR: 0x1,
    LIMIT_SWITCH: 0x2,
    MOTOR: 0x3,
    NOZZLE: 0x4,
    RUN: 0x10
};

// Physics simulation using matter.js
// - Bottles on conveyor
// - Water droplets from nozzle
// - Level sensor collision detection
// - Limit switch at fill position

// Modbus communication via REST API -> OpenPLC
async function readTag(addr) {
    const resp = await fetch(`/api/modbus/read/${addr}`);
    return (await resp.json()).value;
}

async function writeTag(addr, value) {
    await fetch(`/api/modbus/write/${addr}`, {
        method: 'POST',
        body: JSON.stringify({value})
    });
}
```

### 2. Create Attack Console Web Application

**New File: `core-mcp-server/templates/attack_console.html`**

Reference the attack patterns from `blackbox/bottle-filling/attacks/`:

```javascript
// Attack definitions from blackbox analysis
const ATTACKS = {
    'move_and_fill': {
        name: 'Move and Fill',
        description: 'Forces motor ON + nozzle OPEN = overflow',
        registers: [
            {addr: 0x10, value: 1, desc: 'RUN Plant'},
            {addr: 0x3, value: 1, desc: 'Motor ON'},
            {addr: 0x4, value: 1, desc: 'Nozzle OPEN'}
        ]
    },
    'stop_all': {
        name: 'Stop All',
        description: 'Halts all operations',
        registers: [
            {addr: 0x3, value: 0, desc: 'Motor OFF'},
            {addr: 0x4, value: 0, desc: 'Nozzle CLOSED'}
        ]
    },
    // ... other attacks from attacks/*.py
};

async function executeAttack(attackId) {
    const attack = ATTACKS[attackId];
    for (const reg of attack.registers) {
        await writeModbusRegister(reg.addr, reg.value);
        await sleep(500);
    }
}
```

### 3. Create Protocol Server Containers

**New File: `dockerfiles/Dockerfile.modbus-server`**

```dockerfile
FROM python:3.11-slim

RUN pip install pymodbus

# Reference: blackbox/datastreams/tcp_sync_server.py
COPY modbus_server.py /app/

EXPOSE 502
CMD ["python", "/app/modbus_server.py"]
```

**New File: `dockerfiles/Dockerfile.enip-server`**

```dockerfile
FROM python:3.11-slim

RUN pip install cpppo pycomm3

# Reference: blackbox/server_enip.sh
# enip_server SCADA=INT[1000]

EXPOSE 44818
CMD ["python", "-m", "cpppo.server.enip", "--address", "0.0.0.0:44818"]
```

**New File: `dockerfiles/Dockerfile.dnp3-server`**

```dockerfile
FROM python:3.11-slim

RUN pip install pydnp3

# Reference: blackbox/server_slave_dnp3.sh
# /opt/CybatiWorks/Labs/opendnp3/demo-slave-cpp 100 1 172.16.192.13 20000

EXPOSE 20000
CMD ["python", "/app/dnp3_outstation.py"]
```

### 4. Create Traffic Generator Container

**New File: `dockerfiles/Dockerfile.traffic-generator`**

```dockerfile
FROM alpine:latest

RUN apk add --no-cache \
    curl wget \
    lftp \
    samba-client \
    python3 py3-pip

RUN pip3 install pymodbus requests

# Reference scripts from blackbox/datastreams/
COPY traffic_scripts/ /app/

CMD ["/app/run_traffic.sh"]
```

### 5. ICS Training Topology Template

**New File: `core-mcp-server/templates/topologies/ics_training.yaml`**

```yaml
# Reference: blackbox/blackbox_network.imn zones and subnets

name: "ICS Cybersecurity Training Network"
description: "Multi-zone IT/OT network for security training"

zones:
  industrial:
    subnet: "172.16.192.0/24"
    gateway: "172.16.192.1"
    nodes:
      - name: plc-server
        type: openplc
        ip: "172.16.192.2"
        services: [modbus-tcp]
      - name: hmi-workstation
        type: hmi-workstation
        ip: "172.16.192.10"
      - name: enip-server
        type: enip-server
        ip: "172.16.192.12"
      - name: dnp3-slave
        type: dnp3-server
        ip: "172.16.192.13"

  corporate:
    subnet: "10.0.11.0/24"
    gateway: "10.0.11.1"
    nodes:
      - name: file-server
        type: samba-ftp
        ip: "10.0.11.10"
      - name: dns-server
        type: dnsmasq
        ip: "10.0.11.11"
      - name: web-server
        type: nginx
        ip: "10.0.11.20"

  internet:
    subnet: "73.9.0.0/16"
    nodes:
      - name: attacker
        type: kali-novnc
        ip: "73.9.5.10"
      - name: external-web
        type: nginx
        ip: "73.9.7.10"

firewalls:
  - name: industrial-fw
    type: vyos
    position: industrial-corporate-boundary
    interfaces:
      - zone: industrial
        ip: "172.16.192.1"
      - zone: corporate
        ip: "10.0.10.3"
    rules:
      - allow modbus from corporate to industrial
      - deny all from internet to industrial

  - name: border-fw
    type: vyos
    position: corporate-internet-boundary
    interfaces:
      - zone: corporate
        ip: "10.0.10.1"
      - zone: internet
        ip: "73.9.9.2"
    rules:
      - allow http/https outbound
      - deny inbound except established
```

---

## File Reference Index

### Blackbox Source Files

| Category | File | Lines | Description |
|----------|------|-------|-------------|
| **Topology** | `blackbox/blackbox_network.imn` | 1-1939 | Complete CORE topology |
| **Launcher** | `blackbox/blackbox.sh` | 1-42 | Main startup wizard |
| **Runtime** | `blackbox/blackbox_runtime.sh` | 1-61 | Post-startup configuration |
| **Shutdown** | `blackbox/blackbox_stop.sh` | 1-34 | Cleanup script |
| **Firewall** | `blackbox/firewall.sh` | 1-15 | Firewall viewer |
| **Scanning** | `blackbox/active_scan.sh` | 1-4 | Zenmap launcher |
| **Mirroring** | `blackbox/mirror.sh` | 1-81 | Port mirroring + Wireshark |
| **VirtuaPlant** | `blackbox/virtuaplant.sh` | 1-28 | Simulation launcher |
| **World Sim** | `blackbox/bottle-filling/world.py` | 1-359 | Physics + Modbus server |
| **HMI** | `blackbox/bottle-filling/hmi.py` | 1-181 | GTK HMI interface |
| **Attacks** | `blackbox/bottle-filling/attacks/*.py` | ~30 each | Modbus attack scripts |
| **EtherNet/IP** | `blackbox/server_enip.sh` | 1-3 | ENIP server |
| **DNP3** | `blackbox/server_slave_dnp3.sh` | 1-5 | DNP3 slave |
| **Traffic** | `blackbox/datastreams/*.sh` | Various | Traffic generators |
| **Timer** | `blackbox/timer.py` | 1-30 | Exercise countdown |

### New Architecture Files

| Category | File | Description |
|----------|------|-------------|
| **Topology** | `core-mcp-server/core_mcp/topology_generator.py` | NL topology generation |
| **Appliances** | `core-mcp-server/core_mcp/appliance_registry.py` | Container registry |
| **Web UI** | `core-mcp-server/web_ui.py` | Flask application |
| **Dashboard** | `core-mcp-server/templates/dashboard.html` | Vue.js dashboard |
| **MQTT Inject** | `core-mcp-server/core_mqtt_injector.py` | Protocol injection |
| **OpenPLC** | `dockerfiles/Dockerfile.openplc-core` | PLC container |
| **HMI** | `dockerfiles/Dockerfile.hmi-workstation` | Desktop container |
| **Kali** | `dockerfiles/Dockerfile.kali-novnc-core` | Attack container |
| **PLC Program** | `core-mcp-server/examples/plc_programs/water_tank_control.st` | Sample ST program |

---

## Migration Checklist

### Immediate (Use Existing)
- [x] Network topology generation
- [x] Firewall appliances (VyOS, iptables)
- [x] Router appliances (FRR)
- [x] HMI workstation with Wireshark
- [x] Kali attack platform
- [x] OpenPLC with Modbus TCP
- [x] MQTT broker and injection
- [x] noVNC remote desktop access

### Short Term (Easy Ports)
- [ ] DNS server container (dnsmasq)
- [ ] File server container (Samba/FTP)
- [ ] HTTP/FTP traffic generator
- [ ] Modbus polling client
- [ ] Web-based attack console

### Medium Term (New Development)
- [ ] VirtuaPlant web simulation
- [ ] EtherNet/IP server container
- [ ] DNP3 server container
- [ ] VoIP traffic generator
- [ ] ICS training topology template

### Long Term (Research Required)
- [ ] Physical Pi integration
- [ ] GPIO simulation
- [ ] REX Controls alternative
- [ ] 3D/AR process visualization

---

## Conclusion

The new Docker/noVNC/Web architecture can replicate **~90% of CybatiWorks functionality** with significant advantages:

1. **Browser-based access** - No local software installation
2. **Natural language topology** - Faster scenario creation
3. **Container isolation** - Better security and reproducibility
4. **Modern UI** - Vue.js dashboard vs. Zenity dialogs
5. **API-first** - Automation and CI/CD ready

The main porting effort is the VirtuaPlant pygame simulation, which should be converted to HTML5 Canvas for full browser compatibility.
