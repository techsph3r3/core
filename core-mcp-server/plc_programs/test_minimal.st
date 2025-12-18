PROGRAM test_prog
VAR
  button1 AT %IX0.0 : BOOL;
  led1 AT %QX0.0 : BOOL;
  counter AT %MW0 : INT;
END_VAR

led1 := button1;
IF button1 THEN
  counter := counter + 1;
END_IF;

END_PROGRAM


CONFIGURATION Config0
  RESOURCE Res0 ON PLC
    TASK Main(INTERVAL := T#50ms, PRIORITY := 0);
    PROGRAM Inst0 WITH Main : test_prog;
  END_RESOURCE
END_CONFIGURATION
