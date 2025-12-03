# CORE MCP Server - Project Context

## What This Project Is

This is an **IoT/ICS Digital Twin Platform** built on top of NRL CORE (Common Open Research Emulator). It allows you to:

1. **Create virtual network topologies** with Docker-based nodes (routers, PLCs, HMIs, sensors)
2. **Connect physical micro:bit devices** to the virtual network via WebSerial
3. **Simulate industrial control systems** (SCADA, water plants, power grids)
4. **Run security exercises** (red team/blue team, penetration testing)

## Key Components

### Web Dashboard (`localhost:8080`)
- **VNC Hosts**: Embedded noVNC viewers for CORE desktop and HMI workstations
- **Templates**: Pre-built topologies (IoT Quick Deploy, Enterprise, ICS/SCADA)
- **Micro:bit Integration**: WebSerial connection, sensor display, LED/speaker control
- **Topology Builder**: Visual drag-and-drop network designer

### CORE Network Emulator (`core-novnc` container)
- Runs inside Docker with nested Docker support
- Provides GUI via noVNC on port 6080
- Hosts virtual network nodes (mqtt-broker, sensor-server, HMIs, etc.)

### Micro:bit Data Flow
```
Physical micro:bit → USB Serial → Browser WebSerial → Dashboard
    → POST /api/inject/{sensor_id}
    → MQTT Injector (docker exec mosquitto_pub)
    → mqtt-broker (10.0.1.10) in CORE
    → sensor-server (10.0.1.20) subscribes and displays
```

## Important Files

| File | Purpose |
|------|---------|
| `web_ui.py` | Main Flask server (dashboard, APIs, MQTT injector) |
| `templates/dashboard.html` | Vue.js dashboard with micro:bit controls |
| `load_topology.py` | Loads XML topologies into CORE, auto-configures injector |
| `core_mcp/topology_generator.py` | Generates CORE XML from templates |
| `docs/MICROBIT_IOT_ARCHITECTURE.md` | Detailed data flow documentation |

## Common Tasks

### Start the system
```bash
cd /workspaces/core/core-mcp-server
python3 web_ui.py
# Dashboard at http://localhost:8080
# noVNC at http://localhost:6080
```

### Load IoT topology
```bash
python3 load_topology.py /path/to/topology.xml
```

### Configure MQTT injector (if not auto-configured)
```bash
curl -X POST http://localhost:8080/api/inject/configure \
  -H "Content-Type: application/json" \
  -d '{"broker_ip": "10.0.1.10", "broker_node": "mqtt-broker"}'
```

### Check data flow
```bash
# Injector status
curl http://localhost:8080/api/inject/status

# MQTT messages in CORE
docker exec core-novnc docker exec mqtt-broker mosquitto_sub -t "core/sensors/#" -v

# Sensor server data
docker exec core-novnc docker exec mqtt-broker wget -q -O - http://10.0.1.20/api/sensors
```

## Network Layout (IoT Quick Deploy)

| Node | IP | Purpose |
|------|-----|---------|
| mqtt-broker | 10.0.1.10 | Mosquitto MQTT broker |
| sensor-server | 10.0.1.20 | Flask app displaying sensor data |
| hmi1 | 10.0.1.30 | HMI workstation with Firefox |
| iot-switch | - | Layer 2 switch connecting nodes |

## Micro:bit Firmware

**Basic** (accelerometer only):
```javascript
basic.forever(function () {
    let x = input.acceleration(Dimension.X)
    let y = input.acceleration(Dimension.Y)
    let z = input.acceleration(Dimension.Z)
    serial.writeLine('{"ax":' + x + ',"ay":' + y + ',"az":' + z + '}')
    basic.pause(100)
})
```

**Full**: All sensors + bidirectional control (see dashboard "Full" tab)

## Recent Work (Dec 2025)

- Fixed MQTT injector 503 errors (needed `/api/inject/configure` call)
- Added tabbed firmware section (Basic/Full) in micro:bit settings
- Created detailed architecture documentation
- Confirmed end-to-end data flow: micro:bit → dashboard → CORE → sensor-server
