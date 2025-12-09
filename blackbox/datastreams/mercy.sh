#!/bin/bash
#CybatiWorks-1 MERCY
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
ans=$(zenity  --width=350 --height=250 --list  --title="CybatiWorks Attack MERCY" --text "Select MERCY." --radiolist  --column "Select" --column "Attack" TRUE "I GIVE UP" FALSE "PLEASE ATTACK ME AGAIN")
if [ $? -eq 0 ] ; then 
   if [ "$ans" = "I GIVE UP" ]
   then
        vcmd -c /tmp/pycore.$CORE_SESSION/n17 -- /opt/CybatiWorks/Labs/blackbox/datastreams/monitor.sh.x &
        sleep 2
        vcmd -c /tmp/pycore.$CORE_SESSION/n25 -- /opt/CybatiWorks/Labs/blackbox/datastrems/attack_minikit.pyc &
   elif [ "$ans" = "PLEASE ATTACK ME AGAIN" ]
   then
        vcmd -c /tmp/pycore.$CORE_SESSION/n25 -- pkill -9 attack &
        vcmd -c /tmp/pycore.$CORE_SESSION/n17 -- pkill -9 nc
   fi
else
   zenity --error --width="400" --title "MERCY CANCELED." --text="User Stopped."
fi
