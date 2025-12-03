# IoT Sensor System - Quick Start Guide

## Overview

This system bridges physical sensor data (from micro:bit via WebSerial) into the NRL CORE network emulator, making the traffic **visible in Wireshark** as real MQTT packets.

## Architecture

```
Physical micro:bit (USB)
       │
       ▼
Browser WebSerial (microbit.html on port 8080)
       │
       ▼
REST API + Injector (port 8089)
       │ docker exec core-novnc docker exec mqtt-broker mosquitto_pub
       ▼
MQTT Broker (10.0.1.10:1883) ◄── ACTUAL TCP PACKETS ON CORE NETWORK
       │ MQTT Subscribe
       ▼
Sensor Server (10.0.1.20:80)
       │ HTTP
       ▼
HMI Workstation Browser (10.0.1.50)
```

## Active Services

| Port | Service | Description |
|------|---------|-------------|
| 8080 | Web UI | Micro:bit page, topology generator |
| 8089 | MQTT Injector | Injects sensor data into CORE network |
| 6080 | noVNC | Desktop access to CORE GUI |
| 6081-6083 | HMI VNC Proxy | noVNC access to HMI workstations |
| 5901 | VNC Direct | Raw VNC access |

## Access URLs (GitHub Codespace)

| Service | URL |
|---------|-----|
| **Micro:bit Page** | https://musical-robot-97wwqxg47x7wh97q5-8080.app.github.dev/microbit |
| **Sensor Display** | https://musical-robot-97wwqxg47x7wh97q5-8080.app.github.dev/sensor-display |
| **noVNC Desktop** | https://musical-robot-97wwqxg47x7wh97q5-6080.app.github.dev |
| **Injector Status** | https://musical-robot-97wwqxg47x7wh97q5-8089.app.github.dev/status |

> **Note:** Replace `musical-robot-97wwqxg47x7wh97q5` with your Codespace name if different.

## CORE Network Topology (Inside noVNC)

| Node | IP Address | Ports | Purpose |
|------|------------|-------|---------|
| mqtt-broker | 10.0.1.10 | 1883 (MQTT), 9001 (WebSocket) | MQTT message broker |
| sensor-server | 10.0.1.20 | 80 (HTTP) | Web dashboard for sensor data |
| hmi1 | 10.0.1.50 | 5900 (VNC), 6080 (websockify) | HMI workstation with Firefox |

### Accessing HMI Workstation Desktop

The HMI workstation (hmi1) has a full graphical desktop accessible via noVNC. To connect:

1. In the Web UI, expand the **VNC Desktop Access** panel on the right
2. Click **Scan for VNC Hosts** to detect running HMI nodes
3. Select `hmi1` and click **Start VNC**
4. Click **Launch Desktop** to open the VNC viewer

The VNC URL format is:
```
https://<codespace>-6081.app.github.dev/vnc_lite.html?scale=true&path=
```

> **Note:** The `&path=` parameter is required - without it the WebSocket connection will fail.

## Quick Start

### Option A: One-Command Startup (Recommended)

```bash
cd /workspaces/core/core-mcp-server
./start_iot_system.sh
```

This script automatically:
1. Verifies core-novnc container is running
2. Loads the IoT topology into CORE
3. Starts the Web UI on port 8080
4. Starts the MQTT Injector on port 8089
5. Shows you the correct URLs for your environment

### Option B: Manual Startup

```bash
cd /workspaces/core/core-mcp-server

# Start Web UI
python3 web_ui.py --host 0.0.0.0 --port 8080 &

# Start MQTT Injector
python3 core_mqtt_injector.py \
    --session 1 \
    --broker-node mqtt-broker \
    --broker-ip 10.0.1.10 \
    --docker-host core-novnc \
    --port 8089 &
```

### 2. Connect Micro:bit

1. Open the **Micro:bit Page** URL in your browser
2. Click "Connect Micro:bit"
3. Select your micro:bit from the WebSerial dialog
4. Sensor data will start streaming

### 3. View Data in HMI

1. Open **noVNC Desktop** (password: `core123`)
2. Right-click → Browsers → Firefox
3. Navigate to `http://10.0.1.20/`
4. Watch live sensor data

### 4. Capture Traffic in Wireshark

1. In noVNC desktop, open Wireshark
2. Select interface `b.1.1` (the CORE switch)
3. Apply filter: `port 1883`
4. See real MQTT packets flowing!

## Manual Testing

### Inject Test Data

```bash
curl -X POST http://localhost:8089/inject/test-sensor \
    -H "Content-Type: application/json" \
    -d '{"x":100,"y":200,"z":300}'
```

### Check Injector Status

```bash
curl http://localhost:8089/status
```

### Check Sensor Server Data

```bash
docker exec core-novnc docker exec sensor-server curl -s http://localhost/api/sensors
```

## Troubleshooting

### Web UI not responding

```bash
# Check if running
pgrep -af "web_ui.py"

# Restart
pkill -f "web_ui.py"
python3 web_ui.py --host 0.0.0.0 --port 8080 &
```

### Injector not working

```bash
# Check status
curl http://localhost:8089/status

# Restart
pkill -f "mqtt_injector"
python3 core_mqtt_injector.py --session 1 --broker-node mqtt-broker --broker-ip 10.0.1.10 --docker-host core-novnc --port 8089 &
```

### CORE session not running

```bash
# Check containers
docker exec core-novnc docker ps

# Reload topology
docker exec core-novnc /opt/core/venv/bin/python3 /tmp/load_topology.py /tmp/iot_topology.xml
```

## Files

| File | Purpose |
|------|---------|
| `start_iot_system.sh` | **One-command startup script** |
| `web_ui.py` | Flask web server with micro:bit page |
| `core_mqtt_injector.py` | Injects MQTT into CORE network |
| `templates/microbit.html` | WebSerial interface for micro:bit |
| `templates/sensor_display.html` | Sensor data dashboard |
| `dockerfiles/Dockerfile.mqtt-broker-core` | MQTT broker image |
| `dockerfiles/Dockerfile.iot-sensor-server` | Sensor server image |
| `dockerfiles/Dockerfile.hmi-workstation` | HMI desktop image |

## GitHub Codespace Port Configuration

For the system to work in GitHub Codespaces, you need to set the following ports to **Public** visibility:

1. Click on the **PORTS** tab in VS Code
2. Right-click each port and select "Port Visibility" → "Public"

| Port | Service | Must be Public? |
|------|---------|-----------------|
| 6080 | noVNC Desktop | Yes |
| 6081-6083 | HMI VNC Proxy | Yes (for HMI access) |
| 8080 | Web UI | Yes |
| 8089 | MQTT Injector | Yes |

## Stop All Services

```bash
pkill -f "web_ui.py"
pkill -f "core_mqtt_injector.py"
```
