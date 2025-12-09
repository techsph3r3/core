#!/bin/sh
MODPATH=/usr/lib/modules
if [ -e ${MODPATH}/mox_vlan.ko ]; then
    /sbin/insmod ${MODPATH}/mox_vlan.ko
fi
modprobe athrs_gmac
ifconfig eth0 192.168.127.253 up
insmod /usr/lib/modules/art.ko
/usr/sbin/nart.out -console &
# LED patterns to indicate in art mode
echo heartbeat > /sys/class/leds/wlan0/trigger
