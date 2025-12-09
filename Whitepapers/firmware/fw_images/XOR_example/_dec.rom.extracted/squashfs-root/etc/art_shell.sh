#!/bin/sh

TARGET_STATUS=`fw_printenv -n target_status`

if [ -z ${TARGET_STATUS} ]; then
    exit 0
fi

ST=`printf "%d" 0x${TARGET_STATUS}`
if [ $? == 1 ]; then
exit 1
fi

BURNING_FINISHED=`expr $ST / 8 % 2`

if [  ${BURNING_FINISHED} == 0 ]; then
    killall burnin > /dev/null 2>&1
    /sbin/brctl show | grep eth1 && brctl delif br0 eth1
    /sbin/brctl show | grep ath00 && brctl delif br0 ath00
    /sbin/brctl show | grep ath01 && brctl delif br0 ath01

    /etc/rc.d/art_bootup.sh ${BURNING_FINISHED}
else
    exit
fi

