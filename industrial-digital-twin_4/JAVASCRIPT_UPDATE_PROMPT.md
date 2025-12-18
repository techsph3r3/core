# JavaScript 3D Digital Twin Update - Exit Sensor Implementation

## Overview

The PLC logic has been updated to use **sensor-based diverter control** instead of timing-based control. The digital twin JavaScript needs to be updated to:

1. **Add EXIT SENSORS** on each side conveyor belt
2. **Report exit sensor states** to the PLC via the sortingControl API
3. **Remove any hardcoded diverter timing logic** from the JavaScript (the PLC now controls everything)

## Current State

The existing code already has side sensors created (`sensor_side_red`, `sensor_side_white`, `sensor_side_blue`) at position x=1.8, but they are:
- Not being properly monitored for package detection
- Not being reported to the PLC

## Required Changes

### 1. Rename/Relocate Exit Sensors

The existing `sensor_side_*` sensors should be relocated further down the side conveyor to act as EXIT sensors (to detect when a package has fully exited onto the side belt).

**Current position:** x=1.8 (too close to main conveyor)
**New position:** x=3.5 to 4.0 (further down the side belt, where package should trigger close)

In `buildScene()`, change:
```javascript
// OLD
this.addEntity(createSensor(`sensor_side_${c}`, { x: 1.8, y: 0.2, z: st.takeoutZ }, colorHex[c]));

// NEW - rename to exit_sensor and move further down the belt
this.addEntity(createSensor(`exit_sensor_${c}`, { x: 3.5, y: 0.2, z: st.takeoutZ }, colorHex[c]));
```

### 2. Update runPLCLogic() to Monitor Exit Sensors

The `runPLCLogic()` function currently only monitors the main color sensors. Add monitoring for exit sensors:

```javascript
runPLCLogic() {
    const sortingControl = window.sortingControl;

    const stations = [
      { color: 'red', mainSensor: 'sensor_red', exitSensor: 'exit_sensor_red', diverter: 'pusher_red' },
      { color: 'white', mainSensor: 'sensor_white', exitSensor: 'exit_sensor_white', diverter: 'pusher_white' },
      { color: 'blue', mainSensor: 'sensor_blue', exitSensor: 'exit_sensor_blue', diverter: 'pusher_blue' },
    ];

    stations.forEach(st => {
      // --- MAIN COLOR SENSOR (detects package color on main belt) ---
      const sensorEntity = this.entities.get(st.mainSensor);
      let colorDetected = false;
      if (sensorEntity) {
        const sensorBodyPos = sensorEntity.body.position;
        const light = sensorEntity.mesh.getObjectByName('SensorLight');
        if (light) light.material.color.setHex(0x333333);

        for (const [key, entity] of this.entities) {
          if (entity.type === 'dynamic') {
            const dx = entity.body.position.x - sensorBodyPos.x;
            const dz = entity.body.position.z - sensorBodyPos.z;
            // Detect matching color package
            if (Math.sqrt(dx*dx + dz*dz) < 0.4 && entity.data?.color === st.color) {
              colorDetected = true;
              if (light) light.material.color.setHex(0x00ff00);
              break;
            }
          }
        }
      }

      // Report color sensor state change
      if (sortingControl && sortingControl.reportSensor) {
        const prev = this.previousSensorStates.get(st.mainSensor) || false;
        if (colorDetected !== prev) {
          sortingControl.reportSensor(`sensor_${st.color}`, colorDetected);
          this.previousSensorStates.set(st.mainSensor, colorDetected);
        }
      }

      // --- EXIT SENSOR (detects ANY package leaving on side belt) ---
      const exitSensorEntity = this.entities.get(st.exitSensor);
      let exitDetected = false;
      if (exitSensorEntity) {
        const exitSensorPos = exitSensorEntity.body.position;
        const exitLight = exitSensorEntity.mesh.getObjectByName('SensorLight');
        if (exitLight) exitLight.material.color.setHex(0x333333);

        for (const [key, entity] of this.entities) {
          if (entity.type === 'dynamic') {
            const dx = entity.body.position.x - exitSensorPos.x;
            const dz = entity.body.position.z - exitSensorPos.z;
            // Detect ANY package (not color-specific) within range
            if (Math.sqrt(dx*dx + dz*dz) < 0.5) {
              exitDetected = true;
              if (exitLight) exitLight.material.color.setHex(0xffff00); // Yellow for exit
              break;
            }
          }
        }
      }

      // Report exit sensor state change
      if (sortingControl && sortingControl.reportSensor) {
        const prevExit = this.previousSensorStates.get(st.exitSensor) || false;
        if (exitDetected !== prevExit) {
          sortingControl.reportSensor(`exit_${st.color}`, exitDetected);
          this.previousSensorStates.set(st.exitSensor, exitDetected);
        }
      }

      // --- ACTUATE DIVERTER (unchanged - reads from PLC) ---
      let diverterActive = false;
      if (sortingControl && sortingControl.isDiverterActive) {
        diverterActive = sortingControl.isDiverterActive(st.color);
      }
      const diverter = this.entities.get(st.diverter);
      if (diverter && diverter.setActive) diverter.setActive(diverterActive);
    });
}
```

### 3. Update sortingControl API (if needed)

The `window.sortingControl` API must handle the new exit sensor reports. The `reportSensor` function should accept these sensor names:
- `sensor_red`, `sensor_white`, `sensor_blue` (color detection - already implemented)
- `exit_red`, `exit_white`, `exit_blue` (exit detection - NEW)

The API should write to Modbus registers:
- MW108 = exit_red
- MW109 = exit_white
- MW110 = exit_blue

### 4. Visual Distinction for Exit Sensors

Make exit sensors visually distinct from color sensors:

```javascript
const createSensor = (id, pos, colorIndicator, isExitSensor = false) => {
  // ... existing code ...

  // Different appearance for exit sensors
  if (isExitSensor) {
    // Make it a cylinder or different shape
    // Use a different indicator color (e.g., yellow/amber)
  }

  // ... rest of code ...
};
```

Or simpler - just use a different color for exit sensor indicator lights (yellow when triggered instead of green).

### 5. Remove Any Hardcoded Diverter Timing

Search the JavaScript code for any logic that:
- Opens/closes diverters based on timers
- Manages diverter state directly without PLC commands

The ONLY thing that should control diverters is reading `sortingControl.isDiverterActive(color)`. The PLC handles all timing logic.

## Summary of Changes

| Component | Change |
|-----------|--------|
| `buildScene()` | Rename `sensor_side_*` to `exit_sensor_*`, move to x=3.5 |
| `runPLCLogic()` | Add exit sensor detection loop, report to `sortingControl.reportSensor('exit_*', state)` |
| `createSensor()` | Optionally add visual distinction for exit sensors |
| `sortingControl` | Ensure API handles `exit_red`, `exit_white`, `exit_blue` sensor reports |

## PLC Modbus Register Mapping

| Register | Sensor |
|----------|--------|
| MW100 | sensor_red (color detection) |
| MW101 | sensor_white (color detection) |
| MW102 | sensor_blue (color detection) |
| MW103 | package_present |
| MW104 | estop |
| MW105 | start_button |
| MW106 | stop_button |
| MW107 | reset_button |
| MW108 | exit_red (NEW - exit sensor) |
| MW109 | exit_white (NEW - exit sensor) |
| MW110 | exit_blue (NEW - exit sensor) |

## Testing

After implementing:

1. Spawn a red package
2. Verify color sensor (sensor_red) triggers when package passes z=-12
3. Verify diverter opens after delay (controlled by PLC)
4. Verify exit sensor (exit_red) triggers when package reaches x=3.5 on side belt
5. Verify diverter closes when exit sensor triggers
6. Repeat for white and blue packages

The key behavior change is: **Diverters close when the exit sensor detects the package, not after a fixed time.**
