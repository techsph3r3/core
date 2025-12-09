#!/bin/sh
#CybatiWorks-1
#Launch CybatiWorks CORE
sleep 1 && wmctrl -r "Progress Status" -b add,above &
(
   echo "10"
   echo "# Shutting down the CybatiWorks-1 Blackbox IT/ICS network."; sleep 1
   pkill RexDraw
   /usr/local/sbin/core-cleanup
   echo "25"
   echo "# Deleting VLAN architecture and reassociating Mini Kit."; sleep 1
   /opt/CybatiWorks/Labs/sg200/vlans_delete.sh
   ifconfig eth0 172.16.192.10/24
   echo "50"
   echo "# Stopping all running Blackbox processes."; sleep 1
   pkill wish8.5
   pkill wireshark
   pkill timer.pyc
   service core-daemon stop
   echo "75"
   echo "# Confirming Blackbox removal."; sleep 1
   netstat -tlnp | awk '/:4038 */ {split($NF,a,"/"); print a[1]}' | xargs kill
   echo "100"
   echo "# CybatiWorks Blackbox shutdown complete."; sleep 1
) |
zenity --progress \
--title="CybatiWorks Blackbox Wizard" \
--text="First Task." \
--percentage=0 \
--auto-close \
--auto-kill

zenity --info --text "The CybatiWorks Blackbox environment has been stopped.\n" --no-wrap
