# Micro:bit IoT Data Flow Architecture

This document describes how the BBC micro:bit integrates with the CORE network emulator to create a physical-to-virtual IoT data pipeline.

## Overview

The system bridges physical micro:bit sensor data into a virtualized CORE network, allowing real hardware to interact with emulated IoT infrastructure. Data flows from your desk through your browser into a simulated industrial network.

```
┌─────────────┐    USB     ┌─────────────┐   WebSerial   ┌─────────────┐
│  micro:bit  │───────────▶│   Browser   │──────────────▶│  Dashboard  │
│  (Physical) │   Serial   │  (Chrome)   │    API        │  (Web UI)   │
└─────────────┘            └─────────────┘               └──────┬──────┘
                                                                │
                                                         POST /api/inject
                                                                │
                                                                ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         CORE Network Emulator                            │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐              │
│  │ mqtt-broker │◀─────│   Injector  │◀─────│  Web UI     │              │
│  │  10.0.1.10  │ MQTT │  (Embedded) │ HTTP │  :8080      │              │
│  └──────┬──────┘      └─────────────┘      └─────────────┘              │
│         │                                                                │
│         │ MQTT Subscribe: core/sensors/#                                 │
│         ▼                                                                │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐              │
│  │sensor-server│      │    HMI      │      │   Other     │              │
│  │  10.0.1.20  │      │  10.0.1.30  │      │   Nodes     │              │
│  └─────────────┘      └─────────────┘      └─────────────┘              │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Micro:bit (Physical Device)

The BBC micro:bit V2 runs custom MakeCode firmware that:
- Reads sensor data (accelerometer, temperature, light, sound, compass, buttons)
- Outputs JSON over USB serial at configurable intervals
- Receives commands for LED matrix and speaker control

**Firmware Output Format (Basic):**
```json
{"ax":-4,"ay":-88,"az":1012}
```

**Firmware Output Format (Full):**
```json
{"ax":-4,"ay":-88,"az":1012,"t":23,"s":45,"ch":180,"ba":0,"bb":0,"bl":0,"p0":512,"p1":0,"p2":0}
```

| Field | Description | Unit |
|-------|-------------|------|
| `ax`, `ay`, `az` | Accelerometer X, Y, Z | milli-g |
| `t` | Temperature | °C |
| `l` | Light level (when LED off) | 0-255 |
| `s` | Sound level (V2 only) | 0-255 |
| `ch` | Compass heading | degrees |
| `cm` | Magnetic force | micro-Tesla |
| `ba`, `bb` | Button A, B pressed | 0/1 |
| `bl` | Logo touched (V2) | 0/1 |
| `p0`, `p1`, `p2` | Analog pin readings | 0-1023 |

### 2. Browser WebSerial API

The dashboard uses the Web Serial API (Chrome/Edge only) to communicate with the micro:bit:

```javascript
// Request serial port access
const port = await navigator.serial.requestPort({
    filters: [{ usbVendorId: 0x0d28 }]  // BBC micro:bit vendor ID
});

// Open connection at 115200 baud
await port.open({ baudRate: 115200 });

// Read data stream
const reader = port.readable.getReader();
while (true) {
    const { value, done } = await reader.read();
    // Parse JSON lines from value (Uint8Array)
}
```

**Key Points:**
- WebSerial requires HTTPS or localhost
- User must grant permission via browser dialog
- Connection persists until page close or disconnect
- Bidirectional: can send commands back to micro:bit

### 3. Dashboard (Web UI)

Located at `http://localhost:8080`, the dashboard:

1. **Connects to micro:bit** via WebSerial
2. **Parses JSON** sensor data from serial stream
3. **Displays real-time values** in the UI
4. **Forwards data** to two endpoints:
   - `/api/sensors/{sensor_id}/data` - Local storage for dashboard display
   - `/api/inject/{sensor_id}` - MQTT injection into CORE network

**Dashboard JavaScript (simplified):**
```javascript
// When micro:bit data arrives
function handleMicrobitData(data) {
    // Update local display
    microbitLastData.value = data;

    // Send to local sensor store
    fetch(`/api/sensors/${sensorId}/data`, {
        method: 'POST',
        body: JSON.stringify(data)
    });

    // Inject into CORE network (if enabled)
    if (microbitConfig.sendToCore) {
        fetch(`/api/inject/${sensorId}`, {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }
}
```

### 4. MQTT Injector (Embedded)

The web UI server (`web_ui.py`) contains an embedded MQTT injector that bridges HTTP requests to the CORE network.

**Architecture:**
```
HTTP POST ──▶ Flask Route ──▶ Injector Queue ──▶ Docker Exec ──▶ MQTT Publish
```

**How it works:**

1. **Configuration** (`/api/inject/configure`):
   ```json
   {
     "broker_ip": "10.0.1.10",
     "broker_node": "mqtt-broker"
   }
   ```

2. **Injection** (`/api/inject/{sensor_id}`):
   - Receives sensor data via HTTP POST
   - Executes Docker command to publish to MQTT broker inside CORE:
   ```bash
   docker exec core-novnc docker exec mqtt-broker \
       mosquitto_pub -h localhost -t "core/sensors/{sensor_id}/data" \
       -m '{"ax":-4,"ay":-88,"az":1012}'
   ```

**Why Docker-in-Docker?**
- The web UI runs on the host machine
- CORE nodes run inside Docker containers
- The MQTT broker is only accessible from within the CORE network
- We use `docker exec` to run `mosquitto_pub` inside the broker container

**Injector Code Path:**
```
web_ui.py:4358  - /api/inject/<sensor_id> route
web_ui.py:93    - EmbeddedMQTTInjector class
web_ui.py:180   - _execute_in_core() method
```

### 5. MQTT Broker (mqtt-broker container)

The Mosquitto MQTT broker runs inside CORE at `10.0.1.10`:

- **Listens on port 1883** for MQTT connections
- **Topic structure:** `core/sensors/{sensor_id}/data`
- **No authentication** (internal network only)

All CORE nodes can subscribe to sensor data by connecting to `10.0.1.10:1883`.

### 6. Sensor Server (sensor-server container)

A Flask application at `10.0.1.20` that:

1. **Subscribes to MQTT** topic `core/sensors/#`
2. **Stores sensor data** in memory (dictionary)
3. **Serves web dashboard** showing all active sensors
4. **Provides REST API** at `/api/sensors`

**MQTT Subscription:**
```python
def on_message(client, userdata, msg):
    data = json.loads(msg.payload.decode())
    sensor_id = msg.topic.split('/')[2]  # core/sensors/{id}/data
    sensor_data['sensors'][sensor_id] = data
```

**Web Interface:** `http://10.0.1.20/` (port 80, not 5000!)

Shows real-time sensor cards with:
- Accelerometer visualization
- Temperature, light, sound readings
- Button states
- Connection status (active/stale)

## Data Flow Sequence

```
1. micro:bit samples sensors
   └──▶ Outputs: {"ax":-4,"ay":-88,"az":1012}

2. USB Serial transmits to computer
   └──▶ 115200 baud, newline-delimited JSON

3. Browser WebSerial API receives bytes
   └──▶ Converts to string, parses JSON

4. Dashboard JavaScript processes data
   ├──▶ Updates UI display
   └──▶ POST /api/inject/microbit-xxxxx

5. Flask server receives HTTP POST
   └──▶ Queues for MQTT injection

6. Injector executes Docker command
   └──▶ docker exec core-novnc docker exec mqtt-broker mosquitto_pub ...

7. MQTT broker receives message
   └──▶ Publishes to topic: core/sensors/microbit-xxxxx/data

8. sensor-server receives MQTT message
   └──▶ Updates internal sensor_data dictionary

9. sensor-server web page polls /api/sensors
   └──▶ Displays updated sensor values
```

## Configuration

### Injector Setup

The injector must be configured before data flows to CORE:

```bash
curl -X POST http://localhost:8080/api/inject/configure \
  -H "Content-Type: application/json" \
  -d '{"broker_ip": "10.0.1.10", "broker_node": "mqtt-broker"}'
```

This is automatically done when loading an IoT topology via `load_topology.py`.

### Check Injector Status

```bash
curl http://localhost:8080/api/inject/status
```

Response:
```json
{
  "broker_ip": "10.0.1.10",
  "broker_node": "mqtt-broker",
  "running": true,
  "message_count": 1234,
  "last_error": null
}
```

### Manual Data Injection

Test the pipeline without a micro:bit:

```bash
curl -X POST http://localhost:8080/api/inject/test-sensor \
  -H "Content-Type: application/json" \
  -d '{"ax": 100, "ay": 200, "az": 1000, "t": 25}'
```

## Firmware Installation

### Basic Firmware (Accelerometer Only)

```javascript
basic.forever(function () {
    let x = input.acceleration(Dimension.X)
    let y = input.acceleration(Dimension.Y)
    let z = input.acceleration(Dimension.Z)
    serial.writeLine('{"ax":' + x + ',"ay":' + y + ',"az":' + z + '}')
    basic.pause(100)
})
```

### Full Firmware (All Sensors + Controls)

The full firmware includes:
- All sensor readings
- Bidirectional serial communication
- LED matrix control via commands
- Speaker/melody playback
- Configurable sample rate

Available in the dashboard under **Micro:bit Settings > Full (All Sensors)**.

### Flashing Process

1. Go to [makecode.microbit.org](https://makecode.microbit.org/)
2. Click **JavaScript** tab
3. Delete existing code, paste firmware
4. Click **Download**
5. Copy `.hex` file to MICROBIT drive

## Troubleshooting

### No data in sensor-server

1. **Check injector is configured:**
   ```bash
   curl http://localhost:8080/api/inject/status
   # Should show running: true, broker_ip: 10.0.1.10
   ```

2. **Check MQTT messages arrive at broker:**
   ```bash
   docker exec core-novnc docker exec mqtt-broker \
       mosquitto_sub -h localhost -t "core/sensors/#" -v
   ```

3. **Check sensor-server API:**
   ```bash
   docker exec core-novnc docker exec mqtt-broker \
       wget -q -O - http://10.0.1.20/api/sensors
   ```

### WebSerial not working

- Use Chrome or Edge (Firefox doesn't support WebSerial)
- Must be on HTTPS or localhost
- Check browser console for errors
- Try unplugging and reconnecting micro:bit

### Injector returns 503

The injector is not configured. Run:
```bash
curl -X POST http://localhost:8080/api/inject/configure \
  -H "Content-Type: application/json" \
  -d '{"broker_ip": "10.0.1.10", "broker_node": "mqtt-broker"}'
```

### Data shows in dashboard but not sensor-server

- Verify "Send to CORE" toggle is enabled in micro:bit settings
- Check the web UI logs: `tail -f /tmp/webui.log`
- Ensure topology is running (CORE GUI shows green "Running" state)

## Security Considerations

- WebSerial requires explicit user permission
- MQTT broker has no authentication (isolated network)
- Data flows through Docker exec (requires Docker socket access)
- sensor-server is accessible only within CORE network

## Files Reference

| File | Purpose |
|------|---------|
| `web_ui.py` | Flask server with injector |
| `templates/dashboard.html` | Main dashboard with micro:bit UI |
| `templates/microbit.html` | Standalone micro:bit page |
| `load_topology.py` | Topology loader with auto-configure |
| `dockerfiles/Dockerfile.iot-sensor-server` | sensor-server container |
| `dockerfiles/Dockerfile.mqtt-broker-core` | MQTT broker container |
