#!/bin/sh
#
# Shell script for start/stop/restart a Wireless AP.
# 10-16-2007 by William
#

# Local IP information
#
DEVICE_WIRELESS=ath0
DEVICE_WIRE=ixp1
DEVICE_BRIDGE=br0
IPADDR=192.168.127.250
NETMASK=255.255.255.0
BROADCAST=192.168.127.255
GATEWAY=192.168.127.254
#HWMAC=00:90:e8:e9:ea:01

# Wireless configurations
ESSID="MOXA-IW-SW"
# MODE= 
# 0 -> autoselect from 1a/b/g,
# 1 -> lock operation to 11a only
# 2 -> lock operation to 11b only
# 3 -> lock operation to 11g only
MODE=3
CHANNEL=2
WEP=

startAP() {
echo  -n "Bringing up Wireless AP..."
wlanconfig $DEVICE_WIRELESS create wlandev wifi0 wlanmode ap
ifconfig $DEVICE_WIRELESS 0.0.0.0 up
iwpriv $DEVICE_WIRELESS mode $MODE
[ $WEP ] && iwconfig $DEVICE_WIRELESS key $WEP
iwconfig $DEVICE_WIRELESS essid $ESSID
iwconfig $DEVICE_WIRELESS channel $CHANNEL
ifconfig $DEVICE_WIRE 0.0.0.0 hw ether `ifconfig $DEVICE_WIRELESS | grep $DEVICE_WIRELESS |sed -e "s/.*HWaddr \(.*\)/\1/"` up
brctl addbr $DEVICE_BRIDGE
brctl addif $DEVICE_BRIDGE $DEVICE_WIRE
brctl addif $DEVICE_BRIDGE $DEVICE_WIRELESS
ifconfig $DEVICE_BRIDGE $IPADDR broadcast $BROADCAST netmask $NETMASK up

}

stopAP() {
echo  "Shutting down Wireless AP"
ifconfig $DEVICE_BRIDGE down
ifconfig $DEVICE_WIRE 0.0.0.0 down
ifconfig $DEVICE_WIRELESS 0.0.0.0 down
brctl delif $DEVICE_BRIDGE $DEVICE_WIRE
brctl delif $DEVICE_BRIDGE $DEVICE_WIRELESS
brctl delbr $DEVICE_BRIDGE
wlanconfig $DEVICE_WIRELESS destroy
}

case $1 in
  start)
  startAP
  ;;
  stop)
  stopAP
  ;;
  restart)
  stopAP
  startAP
  ;;
  *)
  echo "Usage: ap { start | stop | restart }"
  ;;
  esac



