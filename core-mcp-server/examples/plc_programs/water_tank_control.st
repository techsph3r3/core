(*
   Water Tank Level Control System
   ================================
   A simple PLC program demonstrating:
   - Analog input (tank level sensor)
   - Digital inputs (start/stop buttons, high/low level switches)
   - Digital outputs (pump, alarm)
   - Analog output (valve position)

   Modbus Register Mapping:
   ------------------------
   INPUTS (Read from Modbus):
     %IX0.0 - Start Button (Coil 0)
     %IX0.1 - Stop Button (Coil 1)
     %IX0.2 - High Level Switch (Coil 2)
     %IX0.3 - Low Level Switch (Coil 3)
     %IW0   - Tank Level Sensor 0-100% (Input Register 0)

   OUTPUTS (Write via Modbus):
     %QX0.0 - Pump Running (Coil 100)
     %QX0.1 - High Level Alarm (Coil 101)
     %QX0.2 - Low Level Alarm (Coil 102)
     %QW0   - Outlet Valve Position 0-100% (Holding Register 0)

   INTERNAL:
     %MW0   - Setpoint (Holding Register 1024) - target level
     %MW1   - Cycle Counter (Holding Register 1025)
*)

PROGRAM water_tank_control
  VAR
    (* Digital Inputs *)
    start_button AT %IX0.0 : BOOL;
    stop_button AT %IX0.1 : BOOL;
    high_level_sw AT %IX0.2 : BOOL;
    low_level_sw AT %IX0.3 : BOOL;

    (* Analog Input - Tank Level 0-10000 = 0-100.00% *)
    tank_level AT %IW0 : INT;

    (* Digital Outputs *)
    pump_running AT %QX0.0 : BOOL;
    high_alarm AT %QX0.1 : BOOL;
    low_alarm AT %QX0.2 : BOOL;

    (* Analog Output - Valve Position 0-10000 = 0-100.00% *)
    valve_position AT %QW0 : INT;

    (* Internal Variables *)
    setpoint AT %MW0 : INT := 5000;  (* Default 50% *)
    cycle_counter AT %MW1 : INT;

    (* Control state *)
    system_running : BOOL := FALSE;

    (* Hysteresis thresholds *)
    high_threshold : INT := 8000;  (* 80% *)
    low_threshold : INT := 2000;   (* 20% *)
  END_VAR

  (* Increment cycle counter *)
  cycle_counter := cycle_counter + 1;
  IF cycle_counter > 32000 THEN
    cycle_counter := 0;
  END_IF;

  (* Start/Stop logic with latching *)
  IF start_button AND NOT stop_button THEN
    system_running := TRUE;
  END_IF;

  IF stop_button THEN
    system_running := FALSE;
  END_IF;

  (* Pump control - fill tank when level is low *)
  IF system_running THEN
    (* Turn on pump if level below setpoint minus hysteresis *)
    IF tank_level < (setpoint - 500) THEN
      pump_running := TRUE;
    END_IF;

    (* Turn off pump if level above setpoint plus hysteresis *)
    IF tank_level > (setpoint + 500) THEN
      pump_running := FALSE;
    END_IF;

    (* Emergency stop if high level switch triggered *)
    IF high_level_sw THEN
      pump_running := FALSE;
    END_IF;
  ELSE
    pump_running := FALSE;
  END_IF;

  (* Alarm logic *)
  high_alarm := (tank_level > high_threshold) OR high_level_sw;
  low_alarm := (tank_level < low_threshold) OR low_level_sw;

  (* Valve control - proportional to level (drain when high) *)
  IF tank_level > setpoint THEN
    (* Open valve proportionally when above setpoint *)
    valve_position := (tank_level - setpoint) * 2;
    IF valve_position > 10000 THEN
      valve_position := 10000;
    END_IF;
  ELSE
    valve_position := 0;
  END_IF;

END_PROGRAM


CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK Main(INTERVAL := T#100ms, PRIORITY := 0);
    PROGRAM Inst0 WITH Main : water_tank_control;
  END_RESOURCE
END_CONFIGURATION
