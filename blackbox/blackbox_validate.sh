#!/bin/sh
#CybatiWorks-1
#Launch CybatiWorks CORE
#ethtool -i eth0 | grep AX8877 > /dev/null 2>&1
#if [ $? -eq 0 ] ; then
zenity --info --text "Starting the CybatiWorks BlackBox Environment."
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
core-gui "/usr/local/src/c/y/b/a/t/i/w/o/r/k/s/b/l/a/c/k/b/o/x/blackbox_network.imn" &
#else
#   zenity --info --text "The CybatiWorks Mini Kit can not be found connected to this system.\nPlease rerun the CybatiWorks-1 Set IP Address script to identify the solution." --no-wrap
#fi
