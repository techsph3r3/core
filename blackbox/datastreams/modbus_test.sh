#!/bin/bash
#CybatiWorks-1 Internet Modbus Server Test Traffic Generator
while true
do
        sleep 30
        modbus read -w -p 53 73.9.13.10 37337 5
	sleep 30
done
