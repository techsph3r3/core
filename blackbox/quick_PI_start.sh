#!/bin/sh
#CybatiWorks-1
#Launch Blackbox RexDraw Engineering WS
zenity --info --text "Power off and power on the CybatiWorks Mini Kit to place it within the Blackbox.\nClick OK to continue." --no-wrap
if [ $? -eq 0 ] ; then
   sleep 1 && wmctrl -r "Progress Status" -b add,above &
   (
   echo "5"
   echo "# Reassociating the CybatiWorks-1 Host VM."; sleep 1
   CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
   SUBNET=172.16.192
   HOST=50
   cw_hub=b.26.
   disable_hub1=b.27.
   disable_hub2=b.28.
   disable_hub3=b.29.
   CYBATIWORKS_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $cw_hub)
   hub1_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub1) 
   hub2_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub2)
   hub3_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub3)
   ifconfig eth0 0
   ifconfig $hub1_INTERFACE 0
   ifconfig $hub2_INTERFACE 0
   ifconfig $hub3_INTERFACE 0
   ifconfig $CYBATIWORKS_INTERFACE up $SUBNET.$HOST/24
   route add default gw $SUBNET.1
   echo "8"
   echo "# Waiting for the CybatiWorks Mini Kit controller to become accessible."; sleep 1
   while ! ping -c1 10.0.0.30 </dev/null; do
     sleep 2;
     echo "# Waiting to connect to the CybatiWorks Mini Kit controller."
   done
   echo "10"
   echo "# Restarting REXCore services on the Raspberry PI."; sleep 1
   plink -ssh -pw cybati pi@10.0.0.30 sudo service rexcore stop
   sleep 1
   plink -ssh -pw cybati pi@10.0.0.30 sudo service rexcore start
   echo "20"
   echo "# Resetting services in the CybatiWorks VM."; sleep 1
   pkill RexDraw.exe
   while ! nc -q 1 10.0.0.30 43981 </dev/null; do
     sleep 2;
     echo "# Waiting to connect to REXCORE service on Raspberry PI."
   done
   echo "30"
   echo "# Starting and loading project files in to RexDraw."; sleep 1
   env WINEPREFIX="/root/.wine" wine C:\\windows\\command\\start.exe /Unix /root/.wine/dosdevices/c:/users/Public/Start\ Menu/Programs/REX\ Controls/REX_2_10_7_5386_x86\ \(Active\)/RexDraw\ 2.10.7.lnk
   sleep 2
   xdotool key alt+f
   xdotool key O
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key C
   xdotool key C
   xdotool key Tab
   xdotool key Shift L
   xdotool key Return
   xdotool key Shift B
   xdotool key Down
   xdotool key Down
   xdotool key Return
   xdotool key Shift A
   xdotool key Return
   xdotool key Shift E
   xdotool key Return
   xdotool key Down
   xdotool key Return
   echo "70"
   echo "# Project file found and opened. Time to compile and download."; sleep 4
   xdotool key F6
   sleep 3
   xdotool type "10.0.0.30"
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Tab
   xdotool key Return
   sleep 1
   xdotool key Return
   sleep 1
   echo "90"
   echo "# Stopping RexDraw engineering application."; sleep 1
   pkill RexDraw.exe
   echo "95"
   echo "# Starting attack sequence.  Elements will begin soon.  You have 25 minutes.  Maintain a log book of your actions."; sleep 5
   vcmd -c /tmp/pycore.$CORE_SESSION/n38 -- /opt/CybatiWorks/Labs/blackbox/datastreams/data.sh.x &
   sleep 2
   vcmd -c /tmp/pycore.$CORE_SESSION/n17 -- /opt/CybatiWorks/Labs/blackbox/datastreams/monitor.sh.x &
   sleep 2
   vcmd -c /tmp/pycore.$CORE_SESSION/n25 -- /opt/CybatiWorks/Labs/blackbox/datastreams/attack_minikit.pyc &
   /opt/CybatiWorks/Labs/blackbox/timer.pyc &
   echo "100"
   echo "# CybatiWorks Traffic Light system setup complete. Elements will begin soon.  You have approximately 1500 seconds.\n\nMaintain a log book of your actions."; sleep 1
   ) |
   zenity --progress \
   --title="CybatiWorks Traffic Light Wizard" \
   --text="First Task." \
   --percentage=0 \
   --auto-close \
   --auto-kill
   zenity --info --text "The CybatiWorks-1 Mini Kit is now integrated in to the Blackbox.\n\nYou have approximately 1500 seconds.\nSome elements begin soon. Remember to maintain a log book of your actions." --no-wrap
else
   zenity --info --text "Connection to Raspberry PI unsuccessful. Stop the Blackbox and attempt to use the CybatiWorks-1 Set IP Address shortcut."
fi
