#!/bin/bash
#CybatiWorks-1 VirtuaPlant
sleep 1 && wmctrl -r "Progress Status" -b add,above &
(
   CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
   echo "33"
   echo "# Starting the Bottle Filling process on n5."; sleep 1
   vcmd -c /tmp/pycore.$CORE_SESSION/n5 -- /opt/CybatiWorks/Labs/blackbox/bottle-filling/world.py &
   sleep 3
   vcmd -c /tmp/pycore.$CORE_SESSION/n5 -- /opt/CybatiWorks/Labs/blackbox/bottle-filling/world.py &
   sleep 1
   echo "66"
   echo "# Starting the CybatiWorks HMI on n12."; sleep 1
   vcmd -i -c /tmp/pycore.$CORE_SESSION/n12 /opt/CybatiWorks/Labs/blackbox/bottle-filling/hmi.py &
   sleep 1
   echo "80"
   echo "# Starting the CybatiWorks VirtuaPlant process."; sleep 1
   vcmd -c /tmp/pycore.$CORE_SESSION/n12 /opt/CybatiWorks/Labs/blackbox/bottle-filling/run.py &
   echo "100"
   echo "# CybatiWorks VirtuaPlant system setup complete."; sleep 1
   ) |
   zenity --progress \
   --title="CybatiWorks VirtuaPlant Wizard" \
   --text="First Task." \
   --percentage=0 \
   --auto-close \
   --auto-kill
zenity --info --text "Your virtual bottling facility has been added to the Blackbox.\nFor more information sign-up for a CybatiWorks-1 course at https://cybati.org/." --no-wrap
