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
 * TIMING CONFIGURATION:
 * The variables below allow tuning the physics model directly.
 * Distance_Factor = (Distance_Meters * 1000) / (Belt_Update_Interval / 20)
 * Default used 10000 for 5m.
 *)

PROGRAM SortingController
VAR
    (* INPUTS *)
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
    (* OUTPUTS *)
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
    (* DATA *)
    count_red AT %MW0 : INT;
    count_white AT %MW1 : INT;
    count_blue AT %MW2 : INT;
    count_total AT %MW3 : INT;
    conveyor_speed AT %MW4 : INT;
    cmd_speed AT %MW10 : INT;
    (* HMI *)
    hmi_start AT %MW20 : INT;
    hmi_stop AT %MW21 : INT;
    hmi_feed AT %MW22 : INT;
    hmi_reset AT %MW23 : INT;
    (* FORCES *)
    force_conveyor AT %MW112 : INT;
    force_alarm AT %MW113 : INT;
    force_diverter_red AT %MW114 : INT;
    force_diverter_white AT %MW115 : INT;
    force_diverter_blue AT %MW116 : INT;
    (* DEBUG TIMING *)
    debug_delay_red AT %MW117 : INT;
    debug_delay_white AT %MW118 : INT;
    debug_delay_blue AT %MW119 : INT;
END_VAR

VAR
    (* ============================================= *)
    (*          CONFIGURATION (TUNABLE)              *)
    (* ============================================= *)
    (* Factor correlating Distance to Time based on Speed *)
    (* Formula: Delay_Cycles = Config_Distance_Factor / Speed *)
    (* Default: 10000 for 5m distance *)
    Config_Distance_Red : INT := 10000;
    Config_Distance_White : INT := 10000;
    Config_Distance_Blue : INT := 10000;

    (* Diverter Open Offset (to account for swing time) *)
    Config_Open_Offset : INT := 150;
    (* ============================================= *)

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
    system_running : BOOL;
    system_fault : BOOL;
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

    delay_red_1 : INT; delay_red_2 : INT; delay_red_3 : INT; open_red : INT;
    delay_white_1 : INT; delay_white_2 : INT; delay_white_3 : INT; open_white : INT;
    delay_blue_1 : INT; delay_blue_2 : INT; delay_blue_3 : INT; open_blue : INT;

    calc_delay : INT;
    calc_open : INT;
    effective_speed : INT;
END_VAR

(* Logic Start *)
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

IF (reset_edge OR hmi_reset_edge) AND NOT estop THEN
    system_fault := FALSE;
    alarm := FALSE;
    count_red := 0;
    count_white := 0;
    count_blue := 0;
    count_total := 0;
    delay_red_1 := 0; delay_red_2 := 0; delay_red_3 := 0;
    delay_white_1 := 0; delay_white_2 := 0; delay_white_3 := 0;
    delay_blue_1 := 0; delay_blue_2 := 0; delay_blue_3 := 0;
    open_red := 0; open_white := 0; open_blue := 0;
END_IF;

IF NOT system_fault THEN
    IF start_edge OR hmi_start_edge THEN system_running := TRUE; END_IF;
    IF stop_edge OR hmi_stop_edge THEN system_running := FALSE; END_IF;
END_IF;

IF conveyor_speed > 10 THEN
    effective_speed := conveyor_speed;
ELSE
    effective_speed := 50;
END_IF;

(* Use Tunable Parameter for Open Duration *)
calc_open := (1000 / effective_speed) + Config_Open_Offset;

IF debug_mode THEN
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
    
    IF red_edge THEN count_red := count_red + 1; count_total := count_total + 1; END_IF;
    IF white_edge THEN count_white := count_white + 1; count_total := count_total + 1; END_IF;
    IF blue_edge THEN count_blue := count_blue + 1; count_total := count_total + 1; END_IF;

ELSE
    IF system_running AND NOT system_fault THEN
        IF force_conveyor = 1 THEN conveyor_run := TRUE; ELSIF force_conveyor = 2 THEN conveyor_run := FALSE; ELSE conveyor_run := TRUE; END_IF;
        run_light := conveyor_run;
        ready_light := FALSE;

        IF cmd_speed > 0 AND cmd_speed <= 100 THEN conveyor_speed := cmd_speed; ELSE conveyor_speed := 50; END_IF;

        (* RED Logic *)
        IF red_edge THEN
            count_red := count_red + 1; count_total := count_total + 1;
            calc_delay := Config_Distance_Red / effective_speed; (* Use Tunable Distance *)
            IF delay_red_1 = 0 THEN delay_red_1 := calc_delay;
            ELSIF delay_red_2 = 0 THEN delay_red_2 := calc_delay;
            ELSIF delay_red_3 = 0 THEN delay_red_3 := calc_delay;
            END_IF;
        END_IF;

        (* WHITE Logic *)
        IF white_edge THEN
            count_white := count_white + 1; count_total := count_total + 1;
            calc_delay := Config_Distance_White / effective_speed;
            IF delay_white_1 = 0 THEN delay_white_1 := calc_delay;
            ELSIF delay_white_2 = 0 THEN delay_white_2 := calc_delay;
            ELSIF delay_white_3 = 0 THEN delay_white_3 := calc_delay;
            END_IF;
        END_IF;

        (* BLUE Logic *)
        IF blue_edge THEN
            count_blue := count_blue + 1; count_total := count_total + 1;
            calc_delay := Config_Distance_Blue / effective_speed;
            IF delay_blue_1 = 0 THEN delay_blue_1 := calc_delay;
            ELSIF delay_blue_2 = 0 THEN delay_blue_2 := calc_delay;
            ELSIF delay_blue_3 = 0 THEN delay_blue_3 := calc_delay;
            END_IF;
        END_IF;

        (* Timers *)
        IF delay_red_1 > 0 THEN delay_red_1 := delay_red_1 - 1; IF delay_red_1 = 0 THEN open_red := open_red + calc_open; END_IF; END_IF;
        IF delay_red_2 > 0 THEN delay_red_2 := delay_red_2 - 1; IF delay_red_2 = 0 THEN open_red := open_red + calc_open; END_IF; END_IF;
        IF delay_red_3 > 0 THEN delay_red_3 := delay_red_3 - 1; IF delay_red_3 = 0 THEN open_red := open_red + calc_open; END_IF; END_IF;

        IF delay_white_1 > 0 THEN delay_white_1 := delay_white_1 - 1; IF delay_white_1 = 0 THEN open_white := open_white + calc_open; END_IF; END_IF;
        IF delay_white_2 > 0 THEN delay_white_2 := delay_white_2 - 1; IF delay_white_2 = 0 THEN open_white := open_white + calc_open; END_IF; END_IF;
        IF delay_white_3 > 0 THEN delay_white_3 := delay_white_3 - 1; IF delay_white_3 = 0 THEN open_white := open_white + calc_open; END_IF; END_IF;

        IF delay_blue_1 > 0 THEN delay_blue_1 := delay_blue_1 - 1; IF delay_blue_1 = 0 THEN open_blue := open_blue + calc_open; END_IF; END_IF;
        IF delay_blue_2 > 0 THEN delay_blue_2 := delay_blue_2 - 1; IF delay_blue_2 = 0 THEN open_blue := open_blue + calc_open; END_IF; END_IF;
        IF delay_blue_3 > 0 THEN delay_blue_3 := delay_blue_3 - 1; IF delay_blue_3 = 0 THEN open_blue := open_blue + calc_open; END_IF; END_IF;

        IF open_red > 0 THEN open_red := open_red - 1; END_IF;
        IF open_white > 0 THEN open_white := open_white - 1; END_IF;
        IF open_blue > 0 THEN open_blue := open_blue - 1; END_IF;

        (* Output Mapping with Forces *)
        IF force_diverter_red = 1 THEN diverter_red := TRUE; ELSIF force_diverter_red = 2 THEN diverter_red := FALSE; ELSE diverter_red := open_red > 0; END_IF;
        IF force_diverter_white = 1 THEN diverter_white := TRUE; ELSIF force_diverter_white = 2 THEN diverter_white := FALSE; ELSE diverter_white := open_white > 0; END_IF;
        IF force_diverter_blue = 1 THEN diverter_blue := TRUE; ELSIF force_diverter_blue = 2 THEN diverter_blue := FALSE; ELSE diverter_blue := open_blue > 0; END_IF;

    ELSE
        (* Stopped/Faulted Logic *)
        IF force_conveyor = 1 THEN conveyor_run := TRUE; ELSIF force_conveyor = 2 THEN conveyor_run := FALSE; ELSE conveyor_run := FALSE; END_IF;
        conveyor_speed := 0;
        IF force_diverter_red = 1 THEN diverter_red := TRUE; ELSE diverter_red := FALSE; END_IF;
        IF force_diverter_white = 1 THEN diverter_white := TRUE; ELSE diverter_white := FALSE; END_IF;
        IF force_diverter_blue = 1 THEN diverter_blue := TRUE; ELSE diverter_blue := FALSE; END_IF;

        delay_red_1 := 0; delay_red_2 := 0; delay_red_3 := 0;
        delay_white_1 := 0; delay_white_2 := 0; delay_white_3 := 0;
        delay_blue_1 := 0; delay_blue_2 := 0; delay_blue_3 := 0;
        open_red := 0; open_white := 0; open_blue := 0;

        run_light := conveyor_run;
        IF system_fault THEN fault_light := TRUE; ready_light := FALSE; ELSE fault_light := FALSE; ready_light := TRUE; END_IF;
    END_IF;

    IF force_alarm = 1 THEN alarm := TRUE; ELSIF force_alarm = 2 THEN alarm := FALSE; ELSE alarm := system_fault; END_IF;
END_IF;

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
