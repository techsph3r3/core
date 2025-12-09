#!/bin/bash
#CybatiWorks-1 Modbus Traffic Generator
while true
do
        modbus read --modicon 10.0.0.30 400001 4
	sleep 5
done
