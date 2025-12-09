#!/bin/sh
#CybatiWorks-1
#Launch CybatiWorks CORE
#ethtool -i eth0 | grep AX8877 > /dev/null 2>&1
#if [ $? -eq 0 ] ; then
zenity --info --text "Starting the CybatiWorks BlackBox Environment.\nThanks for participating in our course, or for more information sign up for a CYBATI course at https://cybati.org/." --no-wrap
topo=$(zenity  --list  --title="CybatiWorks Blackbox Topology View" --text "Select to hide or view the Blackbox network diagram." --radiolist  --column "Select" --column "View CybatiWorks Blackbox Network Diagram" FALSE "No - Moderate/Experienced"  TRUE "Yes - Beginner" --width=500 --height=200)
sleep 1 && wmctrl -r "Progress Status" -b add,above &
(
echo "10"
echo "# Resetting CybatiWorks BlackBox services."; sleep 1
/usr/local/sbin/core-cleanup
pkill wish8.5
/etc/init.d/core-daemon restart
echo "40"
echo "# Resetting CybatiWorks network settings."; sleep 1
ifconfig eth0 0
echo "60"
echo "# Initializing vlan configuration."; sleep 1
/opt/CybatiWorks/Labs/sg200/vlans_add.sh
echo "80"
echo "# Launching CybatiWorks software defined network."; sleep 1
echo "100"
echo "# Starting CybatiWorks BlackBox Initialization."; sleep 1
) |
zenity --progress \
--title="CybatiWorks Blackbox Wizard" \
--text="First Task." \
--percentage=0 \
--auto-close \
--auto-kill
zenity --info --text "The CybatiWorks Blackbox will now initialize the environment.\nDo not touch anything until prompted." --no-wrap
if [ "$topo" = "No - Moderate/Experienced" ]; then
  core-gui "--batch /usr/local/src/c/y/b/a/t/i/w/o/r/k/s/b/l/a/c/k/b/o/x/blackbox_network.imn" &
fi
if [ "$topo" = "Yes - Beginner" ]; then
  core-gui "--start /usr/local/src/c/y/b/a/t/i/w/o/r/k/s/b/l/a/c/k/b/o/x/blackbox_network.imn" &
fi
#else
#   zenity --info --text "The CybatiWorks Mini Kit can not be found connected to this system.\nPlease rerun the CybatiWorks-1 Set IP Address script to identify the solution." --no-wrap
#fi
