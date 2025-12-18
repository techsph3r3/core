(*
 * Sorting Facility PLC Program - Digital Twin Compatible
 *
 * TIMING FIX: Implements proper delay between color detection and diverter activation
 * based on conveyor speed and sensor-to-diverter distance.
 *
 * Geometry (from 3D twin):
 *   - Color sensors at z = -12, -2, 8 (red, white, blue)
 *   - Diverters at z = -7, 3, 13 (red, white, blue)
 *   - Distance sensor to diverter: 5 meters
 *   - Block width: 0.5 meters
 *
 * Timing calculations:
 *   - Conveyor speed: MW4/20 m/s (e.g., MW4=50 -> 2.5 m/s)
 *   - Delay = distance / speed = 5m / (MW4/20) = 100/MW4 seconds
 *   - At 10ms scan: delay_cycles = 10000/MW4
 *   - Open duration: block_width / speed + margin = ~50 cycles
 *
 * CRITICAL: OpenPLC does NOT allow writing to %IX via Modbus.
 * This program reads inputs from HOLDING REGISTERS (MW100-MW111).
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
    debug_sensor_red AT %QX1.0 : BOOL;
    debug_sensor_white AT %QX1.1 : BOOL;
    debug_sensor_blue AT %QX1.2 : BOOL;
    debug_start_btn AT %QX1.3 : BOOL;
    debug_stop_btn AT %QX1.4 : BOOL;
    debug_reset_btn AT %QX1.5 : BOOL;
    debug_clock_pulse AT %QX1.6 : BOOL;
    debug_forced_mode AT %QX1.7 : BOOL;
    (* Counter registers *)
    count_red AT %MW0 : INT;
    count_white AT %MW1 : INT;
    count_blue AT %MW2 : INT;
    count_total AT %MW3 : INT;
    conveyor_speed AT %MW4 : INT;
    cmd_speed AT %MW10 : INT;
    (* HMI commands *)
    hmi_start AT %MW20 : INT;
    hmi_stop AT %MW21 : INT;
    hmi_feed AT %MW22 : INT;
    hmi_reset AT %MW23 : INT;
    (* Force mode registers - when non-zero, external control takes over *)
    force_conveyor AT %MW112 : INT;      (* 0=normal, 1=force ON, 2=force OFF *)
    force_alarm AT %MW113 : INT;         (* 0=normal, 1=force ON, 2=force OFF *)
    force_diverter_red AT %MW114 : INT;  (* 0=normal, 1=force ON, 2=force OFF *)
    force_diverter_white AT %MW115 : INT;
    force_diverter_blue AT %MW116 : INT;
    (* Timing debug registers - visible via Modbus for diagnostics *)
    debug_delay_red AT %MW117 : INT;     (* Current delay countdown for red *)
    debug_delay_white AT %MW118 : INT;   (* Current delay countdown for white *)
    debug_delay_blue AT %MW119 : INT;    (* Current delay countdown for blue *)
END_VAR
VAR
    (* Internal BOOLs - converted from holding registers *)
    sensor_red : BOOL;
    sensor_white : BOOL;
    sensor_blue : BOOL;
    package_present : BOOL;
    estop : BOOL;
    start_button : BOOL;
    stop_button : BOOL;
    reset_button : BOOL;
    exit_red : BOOL;
    exit_white : BOOL;
    exit_blue : BOOL;
    debug_mode : BOOL;
    (* System state *)
    system_running : BOOL;
    system_fault : BOOL;
    (* Edge detection *)
    start_edge : BOOL;
    stop_edge : BOOL;
    reset_edge : BOOL;
    prev_start : BOOL;
    prev_stop : BOOL;
    prev_reset : BOOL;
    hmi_start_edge : BOOL;
    hmi_stop_edge : BOOL;
    hmi_reset_edge : BOOL;
    prev_hmi_start : BOOL;
    prev_hmi_stop : BOOL;
    prev_hmi_reset : BOOL;
    red_edge : BOOL;
    white_edge : BOOL;
    blue_edge : BOOL;
    prev_red : BOOL;
    prev_white : BOOL;
    prev_blue : BOOL;
    clock_counter : INT;

    (* NEW: Delay-based diverter timing *)
    (* Each color has: delay timer (sensor->diverter) and open timer (how long open) *)
    (* Using queue slots to handle up to 3 packages per color in transit *)
    delay_red_1 : INT;      (* Delay countdown slot 1 for red *)
    delay_red_2 : INT;      (* Delay countdown slot 2 for red *)
    delay_red_3 : INT;      (* Delay countdown slot 3 for red *)
    open_red : INT;         (* How long red diverter stays open *)

    delay_white_1 : INT;
    delay_white_2 : INT;
    delay_white_3 : INT;
    open_white : INT;

    delay_blue_1 : INT;
    delay_blue_2 : INT;
    delay_blue_3 : INT;
    open_blue : INT;

    (* Calculated timing values *)
    calc_delay : INT;       (* Calculated delay cycles based on speed *)
    calc_open : INT;        (* Calculated open duration based on speed *)
    effective_speed : INT;  (* Speed used for calculations *)
END_VAR

(* Convert holding registers to BOOLs *)
sensor_red := mw_sensor_red <> 0;
sensor_white := mw_sensor_white <> 0;
sensor_blue := mw_sensor_blue <> 0;
package_present := (mw_package_present <> 0) OR sensor_red OR sensor_white OR sensor_blue;
estop := mw_estop <> 0;
start_button := mw_start_button <> 0;
stop_button := mw_stop_button <> 0;
reset_button := mw_reset_button <> 0;
exit_red := mw_exit_red <> 0;
exit_white := mw_exit_white <> 0;
exit_blue := mw_exit_blue <> 0;
debug_mode := mw_debug_mode <> 0;

(* Debug passthrough *)
debug_sensor_red := sensor_red;
debug_sensor_white := sensor_white;
debug_sensor_blue := sensor_blue;
debug_start_btn := start_button;
debug_stop_btn := stop_button;
debug_reset_btn := reset_button;
debug_forced_mode := debug_mode;

clock_counter := clock_counter + 1;
IF clock_counter >= 50 THEN
    clock_counter := 0;
    debug_clock_pulse := NOT debug_clock_pulse;
END_IF;

(* Edge detection *)
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

hmi_start_edge := (hmi_start > 0) AND NOT prev_hmi_start;
hmi_stop_edge := (hmi_stop > 0) AND NOT prev_hmi_stop;
hmi_reset_edge := (hmi_reset > 0) AND NOT prev_hmi_reset;

prev_hmi_start := hmi_start > 0;
prev_hmi_stop := hmi_stop > 0;
prev_hmi_reset := hmi_reset > 0;

IF hmi_start_edge THEN hmi_start := 0; END_IF;
IF hmi_stop_edge THEN hmi_stop := 0; END_IF;
IF hmi_reset_edge THEN hmi_reset := 0; END_IF;

(* Emergency stop *)
IF estop THEN
    system_running := FALSE;
    system_fault := TRUE;
    IF NOT debug_mode THEN
        conveyor_run := FALSE;
        diverter_red := FALSE;
        diverter_white := FALSE;
        diverter_blue := FALSE;
        alarm := TRUE;
    END_IF;
END_IF;

(* Reset *)
IF (reset_edge OR hmi_reset_edge) AND NOT estop THEN
    system_fault := FALSE;
    alarm := FALSE;
    count_red := 0;
    count_white := 0;
    count_blue := 0;
    count_total := 0;
    (* Clear all timing queues *)
    delay_red_1 := 0;
    delay_red_2 := 0;
    delay_red_3 := 0;
    delay_white_1 := 0;
    delay_white_2 := 0;
    delay_white_3 := 0;
    delay_blue_1 := 0;
    delay_blue_2 := 0;
    delay_blue_3 := 0;
    open_red := 0;
    open_white := 0;
    open_blue := 0;
END_IF;

(* Start/Stop *)
IF NOT system_fault THEN
    IF start_edge OR hmi_start_edge THEN
        system_running := TRUE;
    END_IF;
    IF stop_edge OR hmi_stop_edge THEN
        system_running := FALSE;
    END_IF;
END_IF;

(* Calculate timing based on conveyor speed *)
(* Distance: 5 meters from sensor to diverter *)
(* Speed: conveyor_speed/20 m/s *)
(* Delay = 5 / (speed/20) = 100/speed seconds = 10000/speed cycles at 10ms *)
(* Minimum speed of 10 to avoid division issues *)
IF conveyor_speed > 10 THEN
    effective_speed := conveyor_speed;
ELSE
    effective_speed := 50;  (* Default speed *)
END_IF;

(* calc_delay = 10001 / effective_speed *)
(* At speed 50: 10000/50 = 200 cycles = 2 seconds *)
(* At speed 100: 10000/100 = 100 cycles = 1 second *)
calc_delay := 10000 / effective_speed;

(* Open duration: time for block to slide off conveyor onto side chute *)
(* Block needs time to: 1) be pushed by diverter, 2) slide ~1m sideways, 3) clear main belt *)
(* Diverter swing time ~180ms, plus slide time depends on friction *)
(* Using 150 cycle base (1.5 sec) plus block pass time for reliable operation *)
calc_open := (1000 / effective_speed) + 150;

(* Main control *)
IF debug_mode THEN
    (* Debug mode: Don't write outputs - allow external forcing *)
    (* Still decrement timers to maintain state *)
    IF delay_red_1 > 0 THEN delay_red_1 := delay_red_1 - 1; END_IF;
    IF delay_red_2 > 0 THEN delay_red_2 := delay_red_2 - 1; END_IF;
    IF delay_red_3 > 0 THEN delay_red_3 := delay_red_3 - 1; END_IF;
    IF delay_white_1 > 0 THEN delay_white_1 := delay_white_1 - 1; END_IF;
    IF delay_white_2 > 0 THEN delay_white_2 := delay_white_2 - 1; END_IF;
    IF delay_white_3 > 0 THEN delay_white_3 := delay_white_3 - 1; END_IF;
    IF delay_blue_1 > 0 THEN delay_blue_1 := delay_blue_1 - 1; END_IF;
    IF delay_blue_2 > 0 THEN delay_blue_2 := delay_blue_2 - 1; END_IF;
    IF delay_blue_3 > 0 THEN delay_blue_3 := delay_blue_3 - 1; END_IF;
    IF open_red > 0 THEN open_red := open_red - 1; END_IF;
    IF open_white > 0 THEN open_white := open_white - 1; END_IF;
    IF open_blue > 0 THEN open_blue := open_blue - 1; END_IF;

    (* Still count packages *)
    IF red_edge THEN
        count_red := count_red + 1;
        count_total := count_total + 1;
    END_IF;
    IF white_edge THEN
        count_white := count_white + 1;
        count_total := count_total + 1;
    END_IF;
    IF blue_edge THEN
        count_blue := count_blue + 1;
        count_total := count_total + 1;
    END_IF;

ELSE
    (* Normal mode: PLC controls outputs *)
    IF system_running AND NOT system_fault THEN
        (* Conveyor control *)
        IF force_conveyor = 1 THEN
            conveyor_run := TRUE;
        ELSIF force_conveyor = 2 THEN
            conveyor_run := FALSE;
        ELSE
            conveyor_run := TRUE;
        END_IF;

        run_light := conveyor_run;
        ready_light := FALSE;

        IF cmd_speed > 0 AND cmd_speed <= 100 THEN
            conveyor_speed := cmd_speed;
        ELSE
            conveyor_speed := 50;
        END_IF;

        (* RED package detection - queue into delay slots *)
        IF red_edge THEN
            count_red := count_red + 1;
            count_total := count_total + 1;
            (* Find empty slot and start delay countdown *)
            IF delay_red_1 = 0 THEN
                delay_red_1 := calc_delay;
            ELSIF delay_red_2 = 0 THEN
                delay_red_2 := calc_delay;
            ELSIF delay_red_3 = 0 THEN
                delay_red_3 := calc_delay;
            END_IF;
            (* If all slots full, package will be missed - rare case *)
        END_IF;

        (* WHITE package detection *)
        IF white_edge THEN
            count_white := count_white + 1;
            count_total := count_total + 1;
            IF delay_white_1 = 0 THEN
                delay_white_1 := calc_delay;
            ELSIF delay_white_2 = 0 THEN
                delay_white_2 := calc_delay;
            ELSIF delay_white_3 = 0 THEN
                delay_white_3 := calc_delay;
            END_IF;
        END_IF;

        (* BLUE package detection *)
        IF blue_edge THEN
            count_blue := count_blue + 1;
            count_total := count_total + 1;
            IF delay_blue_1 = 0 THEN
                delay_blue_1 := calc_delay;
            ELSIF delay_blue_2 = 0 THEN
                delay_blue_2 := calc_delay;
            ELSIF delay_blue_3 = 0 THEN
                delay_blue_3 := calc_delay;
            END_IF;
        END_IF;

        (* Decrement delay timers and trigger diverter when delay expires *)
        (* RED delays *)
        IF delay_red_1 > 0 THEN
            delay_red_1 := delay_red_1 - 1;
            IF delay_red_1 = 0 THEN
                open_red := open_red + calc_open;  (* Extend open time *)
            END_IF;
        END_IF;
        IF delay_red_2 > 0 THEN
            delay_red_2 := delay_red_2 - 1;
            IF delay_red_2 = 0 THEN
                open_red := open_red + calc_open;
            END_IF;
        END_IF;
        IF delay_red_3 > 0 THEN
            delay_red_3 := delay_red_3 - 1;
            IF delay_red_3 = 0 THEN
                open_red := open_red + calc_open;
            END_IF;
        END_IF;

        (* WHITE delays *)
        IF delay_white_1 > 0 THEN
            delay_white_1 := delay_white_1 - 1;
            IF delay_white_1 = 0 THEN
                open_white := open_white + calc_open;
            END_IF;
        END_IF;
        IF delay_white_2 > 0 THEN
            delay_white_2 := delay_white_2 - 1;
            IF delay_white_2 = 0 THEN
                open_white := open_white + calc_open;
            END_IF;
        END_IF;
        IF delay_white_3 > 0 THEN
            delay_white_3 := delay_white_3 - 1;
            IF delay_white_3 = 0 THEN
                open_white := open_white + calc_open;
            END_IF;
        END_IF;

        (* BLUE delays *)
        IF delay_blue_1 > 0 THEN
            delay_blue_1 := delay_blue_1 - 1;
            IF delay_blue_1 = 0 THEN
                open_blue := open_blue + calc_open;
            END_IF;
        END_IF;
        IF delay_blue_2 > 0 THEN
            delay_blue_2 := delay_blue_2 - 1;
            IF delay_blue_2 = 0 THEN
                open_blue := open_blue + calc_open;
            END_IF;
        END_IF;
        IF delay_blue_3 > 0 THEN
            delay_blue_3 := delay_blue_3 - 1;
            IF delay_blue_3 = 0 THEN
                open_blue := open_blue + calc_open;
            END_IF;
        END_IF;

        (* Decrement open timers *)
        IF open_red > 0 THEN
            open_red := open_red - 1;
        END_IF;
        IF open_white > 0 THEN
            open_white := open_white - 1;
        END_IF;
        IF open_blue > 0 THEN
            open_blue := open_blue - 1;
        END_IF;

        (* Apply diverter outputs with force overrides *)
        IF force_diverter_red = 1 THEN
            diverter_red := TRUE;
        ELSIF force_diverter_red = 2 THEN
            diverter_red := FALSE;
        ELSE
            diverter_red := open_red > 0;
        END_IF;

        IF force_diverter_white = 1 THEN
            diverter_white := TRUE;
        ELSIF force_diverter_white = 2 THEN
            diverter_white := FALSE;
        ELSE
            diverter_white := open_white > 0;
        END_IF;

        IF force_diverter_blue = 1 THEN
            diverter_blue := TRUE;
        ELSIF force_diverter_blue = 2 THEN
            diverter_blue := FALSE;
        ELSE
            diverter_blue := open_blue > 0;
        END_IF;

    ELSE
        (* System stopped or faulted *)
        IF force_conveyor = 1 THEN
            conveyor_run := TRUE;
        ELSIF force_conveyor = 2 THEN
            conveyor_run := FALSE;
        ELSE
            conveyor_run := FALSE;
        END_IF;

        conveyor_speed := 0;

        IF force_diverter_red = 1 THEN
            diverter_red := TRUE;
        ELSE
            diverter_red := FALSE;
        END_IF;

        IF force_diverter_white = 1 THEN
            diverter_white := TRUE;
        ELSE
            diverter_white := FALSE;
        END_IF;

        IF force_diverter_blue = 1 THEN
            diverter_blue := TRUE;
        ELSE
            diverter_blue := FALSE;
        END_IF;

        (* Clear all delays when stopped *)
        delay_red_1 := 0;
        delay_red_2 := 0;
        delay_red_3 := 0;
        delay_white_1 := 0;
        delay_white_2 := 0;
        delay_white_3 := 0;
        delay_blue_1 := 0;
        delay_blue_2 := 0;
        delay_blue_3 := 0;
        open_red := 0;
        open_white := 0;
        open_blue := 0;

        run_light := conveyor_run;

        IF system_fault THEN
            fault_light := TRUE;
            ready_light := FALSE;
        ELSE
            fault_light := FALSE;
            ready_light := TRUE;
        END_IF;
    END_IF;

    (* Alarm control *)
    IF force_alarm = 1 THEN
        alarm := TRUE;
    ELSIF force_alarm = 2 THEN
        alarm := FALSE;
    ELSE
        alarm := system_fault;
    END_IF;
END_IF;

(* Update debug registers for monitoring *)
debug_delay_red := delay_red_1;
debug_delay_white := delay_white_1;
debug_delay_blue := delay_blue_1;

END_PROGRAM


CONFIGURATION Config0
    RESOURCE Res0 ON PLC
        TASK MainTask(INTERVAL := T#10ms, PRIORITY := 0);
        PROGRAM Inst0 WITH MainTask : SortingController;
    END_RESOURCE
END_CONFIGURATION
