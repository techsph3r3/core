# ICS Digital Twin Data Flow Documentation

This document describes the complete data flow between the 3D Digital Twin, PLC I/O Bridge, and OpenPLC for the ICS Sorting Facility.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Web Browser                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  /digital-twin route (digital_twin.html)                            │   │
│  │  ┌─────────────────────┐    ┌─────────────────────────────────────┐ │   │
│  │  │   Parent Window     │    │  iframe (index.html - 3D Twin)      │ │   │
│  │  │                     │    │                                     │ │   │
│  │  │  plcState object    │<───│  window.sortingControl API          │ │   │
│  │  │  - outputs          │    │  - isConveyorRunning()              │ │   │
│  │  │  - registers        │    │  - getConveyorSpeed()               │ │   │
│  │  │                     │    │  - isDiverterActive(color)          │ │   │
│  │  │  WebSocket to       │───>│  - reportSensor(name, value)        │ │   │
│  │  │  /ws/plc-io         │    │  - getCounters()                    │ │   │
│  │  └─────────────────────┘    └─────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ WebSocket (ws://host:8080/ws/plc-io)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Web Dashboard (web_ui.py)                            │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  VNCWebSocketMiddleware                                              │   │
│  │  - Intercepts WebSocket requests to /ws/plc-io                      │   │
│  │  - Routes to plc_io_bridge.handle_websocket()                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  PLC I/O Bridge (plc_io_bridge.py)                                   │   │
│  │                                                                       │   │
│  │  IO_MAP:                                                             │   │
│  │    inputs:                        outputs:                           │   │
│  │      sensor_red: MW100 (1124)       conveyor_run: QX0.0 (coil 0)    │   │
│  │      sensor_white: MW101 (1125)     diverter_red: QX0.1 (coil 1)    │   │
│  │      sensor_blue: MW102 (1126)      diverter_white: QX0.2 (coil 2)  │   │
│  │      package_present: MW103         diverter_blue: QX0.3 (coil 3)   │   │
│  │      estop: MW104 (1128)           alarm: QX0.4                      │   │
│  │      start_button: MW105 (1129)    run_light: QX0.5                  │   │
│  │      stop_button: MW106 (1130)     fault_light: QX0.6                │   │
│  │      reset_button: MW107 (1131)    ready_light: QX0.7                │   │
│  │      exit_red: MW108 (1132)                                          │   │
│  │      exit_white: MW109 (1133)      registers:                        │   │
│  │      exit_blue: MW110 (1134)         count_red: MW0 (1024)           │   │
│  │                                       count_white: MW1 (1025)        │   │
│  │                                       count_blue: MW2 (1026)         │   │
│  │                                       count_total: MW3 (1027)        │   │
│  │                                       conveyor_speed: MW4 (1028)     │   │
│  │                                       cmd_speed: MW10 (1034)         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Modbus TCP (via CORE network)
                                    │ docker exec core-novnc docker exec eng-ws python3 ...
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CORE Network Emulator (core-novnc)                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  eng-ws (Engineering Workstation)                                    │   │
│  │  - Executes pymodbus commands to PLC                                │   │
│  │  - IP: 10.0.0.20 (example)                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    │ Modbus TCP (port 502)                  │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  plc (OpenPLC Runtime)                                               │   │
│  │  - IP: 10.0.0.10                                                    │   │
│  │  - Modbus Server: port 502                                          │   │
│  │  - Web UI: port 8080                                                │   │
│  │                                                                       │   │
│  │  Running: sorting_twin.st                                            │   │
│  │  - Reads inputs from MW100-MW110                                    │   │
│  │  - Writes outputs to QX0.0-QX0.7                                    │   │
│  │  - Writes counters/speed to MW0-MW10                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Details

### 1. Sensor Data (3D Twin → PLC)

**Flow:**
```
3D Twin detects package → sortingControl.reportSensor() → WebSocket message →
PLC I/O Bridge → Modbus write to holding register → OpenPLC reads MW register
```

**Example - Color Sensor Detection:**
1. 3D physics detects red package at sensor position
2. JavaScript calls: `sortingControl.reportSensor('sensor_red', true)`
3. Parent window sends WebSocket message: `{"type": "sensor", "name": "sensor_red", "value": true}`
4. Bridge receives message, calls `set_input('sensor_red', True)`
5. Bridge poll loop writes holding register MW100 (address 1124) = 1
6. PLC reads `mw_sensor_red AT %MW100 : INT` and converts to BOOL
7. PLC triggers diverter logic

### 2. Actuator Commands (PLC → 3D Twin)

**Flow:**
```
PLC writes coil → Bridge reads coil → WebSocket broadcast →
Parent window updates plcState → iframe reads sortingControl API
```

**Example - Diverter Activation:**
1. PLC sets `diverter_red AT %QX0.1 : BOOL := TRUE`
2. Bridge poll loop reads coil 1 via Modbus
3. Bridge broadcasts: `{"type": "plc_state", "data": {"outputs": {"diverter_red": true}, ...}}`
4. Parent window receives WebSocket message, updates `plcState.outputs.diverter_red = true`
5. 3D Twin calls `sortingControl.isDiverterActive('red')` which returns `true`
6. Diverter mesh animates to open position

### 3. Control Buttons (3D UI → PLC)

**Flow:**
```
User clicks Start → reportSensor('start_button', true) → MW105 = 1 →
PLC detects rising edge → system_running = TRUE → QX0.0 (conveyor_run) = TRUE
```

**Button Mappings:**
| Button | Sensor Name | MW Register | Modbus Address |
|--------|-------------|-------------|----------------|
| Start | start_button | MW105 | 1129 |
| Stop | stop_button | MW106 | 1130 |
| Reset | reset_button | MW107 | 1131 |
| E-Stop | estop | MW104 | 1128 |

### 4. Exit Sensors (NEW in v5)

The exit sensors trigger diverter close:

```
Package reaches side belt exit → exit_sensor_red detects →
sortingControl.reportSensor('exit_red', true) → MW108 = 1 →
PLC decrements red_pending → if pending=0, closes diverter
```

**Exit Sensor Mappings:**
| Sensor | MW Register | Modbus Address |
|--------|-------------|----------------|
| exit_red | MW108 | 1132 |
| exit_white | MW109 | 1133 |
| exit_blue | MW110 | 1134 |

## Troubleshooting Guide

### Problem: Conveyor not running despite conveyor_run=true in PLC

**Possible Causes:**
1. **Bridge not started** - Check `/api/plc-bridge/status`
2. **WebSocket not connected** - Check browser console for connection errors
3. **sortingControl not injected** - Must access via `/digital-twin` route, not directly
4. **CORS issue** - iframe must be same-origin

**Fix:**
```bash
# Start bridge
curl -X POST http://localhost:8080/api/plc-bridge/start \
  -H "Content-Type: application/json" \
  -d '{"plc_ip": "10.0.0.10", "plc_port": 502}'

# Verify
curl http://localhost:8080/api/plc-bridge/status
```

### Problem: Buttons don't work (Start/Stop)

**Possible Causes:**
1. **Wrong Modbus addresses** - Node-RED or bridge writing to wrong registers
2. **PLC not running** - OpenPLC runtime not started
3. **Edge detection issue** - Button must be pulsed, not held

**Check PLC is running:**
```bash
docker exec core-novnc docker exec plc netstat -tlnp | grep 502
```

**Check Modbus addresses match:**
- Start button: MW105 (address 1129), NOT HR20
- Stop button: MW106 (address 1130), NOT HR21

### Problem: Diverters don't activate

**Possible Causes:**
1. **Timing issue** - Package too fast, sensor detection missed
2. **Exit sensors not configured** - Diverter closes immediately
3. **PLC logic error** - Check sorting_twin.st

**Debug via bridge status:**
```bash
curl http://localhost:8080/api/plc-bridge/status | jq '.state.outputs'
```

### Problem: WebSocket disconnects

**Check server logs:**
```bash
tail -f /tmp/webui.log | grep -E "WebSocket|plc-io|Twin"
```

**Verify gevent WebSocket is running:**
```bash
grep "Starting with gevent" /tmp/webui.log
```

## API Reference

### REST Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/plc-bridge/status` | GET | Get bridge status and IO state |
| `/api/plc-bridge/start` | POST | Start bridge with `{plc_ip, plc_port}` |
| `/api/plc-bridge/stop` | POST | Stop the bridge |
| `/api/plc/state` | GET | Get simplified PLC state |
| `/api/plc/command` | POST | Send button commands |

### WebSocket Protocol (/ws/plc-io)

**Client → Server:**
```json
{"type": "sensor", "name": "sensor_red", "value": true}
{"type": "register", "name": "cmd_speed", "value": 75}
{"type": "get_state"}
{"type": "get_io_map"}
```

**Server → Client:**
```json
{
  "type": "plc_state",
  "data": {
    "connected": true,
    "outputs": {"conveyor_run": true, "diverter_red": false, ...},
    "registers": {"conveyor_speed": 50, "count_red": 5, ...},
    "inputs": {}
  }
}
```

## Files Reference

| File | Purpose |
|------|---------|
| `plc_io_bridge.py` | Modbus-WebSocket bridge |
| `templates/digital_twin.html` | Bridge wrapper that injects sortingControl |
| `static/digital-twin/index.html` | 3D visualization (industrial-digital-twin_5) |
| `plc_programs/sorting_twin.st` | OpenPLC program with sensor-based diverter control |
| `dockerfiles/nodered-hmi/flows.json` | Node-RED HMI flows |

## Version History

- **v1-v4**: Timing-based diverter control, various iterations
- **v5**: Sensor-based diverter control with exit sensors
  - Added exit_red, exit_white, exit_blue sensors at x=3.5 on side belts
  - PLC uses exit sensors to close diverters instead of fixed timing
  - Added safety timeout (5 seconds) as fallback
