#!/bin/sh

MODPATH=/usr/lib/modules
ATHSBINPATH=/usr/sbin

MODS="umac ath_dev ath_dfs ath_hal asf adf ath_rate_atheros"
WLAN_INTF="ath00 ath01"



#echo ${WLAN_INTF}
for i in ${WLAN_INTF};
do
    /sbin/brctl show | grep ${i} && brctl delif br0 ${i}
    /sbin/ifconfig ${i} > /dev/null 2>&1 && /sbin/ifconfig ${i} down && ${ATHSBINPATH}/wlanconfig ${i} destroy
done

for m in ${MODS};
do
    grep $m /proc/modules && rmmod ${m}
done

grep art /proc/modules || insmod ${MODPATH}/art.ko

${ATHSBINPATH}/mdk_client

