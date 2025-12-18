#!/bin/sh
val=`/usr/sbin/reg 0x803c | grep 0xb000 | awk -F '=' '{print $2}'`
let "new=$val &~ 0x0020"
/usr/sbin/reg 0x803c=$new
