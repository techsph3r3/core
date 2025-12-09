#!/bin/bash
#CybatiWorks-1 Modbus Redirect
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
while ! nc -q 1 73.9.13.10 53 </dev/null; do
    sleep 2;
done
#while true
#do
#  if lsof -Pi :502 -sTCP:LISTEN -t >/dev/null ; then
#      sleep 2;
#  else
#      killall -s 9 nc
      rm /tmp/pycore.$CORE_SESSION/n17.conf/backpipe
      mkfifo /tmp/pycore.$CORE_SESSION/n17.conf/backpipe
      /bin/nc -l -p 502 0</tmp/pycore.$CORE_SESSION/n17.conf/backpipe | /bin/nc 73.9.13.10 53 1>/tmp/pycore.$CORE_SESSION/n17.conf/backpipe &
#      sleep 2;
#  fi
#done
