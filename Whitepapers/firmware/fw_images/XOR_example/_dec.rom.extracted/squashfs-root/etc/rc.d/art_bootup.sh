#!/bin/sh
# This is supposed to be executed at boot time and should be called /etc/init.d/rcS
# when called by /etc/art_shell.sh, it would enter art mode for calibration failed device for re-calibration

if [ -z $1 ]; then
UNCALIBRATED_WLAN_PCI_DEVID=168cff1c
else
UNCALIBRATED_WLAN_PCI_DEVID=168c002a
fi

DEFAULT_IP=192.168.127.253

MODPATH=/usr/lib/modules
ATHSBINPATH=/usr/sbin

HWID=`/usr/sbin/iw_testBoard -i`

if [ ${HWID} = 8 ]
then
    echo "Running in calibration mode"
else
    # check if wlan device is calibrated
    cat /proc/bus/pci/devices | grep -i ${UNCALIBRATED_WLAN_PCI_DEVID} > /dev/null || exit 0
fi


# load Ethernet driver and set default IP address
modprobe athrs_gmac.ko

ifconfig eth0 up
ifconfig eth1 ${DEFAULT_IP} up
# Ethernet LED
echo eth1 > /sys/class/leds/lanled/device_name

# 
grep art /proc/modules || insmod ${MODPATH}/art.ko

# LED patterns to indicate in art mode
echo heartbeat > /sys/class/leds/ss4/trigger
echo heartbeat > /sys/class/leds/ss3/trigger
echo heartbeat > /sys/class/leds/ss2/trigger
echo default-on > /sys/class/leds/ss1/trigger
echo default-on > /sys/class/leds/ss0/trigger

${ATHSBINPATH}/mdk_client

