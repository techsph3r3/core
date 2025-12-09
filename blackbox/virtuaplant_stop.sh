#!/bin/bash
#CybatiWorks-1 VirtuaPlant Stop
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
vcmd -c /tmp/pycore.$CORE_SESSION/n5 -- pkill -9 -f world &
vcmd -c /tmp/pycore.$CORE_SESSION/n12 -- pkill -9 -f hmi &
zenity --info --text "VirtuaPlant is now removed from the Blackbox." --no-wrap
