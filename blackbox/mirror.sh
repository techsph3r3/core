#!/bin/bash
#CybatiWorks-1 Blackbox Port Mirroring (ie. Switch acts like a Hub)
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
zenity --info --text "Passive network analysis using a SPAN, TAP or MIRRORED switch/bridge port or HUB connection provides host to host communication visualization.\nEstablishing tap points MAY impact older CPU and switch backplane data rates and should be tested before performing in an Industrial facility.\nAn intentional discussion should be made whether your organization should use external taps or internal switch spans/mirroring.\n\nThis wizard will establish a TAP point by reconfiguring local switches.\nThe wizard then launches wireshark within the selected zone." --no-wrap
CybatiWorks_Location=$(zenity  --list  --title="Setting CybatiWorks TAP point" --text "Select the CybatiWorks-1 node map location (if unsure, leave defaults)." --radiolist  --column "Select" --column "CybatiWorks-1 Type" TRUE "Industrial Control Network (n26)" FALSE "Corporate Network Hosts (n27)" FALSE "Corporate Network Core (n28)" FALSE "Internet (n29)" --height=250)
if [ -n "$CybatiWorks_Location" ];
then
   if [ "$CybatiWorks_Location" = "Industrial Control Network (n26)" ]
   then
      bridge=b.1.
      SUBNET=172.16.192
      HOST=50
      cw_hub=b.26.
      disable_hub1=b.27.
      disable_hub2=b.28.
      disable_hub3=b.29.
      Disable_Mirror1=b.2.
      Disable_Mirror2=b.3.
      Disable_Mirror3=b.4.
   fi
   if [ "$CybatiWorks_Location" = "Corporate Network Core (n28)" ]
   then
      bridge=b.2.
      SUBNET=10.0.10
      HOST=50
      cw_hub=b.28.
      disable_hub1=b.26.
      disable_hub2=b.27.
      disable_hub3=b.29.
      Disable_Mirror1=b.1.
      Disable_Mirror2=b.3.
      Disable_Mirror3=b.4.
   fi
   if [ "$CybatiWorks_Location" = "Corporate Network Hosts (n27)" ]
   then
      bridge=b.3.
      SUBNET=10.0.11
      HOST=50
      cw_hub=b.27.
      disable_hub1=b.26.
      disable_hub2=b.28.
      disable_hub3=b.29.
      Disable_Mirror1=b.1.
      Disable_Mirror2=b.2.
      Disable_Mirror3=b.4.
   fi
   if [ "$CybatiWorks_Location" = "Internet (n29)" ]
   then
      bridge=b.4.
      SUBNET=73.9.9
      HOST=50
      cw_hub=b.29.
      disable_hub1=b.26.
      disable_hub2=b.27.
      disable_hub3=b.28.
      Disable_Mirror1=b.1.
      Disable_Mirror2=b.2.
      Disable_Mirror3=b.3.
   fi
   pkill wireshark
   CYBATIWORKS_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $cw_hub)
   hub1_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub1) 
   hub2_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub2)
   hub3_INTERFACE=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $disable_hub3)
   ifconfig $hub1_INTERFACE 0
   ifconfig $hub2_INTERFACE 0
   ifconfig $hub3_INTERFACE 0
   ifconfig $CYBATIWORKS_INTERFACE up $SUBNET.$HOST/24
   route add default gw $SUBNET.1
   MIRRORING_SWITCH=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $bridge)
   Disable_MIRRORING_SWITCH1=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $Disable_Mirror1)
   Disable_MIRRORING_SWITCH2=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $Disable_Mirror2)
   Disable_MIRRORING_SWITCH3=$(brctl show | grep -v "bridge name" | awk "/^[^\\t]/ { print \$1 }" | fgrep $Disable_Mirror3)
   brctl setageing $Disable_MIRRORING_SWITCH1 300
   brctl setageing $Disable_MIRRORING_SWITCH2 300
   brctl setageing $Disable_MIRRORING_SWITCH3 300
   brctl setageing $MIRRORING_SWITCH 0
   wireshark -i $CYBATIWORKS_INTERFACE -k &
   sleep 3
   zenity --info --text "The CybatiWorks host is now located at IP address $SUBNET.$HOST.\n\nPort mirroring is enabled on bridging device $MIRRORING_SWITCH in the\n$CybatiWorks_Location using setageing time of zero.\n\nThis mirroring configuration alters the bridge to act like a hub.\n\nYou may use the Wireshark menu option of Statistics | Conversations to quickly view active communications streams." --no-wrap
fi
