#!/bin/sh
#CybatiWorks-1
#Launch Blackbox RexDraw Engineering WS
zenity --info --text "Power off and power on the CybatiWorks Mini Kit to place it within the Blackbox.\nClick OK to continue." --no-wrap
if [ $? -eq 0 ] ; then
   sleep 1 && wmctrl -r "Progress Status" -b add,above &
   (
   echo "5"
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
   xdotool key Shift F
   xdotool key Down
   xdotool key Return
   xdotool key Shift M
   xdotool key Return
   xdotool key Shift E
   xdotool key Return
   sleep 4
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
   echo "80"
   echo "# Stopping RexDraw engineering application."; sleep 1
   pkill RexDraw.exe
   CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
   sleep 1
   vcmd -c /tmp/pycore.$CORE_SESSION/n12 -- /opt/CybatiWorks/Labs/blackbox/datastreams/modbus.sh.x &
   echo "90"
   echo "# Enabled remote monitoring."; sleep 1
   echo "100"
   echo "# CybatiWorks Basic HMI/PLC system setup complete."; sleep 1
   ) |
   zenity --progress \
   --title="CybatiWorks Basic HMI/PLC Wizard" \
   --text="First Task." \
   --percentage=0 \
   --auto-close \
   --auto-kill
   zenity --info --text "The CybatiWorks-1 Mini Kit is now integrated in to the Blackbox.\n" --no-wrap
else
   zenity --info --text "Connection to Raspberry PI unsuccessful.\nStop the Blackbox and attempt to use the CybatiWorks-1 Set IP Address shortcut.\n" --no-wrap
fi
