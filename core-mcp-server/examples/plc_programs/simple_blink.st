(*
   Simple Blink / Counter Program
   ==============================
   The simplest possible OpenPLC program for testing.

   Modbus Register Mapping:
   ------------------------
     %QX0.0 - Blinking LED (Coil 100) - toggles every cycle
     %QX0.1 - Heartbeat (Coil 101) - always ON when running
     %MW0   - Counter (Holding Register 1024) - increments each cycle
     %MW1   - Toggle Speed (Holding Register 1025) - cycles between toggles

   To test via Modbus:
     - Read Coil 100: should toggle TRUE/FALSE
     - Read Holding Register 1024: should increment
     - Write Holding Register 1025: change blink speed (default 10)
*)

PROGRAM simple_blink
  VAR
    (* Outputs *)
    blink_led AT %QX0.0 : BOOL;
    heartbeat AT %QX0.1 : BOOL := TRUE;

    (* Internal registers accessible via Modbus *)
    counter AT %MW0 : INT := 0;
    toggle_speed AT %MW1 : INT := 10;

    (* Internal working variables *)
    tick_counter : INT := 0;
  END_VAR

  (* Always set heartbeat to show PLC is running *)
  heartbeat := TRUE;

  (* Increment main counter *)
  counter := counter + 1;
  IF counter > 30000 THEN
    counter := 0;
  END_IF;

  (* Blink logic with configurable speed *)
  tick_counter := tick_counter + 1;
  IF tick_counter >= toggle_speed THEN
    blink_led := NOT blink_led;
    tick_counter := 0;
  END_IF;

END_PROGRAM


CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK Main(INTERVAL := T#100ms, PRIORITY := 0);
    PROGRAM Inst0 WITH Main : simple_blink;
  END_RESOURCE
END_CONFIGURATION
