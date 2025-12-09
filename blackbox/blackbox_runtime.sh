#!/bin/bash
#CybatiWorks-1 Community Edition Quick ICS
MINIKIT_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep b.26.)
SUBNET=172.16.192
HOST=50
sleep 1 && wmctrl -r "Progress Status" -b add,above &
(
   echo "10"
   echo "# Building blackbox network and hosts."; sleep 1
   ifconfig eth0 0
   echo "20"
   echo "# Inserting the CybatiWorks host in to the blackbox."; sleep 2
   ifconfig $MINIKIT_INTERFACE up $SUBNET.$HOST/24
   route add default gw $SUBNET.1
   CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
#   netstat -tlnp | awk '/:502 */ {split($NF,a,"/"); print a[1]}' | xargs kill
   echo "30"
   echo "# Enabling and configuring additional Blackbox services"; sleep 2
   vcmd -c /tmp/pycore.$CORE_SESSION/n13 -- conpot --template default &
   vcmd -c /tmp/pycore.$CORE_SESSION/n22 -- /opt/CybatiWorks/Labs/blackbox/datastreams/smbclient.sh.x &
   vcmd -c /tmp/pycore.$CORE_SESSION/n16 -- chmod a-w var.ftp
   vcmd -c /tmp/pycore.$CORE_SESSION/n16 -- chmod a-w var.run.vsftpd.empty
   vcmd -c /tmp/pycore.$CORE_SESSION/n21 -- /opt/CybatiWorks/Labs/blackbox/datastreams/ftp.sh.x &
   vcmd -c /tmp/pycore.$CORE_SESSION/n38 -- /opt/CybatiWorks/Labs/blackbox/datastreams/http.sh.x &
   cp /var/ftp/* /tmp/pycore.$CORE_SESSION/n16.conf/var.ftp/
   cp /var/ftp/* /tmp/pycore.$CORE_SESSION/n37.conf/var.www/
   /opt/CybatiWorks/Labs/blackbox/datastreams/voip.sh.x &
   /opt/CybatiWorks/Labs/blackbox/datastreams/modbus_server.sh.x &
   echo "35"
   echo "# Waiting for all services to start and routing protocol convergence.\nConvergence requires approximately 50 seconds."; sleep 1
   while ! ping -c1 10.0.10.1 &>/dev/null; do :; done
   sleep 1;
#   vcmd -c /tmp/pycore.$CORE_SESSION/n25 -- /opt/CybatiWorks/Labs/blackbox/datastreams/modbus_test.sh.x &
   echo "80"
   echo "# Installing Corporate firewall policies."; sleep 2
   vcmd -c /tmp/pycore.$CORE_SESSION/n8 -- /opt/CybatiWorks/Labs/blackbox/Blackbox_Border_FW.fw
   echo "80"
   echo "# Installing Industrial firewall policies."; sleep 2
   vcmd -c /tmp/pycore.$CORE_SESSION/n6 -- /opt/CybatiWorks/Labs/blackbox/Blackbox_Industrial_FW.fw
   echo "90"
   echo "# Industrial and Corporate firewall policies installed."; sleep 2
   echo "100"
   echo "# CybatiWorks Blackbox design complete."; sleep 1
) |
zenity --progress \
--title="Initializing the CybatiWorks Blackbox" \
--text="First Task." \
--percentage=0 \
--auto-close \
--auto-kill
zenity --info --text "CybatiWorks Blackbox design is complete. Time to discover!\n\nThe CybatiWorks host is now located at IP address $SUBNET.$HOST/24 on $MINIKIT_INTERFACE with a default gateway of $SUBNET.1\nGood luck!" --no-wrap
#gnome-terminal --command "ifconfig $MINIKIT_INTERFACE" --working-directory=/root
#sleep 2
#xdotool search --name=blackbox windowactivate
#xdotool type 'ifconfig'
#xdotool key space
#xdotool type $MINIKIT_INTERFACE
#xdotool key 'Return'
#xdotool type 'route -n'
#xdotool key 'Return'
