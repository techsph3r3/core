#!/bin/bash
#CybatiWorks-1 Blackbox Firewall Configuration Viewer
CybatiWorks_Firewall=$(zenity  --list  --title="CybatiWorks Blackbox Firewall Configuration" --text "Select the CybatiWorks Blackbox firewall configuration to review." --radiolist  --column "Select" --column "CybatiWorks-1 Firewall" TRUE "Industrial Control Network (n6)" FALSE "Corporate Network (n8)" --height=200)
if [ -n "$CybatiWorks_Firewall" ];
then
   pkill fwbuilder
   if [ "$CybatiWorks_Firewall" = "Industrial Control Network (n6)" ]
   then
       fwbuilder -f /opt/CybatiWorks/Labs/blackbox/Blackbox_Industrial_FW.fwb
   fi
   if [ "$CybatiWorks_Firewall" = "Corporate Network (n8)" ]
   then
       fwbuilder -f /opt/CybatiWorks/Labs/blackbox/Blackbox_Border_FW.fwb
   fi
fi
