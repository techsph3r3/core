# ICS Sorting Facility - Status Report
**Date:** 2025-12-10

---

## Completed Tasks

1. **Removed camera controls overlay** from `templates/dashboard.html` (lines 640-651) - the "3D Digital Twin Controls / Left Click: Rotate Camera..." text is gone.

2. **Updated `init_openplc.py`** to use curl instead of pymodbus (PLC container has older pymodbus version). Also added `press_start_button()` function to auto-start conveyor after PLC init.

3. **Fixed `init_openplc.py`** to use `eng-ws` container for pressing start button (which has pymodbus 3.x).

4. **v4 3D Twin deployed** with PLC-only control and WideControlPanel features.

5. **New sorting_twin.st** with delay-then-activate algorithm (6 independent timers for proper timing).

---

## Current Issue: Conveyor Won't Start

**Symptoms:**
- OpenPLC dashboard says "Running"
- Modbus port 502 is open
- Compilation succeeds
- But all outputs are FALSE including `ready_light`

**Root Cause (Suspected):**
The ST program's logic flow suggests the PLC may not be executing the program correctly, OR the initial state variables are not being set properly. The `ready_light` should be TRUE when system is stopped (not running) and no fault exists.

**Key observations:**
- `conveyor_run: False`
- `ready_light: False` (should be TRUE if system stopped without fault)
- `conveyor_speed: 0`
- Direct Modbus writes work (we successfully started conveyor earlier)
- After CORE restart, the PLC runtime needs recompilation/restart

---

## Files Modified This Session

| File | Changes |
|------|---------|
| `templates/dashboard.html` | Removed Twin Controls Overlay (lines 640-651) |
| `init_openplc.py` | Changed to use curl for compile/start, added auto-start via eng-ws |
| `plc_programs/sorting_twin.st` | New algorithm with 6 timers (already existed) |

---

## Commands to Resume

```bash
# 1. Check web UI is running
curl -s http://localhost:8080/ -o /dev/null -w "%{http_code}"

# 2. Check PLC bridge status
curl -s http://localhost:8080/api/plc-bridge/status | python3 -m json.tool

# 3. Full PLC state dump
docker exec core-novnc docker exec eng-ws python3 -c "
from pymodbus.client import ModbusTcpClient
client = ModbusTcpClient('10.0.0.10', port=502, timeout=2)
if client.connect():
    regs = client.read_holding_registers(address=1124, count=8)
    print('Inputs:', regs.registers if not regs.isError() else 'ERROR')
    coils = client.read_coils(address=0, count=8)
    print('Outputs:', list(coils.bits[:8]) if not coils.isError() else 'ERROR')
    client.close()
"

# 4. Manually press START button
docker exec core-novnc docker exec eng-ws python3 -c "
from pymodbus.client import ModbusTcpClient
import time
client = ModbusTcpClient('10.0.0.10', port=502, timeout=2)
client.connect()
client.write_register(address=1129, value=1)
time.sleep(0.3)
client.write_register(address=1129, value=0)
time.sleep(0.2)
coils = client.read_coils(address=0, count=1)
print(f'conveyor_run: {coils.bits[0]}')
client.close()
"

# 5. Re-run full init if needed
cd /workspaces/core/core-mcp-server
python3 init_openplc.py
```

---

## Access URLs

- **Digital Twin:** `https://musical-robot-97wwqxg47x7wh97q5-8080.app.github.dev/digital-twin`
- **eng-ws VNC:** `https://musical-robot-97wwqxg47x7wh97q5-8080.app.github.dev/hmi-vnc/6082/vnc_lite.html?scale=true&path=hmi-vnc/6082/websockify`
- **OpenPLC Web (from eng-ws Firefox):** `http://10.0.0.10:8080/` (creds: openplc/openplc)

---

## Next Steps to Investigate

1. **Check if PLC is actually executing the program** - read runtime logs from OpenPLC dashboard
2. **Verify the compiled binary** - the openplc binary exists at `/workdir/webserver/core/openplc`
3. **Test if the ST program has syntax errors** - check compilation logs more carefully
4. **Consider if system_fault is TRUE** on startup - might need initialization logic to ensure clean state

---

## Architecture Summary

```
Browser (Digital Twin)
    |
    | WebSocket /ws/plc-io
    v
Web UI (web_ui.py:8080)
    |
    | PLC I/O Bridge (plc_io_bridge.py)
    |
    | docker exec core-novnc docker exec eng-ws python3 (Modbus)
    v
OpenPLC (10.0.0.10:502) inside CORE network
    |
    | Runs sorting_twin.st program
    v
Outputs: conveyor_run, diverters, lights
```

## Key Files

- `/workspaces/core/core-mcp-server/plc_io_bridge.py` - WebSocket to Modbus bridge
- `/workspaces/core/core-mcp-server/init_openplc.py` - Auto-init script for OpenPLC
- `/workspaces/core/core-mcp-server/plc_programs/sorting_twin.st` - PLC logic with timing algorithm
- `/workspaces/core/core-mcp-server/static/digital-twin/index.html` - v4 3D Twin
- `/workspaces/core/core-mcp-server/templates/digital_twin.html` - Wrapper page
