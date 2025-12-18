(*
 * Sorting Facility PLC Program
 *
 * This Structured Text (ST) program controls a 3-color package sorting facility.
 * It interfaces with a 3D digital twin via the PLC I/O bridge.
 *
 * I/O Mapping (matching plc_io_bridge.py):
 *
 * INPUTS (from 3D twin/sensors):
 *   %IX0.0 - sensor_red      : Color sensor detected RED package
 *   %IX0.1 - sensor_white    : Color sensor detected WHITE package
 *   %IX0.2 - sensor_blue     : Color sensor detected BLUE package
 *   %IX0.3 - package_present : Package at sensor position
 *   %IX0.4 - estop           : Emergency stop
 *   %IX0.5 - start_button    : Start pushbutton
 *   %IX0.6 - stop_button     : Stop pushbutton
 *   %IX0.7 - reset_button    : Reset/acknowledge button
 *
 * OUTPUTS (to 3D twin/actuators):
 *   %QX0.0 - conveyor_run    : Conveyor motor running
 *   %QX0.1 - diverter_red    : Red package diverter active
 *   %QX0.2 - diverter_white  : White package diverter active
 *   %QX0.3 - diverter_blue   : Blue package diverter active
 *   %QX0.4 - alarm           : Alarm indicator
 *   %QX0.5 - run_light       : System running indicator
 *   %QX0.6 - fault_light     : Fault indicator
 *   %QX0.7 - ready_light     : Ready indicator
 *
 * HOLDING REGISTERS:
 *   %MW0 - count_red         : Red package count
 *   %MW1 - count_white       : White package count
 *   %MW2 - count_blue        : Blue package count
 *   %MW3 - count_total       : Total package count
 *   %MW4 - conveyor_speed    : Current conveyor speed (0-100%)
 *   %MW10 - cmd_speed        : Commanded speed setpoint
 *
 * HMI COMMAND REGISTERS (written by Node-RED HMI):
 *   %MW20 - hmi_start        : Start command (1=start, auto-clears)
 *   %MW21 - hmi_stop         : Stop command (1=stop, auto-clears)
 *   %MW22 - hmi_feed         : Feed package (unused - 3D twin handles)
 *   %MW23 - hmi_reset        : Reset command (1=reset, auto-clears)
 *)

PROGRAM SortingController
VAR
    (* === INPUTS === *)
    (* Color sensors from 3D twin *)
    sensor_red AT %IX0.0 : BOOL;
    sensor_white AT %IX0.1 : BOOL;
    sensor_blue AT %IX0.2 : BOOL;
    package_present AT %IX0.3 : BOOL;

    (* Control buttons *)
    estop AT %IX0.4 : BOOL;
    start_button AT %IX0.5 : BOOL;
    stop_button AT %IX0.6 : BOOL;
    reset_button AT %IX0.7 : BOOL;

    (* === OUTPUTS === *)
    (* Actuators to 3D twin *)
    conveyor_run AT %QX0.0 : BOOL;
    diverter_red AT %QX0.1 : BOOL;
    diverter_white AT %QX0.2 : BOOL;
    diverter_blue AT %QX0.3 : BOOL;

    (* Status indicators *)
    alarm AT %QX0.4 : BOOL;
    run_light AT %QX0.5 : BOOL;
    fault_light AT %QX0.6 : BOOL;
    ready_light AT %QX0.7 : BOOL;

    (* === HOLDING REGISTERS === *)
    count_red AT %MW0 : INT;
    count_white AT %MW1 : INT;
    count_blue AT %MW2 : INT;
    count_total AT %MW3 : INT;
    conveyor_speed AT %MW4 : INT;
    cmd_speed AT %MW10 : INT;

    (* HMI Command Registers - written by Node-RED HMI *)
    hmi_start AT %MW20 : INT;    (* 1 = Start command *)
    hmi_stop AT %MW21 : INT;     (* 1 = Stop command *)
    hmi_feed AT %MW22 : INT;     (* 1 = Feed package command - unused, 3D twin handles this *)
    hmi_reset AT %MW23 : INT;    (* 1 = Reset command *)

    (* === INTERNAL VARIABLES === *)
    system_running : BOOL := FALSE;
    system_fault : BOOL := FALSE;

    (* Edge detection for physical buttons *)
    start_edge : BOOL := FALSE;
    stop_edge : BOOL := FALSE;
    reset_edge : BOOL := FALSE;
    prev_start : BOOL := FALSE;
    prev_stop : BOOL := FALSE;
    prev_reset : BOOL := FALSE;

    (* Edge detection for HMI commands *)
    hmi_start_edge : BOOL := FALSE;
    hmi_stop_edge : BOOL := FALSE;
    hmi_reset_edge : BOOL := FALSE;
    prev_hmi_start : BOOL := FALSE;
    prev_hmi_stop : BOOL := FALSE;
    prev_hmi_reset : BOOL := FALSE;

    (* Edge detection for sensors *)
    red_edge : BOOL := FALSE;
    white_edge : BOOL := FALSE;
    blue_edge : BOOL := FALSE;
    prev_red : BOOL := FALSE;
    prev_white : BOOL := FALSE;
    prev_blue : BOOL := FALSE;

    (* Diverter timing *)
    diverter_timer : INT := 0;
    DIVERTER_ACTIVE_TIME : INT := 30;  (* 300ms at 10ms scan rate - enough for package to pass *)
    active_diverter : INT := 0;  (* 0=none, 1=red, 2=white, 3=blue *)

END_VAR

(* ============================================================ *)
(* MAIN PROGRAM *)
(* ============================================================ *)

(* --- Edge Detection for Physical Buttons --- *)
start_edge := start_button AND NOT prev_start;
stop_edge := stop_button AND NOT prev_stop;
reset_edge := reset_button AND NOT prev_reset;
red_edge := sensor_red AND NOT prev_red;
white_edge := sensor_white AND NOT prev_white;
blue_edge := sensor_blue AND NOT prev_blue;

(* Store previous states for physical buttons *)
prev_start := start_button;
prev_stop := stop_button;
prev_reset := reset_button;
prev_red := sensor_red;
prev_white := sensor_white;
prev_blue := sensor_blue;

(* --- Edge Detection for HMI Commands --- *)
(* HMI writes 1 to register, we detect rising edge then clear it *)
hmi_start_edge := (hmi_start > 0) AND NOT prev_hmi_start;
hmi_stop_edge := (hmi_stop > 0) AND NOT prev_hmi_stop;
hmi_reset_edge := (hmi_reset > 0) AND NOT prev_hmi_reset;

(* Store previous HMI states *)
prev_hmi_start := hmi_start > 0;
prev_hmi_stop := hmi_stop > 0;
prev_hmi_reset := hmi_reset > 0;

(* Auto-clear HMI command registers after processing *)
IF hmi_start_edge THEN hmi_start := 0; END_IF;
IF hmi_stop_edge THEN hmi_stop := 0; END_IF;
IF hmi_reset_edge THEN hmi_reset := 0; END_IF;

(* --- Emergency Stop Logic --- *)
IF estop THEN
    system_running := FALSE;
    system_fault := TRUE;
    conveyor_run := FALSE;
    diverter_red := FALSE;
    diverter_white := FALSE;
    diverter_blue := FALSE;
    alarm := TRUE;
END_IF;

(* --- Reset Logic (from physical button OR HMI) --- *)
IF (reset_edge OR hmi_reset_edge) AND NOT estop THEN
    system_fault := FALSE;
    alarm := FALSE;
    (* Reset counters on reset *)
    count_red := 0;
    count_white := 0;
    count_blue := 0;
    count_total := 0;
END_IF;

(* --- Start/Stop Logic (from physical buttons OR HMI) --- *)
IF NOT system_fault THEN
    IF start_edge OR hmi_start_edge THEN
        system_running := TRUE;
    END_IF;

    IF stop_edge OR hmi_stop_edge THEN
        system_running := FALSE;
    END_IF;
END_IF;

(* --- Main Control Logic --- *)
IF system_running AND NOT system_fault THEN
    (* Run conveyor *)
    conveyor_run := TRUE;
    run_light := TRUE;
    ready_light := FALSE;

    (* Apply commanded speed *)
    IF cmd_speed > 0 AND cmd_speed <= 100 THEN
        conveyor_speed := cmd_speed;
    ELSE
        conveyor_speed := 50;  (* Default 50% speed *)
    END_IF;

    (* --- Color Detection and Sorting --- *)
    (* Detect new package at sensor *)
    IF package_present THEN
        (* Check which color was detected (priority: red > white > blue) *)
        (* If same color detected while diverter active, EXTEND timer to handle back-to-back packages *)
        IF red_edge THEN
            IF active_diverter = 1 THEN
                (* Same color - extend timer for back-to-back packages *)
                diverter_timer := diverter_timer + DIVERTER_ACTIVE_TIME;
            ELSE
                (* New color or no active diverter *)
                active_diverter := 1;
                diverter_timer := DIVERTER_ACTIVE_TIME;
            END_IF;
            count_red := count_red + 1;
            count_total := count_total + 1;
        ELSIF white_edge THEN
            IF active_diverter = 2 THEN
                (* Same color - extend timer *)
                diverter_timer := diverter_timer + DIVERTER_ACTIVE_TIME;
            ELSE
                active_diverter := 2;
                diverter_timer := DIVERTER_ACTIVE_TIME;
            END_IF;
            count_white := count_white + 1;
            count_total := count_total + 1;
        ELSIF blue_edge THEN
            IF active_diverter = 3 THEN
                (* Same color - extend timer *)
                diverter_timer := diverter_timer + DIVERTER_ACTIVE_TIME;
            ELSE
                active_diverter := 3;
                diverter_timer := DIVERTER_ACTIVE_TIME;
            END_IF;
            count_blue := count_blue + 1;
            count_total := count_total + 1;
        END_IF;
    END_IF;

    (* --- Diverter Control with Timer --- *)
    IF diverter_timer > 0 THEN
        diverter_timer := diverter_timer - 1;

        CASE active_diverter OF
            1: (* Red diverter *)
                diverter_red := TRUE;
                diverter_white := FALSE;
                diverter_blue := FALSE;
            2: (* White diverter *)
                diverter_red := FALSE;
                diverter_white := TRUE;
                diverter_blue := FALSE;
            3: (* Blue diverter *)
                diverter_red := FALSE;
                diverter_white := FALSE;
                diverter_blue := TRUE;
        END_CASE;
    ELSE
        (* Timer expired - deactivate all diverters *)
        active_diverter := 0;
        diverter_red := FALSE;
        diverter_white := FALSE;
        diverter_blue := FALSE;
    END_IF;

ELSE
    (* System stopped or faulted *)
    conveyor_run := FALSE;
    conveyor_speed := 0;

    (* Clear diverters *)
    diverter_red := FALSE;
    diverter_white := FALSE;
    diverter_blue := FALSE;
    active_diverter := 0;
    diverter_timer := 0;

    (* Update status lights *)
    run_light := FALSE;

    IF system_fault THEN
        fault_light := TRUE;
        ready_light := FALSE;
    ELSE
        fault_light := FALSE;
        ready_light := TRUE;  (* Ready to start *)
    END_IF;
END_IF;

END_PROGRAM


(* ============================================================ *)
(* CONFIGURATION *)
(* ============================================================ *)
CONFIGURATION Config0
    RESOURCE Res0 ON PLC
        TASK MainTask(INTERVAL := T#10ms, PRIORITY := 0);
        PROGRAM Inst0 WITH MainTask : SortingController;
    END_RESOURCE
END_CONFIGURATION
