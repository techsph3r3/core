#!/bin/bash
#CybatiWorks-1 VirtuaPlant Attack Logic
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
#from=$(zenity  --width=350 --height=250 --list  --title="CybatiWorks Bottling VirtuaPlant Attack Logic" --text "Select the attack source." --radiolist  --column "Select" --column "Attack" TRUE "n1" FALSE "n10" FALSE "n9" FALSE "n5")
ans=$(zenity  --width=350 --height=250 --list  --title="CybatiWorks Bottling VirtuaPlant Attack Logic" --text "Select the sample attack." --radiolist  --column "Select" --column "Attack" TRUE "Move and Fill" FALSE "Never Stop" FALSE "Stop All" FALSE "Stop and Fill")
if [ $? -eq 0 ] ; then 
   if [ "$ans" = "Move and Fill" ]
   then
        script=move_and_fill.pyc
   elif [ "$ans" = "Never Stop" ]
   then
        script=never_stop.pyc
   elif [ "$ans" = "Stop All" ]
   then
        script=stop_all.pyc
   elif [ "$ans" = "Stop and Fill" ]
   then
        script=stop_and_fill.pyc
   fi
   vcmd -c /tmp/pycore.$CORE_SESSION/n40 /opt/CybatiWorks/Labs/blackbox/bottle-filling/attacks/attack_$script
else
   zenity --error --width="400" --title "Stopping the Attacks." --text="User Stopped."
   vcmd -c /tmp/pycore.$CORE_SESSION/n40 pkill attack &
fi
