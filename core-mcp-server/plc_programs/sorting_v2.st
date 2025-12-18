PROGRAM SortingController
VAR
  sensor_red AT %IX0.0 : BOOL;
  sensor_white AT %IX0.1 : BOOL;
  sensor_blue AT %IX0.2 : BOOL;
  package_present AT %IX0.3 : BOOL;
  estop AT %IX0.4 : BOOL;
  start_button AT %IX0.5 : BOOL;
  stop_button AT %IX0.6 : BOOL;
  reset_button AT %IX0.7 : BOOL;
  conveyor_run AT %QX0.0 : BOOL;
  diverter_red AT %QX0.1 : BOOL;
  diverter_white AT %QX0.2 : BOOL;
  diverter_blue AT %QX0.3 : BOOL;
  alarm AT %QX0.4 : BOOL;
  run_light AT %QX0.5 : BOOL;
  fault_light AT %QX0.6 : BOOL;
  ready_light AT %QX0.7 : BOOL;
  count_red AT %MW0 : INT;
  count_white AT %MW1 : INT;
  count_blue AT %MW2 : INT;
  count_total AT %MW3 : INT;
  conveyor_speed AT %MW4 : INT;
  cmd_speed AT %MW10 : INT;
END_VAR
VAR
  system_running : BOOL;
  system_fault : BOOL;
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
  diverter_timer : INT;
  active_diverter : INT;
END_VAR

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
  conveyor_run := TRUE;
  run_light := TRUE;
  ready_light := FALSE;
  fault_light := FALSE;

  IF cmd_speed > 0 AND cmd_speed <= 100 THEN
    conveyor_speed := cmd_speed;
  ELSE
    conveyor_speed := 50;
  END_IF;

  IF package_present THEN
    IF red_edge THEN
      active_diverter := 1;
      diverter_timer := 10;
      count_red := count_red + 1;
      count_total := count_total + 1;
    ELSIF white_edge THEN
      active_diverter := 2;
      diverter_timer := 10;
      count_white := count_white + 1;
      count_total := count_total + 1;
    ELSIF blue_edge THEN
      active_diverter := 3;
      diverter_timer := 10;
      count_blue := count_blue + 1;
      count_total := count_total + 1;
    END_IF;
  END_IF;

  IF diverter_timer > 0 THEN
    diverter_timer := diverter_timer - 1;
    IF active_diverter = 1 THEN
      diverter_red := TRUE;
      diverter_white := FALSE;
      diverter_blue := FALSE;
    ELSIF active_diverter = 2 THEN
      diverter_red := FALSE;
      diverter_white := TRUE;
      diverter_blue := FALSE;
    ELSIF active_diverter = 3 THEN
      diverter_red := FALSE;
      diverter_white := FALSE;
      diverter_blue := TRUE;
    END_IF;
  ELSE
    active_diverter := 0;
    diverter_red := FALSE;
    diverter_white := FALSE;
    diverter_blue := FALSE;
  END_IF;

ELSE
  conveyor_run := FALSE;
  conveyor_speed := 0;
  diverter_red := FALSE;
  diverter_white := FALSE;
  diverter_blue := FALSE;
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

END_PROGRAM


CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK MainTask(INTERVAL := T#10ms, PRIORITY := 0);
    PROGRAM Inst0 WITH MainTask : SortingController;
  END_RESOURCE
END_CONFIGURATION
