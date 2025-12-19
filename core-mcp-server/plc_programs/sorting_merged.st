(*
 * Sorting Facility PLC Program - Digital Twin Compatible (Merged)
 *
 * Logic: Simplified V2 Logic
 * I/O Layer: Digital Twin Registers (MW100+)
 * Forces: Implemented via MW112+
 *)

PROGRAM SortingController
VAR
    (* Holding register inputs from digital twin - Modbus addresses 1124-1135 *)
    mw_sensor_red AT %MW100 : INT;
    mw_sensor_white AT %MW101 : INT;
    mw_sensor_blue AT %MW102 : INT;
    mw_package_present AT %MW103 : INT;
    mw_estop AT %MW104 : INT;
    mw_start_button AT %MW105 : INT;
    mw_stop_button AT %MW106 : INT;
    mw_reset_button AT %MW107 : INT;
    mw_exit_red AT %MW108 : INT;
    mw_exit_white AT %MW109 : INT;
    mw_exit_blue AT %MW110 : INT;
    mw_debug_mode AT %MW111 : INT;

    (* Outputs to digital twin *)
    conveyor_run AT %QX0.0 : BOOL;
    diverter_red AT %QX0.1 : BOOL;
    diverter_white AT %QX0.2 : BOOL;
    diverter_blue AT %QX0.3 : BOOL;
    alarm AT %QX0.4 : BOOL;
    run_light AT %QX0.5 : BOOL;
    fault_light AT %QX0.6 : BOOL;
    ready_light AT %QX0.7 : BOOL;

    (* Debug/Passthrough Outputs *)
    debug_sensor_red AT %QX1.0 : BOOL;
    debug_sensor_white AT %QX1.1 : BOOL;
    debug_sensor_blue AT %QX1.2 : BOOL;
    debug_start_btn AT %QX1.3 : BOOL;
    debug_stop_btn AT %QX1.4 : BOOL;
    debug_reset_btn AT %QX1.5 : BOOL;
    debug_clock_pulse AT %QX1.6 : BOOL;
    debug_forced_mode AT %QX1.7 : BOOL;

    (* Internal Counters/Registers *)
    count_red AT %MW0 : INT;
    count_white AT %MW1 : INT;
    count_blue AT %MW2 : INT;
    count_total AT %MW3 : INT;
    conveyor_speed AT %MW4 : INT;
    cmd_speed AT %MW10 : INT;

    (* Force Registers *)
    force_conveyor AT %MW112 : INT;
    force_alarm AT %MW113 : INT;
    force_diverter_red AT %MW114 : INT;
    force_diverter_white AT %MW115 : INT;
    force_diverter_blue AT %MW116 : INT;
END_VAR
VAR
    (* Internal Bools *)
    sensor_red : BOOL;
    sensor_white : BOOL;
    sensor_blue : BOOL;
    package_present : BOOL;
    estop : BOOL;
    start_button : BOOL;
    stop_button : BOOL;
    reset_button : BOOL;

    (* State *)
    system_running : BOOL;
    system_fault : BOOL;
    
    (* Edge Detection *)
    start_edge : BOOL;
    stop_edge : BOOL;
    reset_edge : BOOL;
    prev_start : BOOL;
    prev_stop : BOOL;
    prev_reset : BOOL;
    red_edge : BOOL;
    white_edge : BOOL;
    blue_edge : BOOL;
    prev_red : BOOL;
    prev_white : BOOL;
    prev_blue : BOOL;

    (* Logic Controllers *)
    active_diverter : INT;
    diverter_timer : INT;
END_VAR

(* 1. Input Mapping *)
sensor_red := mw_sensor_red <> 0;
sensor_white := mw_sensor_white <> 0;
sensor_blue := mw_sensor_blue <> 0;
package_present := (mw_package_present <> 0) OR sensor_red OR sensor_white OR sensor_blue;
estop := mw_estop <> 0;
start_button := mw_start_button <> 0;
stop_button := mw_stop_button <> 0;
reset_button := mw_reset_button <> 0;

(* 2. Debug Passthrough *)
debug_sensor_red := sensor_red;
debug_sensor_white := sensor_white;
debug_sensor_blue := sensor_blue;
debug_start_btn := start_button;
debug_stop_btn := stop_button;
debug_reset_btn := reset_button;

(* 3. Edge Detection *)
start_edge := start_button AND NOT prev_start;
stop_edge := stop_button AND NOT prev_stop;
reset_edge := reset_button AND NOT prev_reset;
red_edge := sensor_red AND NOT prev_red;
white_edge := sensor_white AND NOT prev_white;
blue_edge := sensor_blue AND NOT prev_blue;

prev_start := start_button;
prev_stop := stop_button;
prev_reset := reset_button;
prev_red := sensor_red;
prev_white := sensor_white;
prev_blue := sensor_blue;

(* 4. Main Control Logic (Simplified V2) *)

IF estop THEN
  system_running := FALSE;
  system_fault := TRUE;
  conveyor_run := FALSE;
  diverter_red := FALSE;
  diverter_white := FALSE;
  diverter_blue := FALSE;
  alarm := TRUE;
END_IF;

IF reset_edge AND NOT estop THEN
  system_fault := FALSE;
  alarm := FALSE;
  count_red := 0;
  count_white := 0;
  count_blue := 0;
  count_total := 0;
  active_diverter := 0;
  diverter_timer := 0;
END_IF;

IF NOT system_fault THEN
  IF start_edge THEN
    system_running := TRUE;
  END_IF;
  IF stop_edge THEN
    system_running := FALSE;
  END_IF;
END_IF;

IF system_running AND NOT system_fault THEN
  (* Conveyor Logic with Force Override *)
  IF force_conveyor = 1 THEN
      conveyor_run := TRUE;
  ELSIF force_conveyor = 2 THEN
      conveyor_run := FALSE;
  ELSE
      conveyor_run := TRUE;
  END_IF;

  run_light := TRUE;
  ready_light := FALSE;
  fault_light := FALSE;

  IF cmd_speed > 0 AND cmd_speed <= 100 THEN
    conveyor_speed := cmd_speed;
  ELSE
    conveyor_speed := 50;
  END_IF;

  (* Package Detection *)
  IF package_present THEN
    IF red_edge THEN
      active_diverter := 1;
      diverter_timer := 100; (* Tuned for length of belt *)
      count_red := count_red + 1;
      count_total := count_total + 1;
    ELSIF white_edge THEN
      active_diverter := 2;
      diverter_timer := 100;
      count_white := count_white + 1;
      count_total := count_total + 1;
    ELSIF blue_edge THEN
      active_diverter := 3;
      diverter_timer := 100;
      count_blue := count_blue + 1;
      count_total := count_total + 1;
    END_IF;
  END_IF;

  (* Diverter Timer Logic *)
  IF diverter_timer > 0 THEN
    diverter_timer := diverter_timer - 1;
    
    (* Diverter Red Control *)
    IF force_diverter_red = 1 THEN diverter_red := TRUE;
    ELSIF force_diverter_red = 2 THEN diverter_red := FALSE;
    ELSE diverter_red := (active_diverter = 1);
    END_IF;

    (* Diverter White Control *)
    IF force_diverter_white = 1 THEN diverter_white := TRUE;
    ELSIF force_diverter_white = 2 THEN diverter_white := FALSE;
    ELSE diverter_white := (active_diverter = 2);
    END_IF;

    (* Diverter Blue Control *)
    IF force_diverter_blue = 1 THEN diverter_blue := TRUE;
    ELSIF force_diverter_blue = 2 THEN diverter_blue := FALSE;
    ELSE diverter_blue := (active_diverter = 3);
    END_IF;

  ELSE
    active_diverter := 0;
    (* Turn off all unless forced *)
    IF force_diverter_red = 1 THEN diverter_red := TRUE; ELSE diverter_red := FALSE; END_IF;
    IF force_diverter_white = 1 THEN diverter_white := TRUE; ELSE diverter_white := FALSE; END_IF;
    IF force_diverter_blue = 1 THEN diverter_blue := TRUE; ELSE diverter_blue := FALSE; END_IF;
  END_IF;

ELSE
  (* System Stopped *)
  conveyor_run := (force_conveyor = 1);
  conveyor_speed := 0;
  
  IF force_diverter_red = 1 THEN diverter_red := TRUE; ELSE diverter_red := FALSE; END_IF;
  IF force_diverter_white = 1 THEN diverter_white := TRUE; ELSE diverter_white := FALSE; END_IF;
  IF force_diverter_blue = 1 THEN diverter_blue := TRUE; ELSE diverter_blue := FALSE; END_IF;

  active_diverter := 0;
  diverter_timer := 0;
  run_light := FALSE;

  IF system_fault THEN
    fault_light := TRUE;
    ready_light := FALSE;
  ELSE
    fault_light := FALSE;
    ready_light := TRUE;
  END_IF;
END_IF;

(* Alarm Force Logic *)
IF force_alarm = 1 THEN alarm := TRUE;
ELSIF force_alarm = 2 THEN alarm := FALSE;
ELSIF system_fault THEN alarm := TRUE;
END_IF;

END_PROGRAM


CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK MainTask(INTERVAL := T#10ms, PRIORITY := 0);
    PROGRAM Inst0 WITH MainTask : SortingController;
  END_RESOURCE
END_CONFIGURATION
