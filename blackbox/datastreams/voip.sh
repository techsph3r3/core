#!/bin/bash
#CybatiWorks-1 Traffic Generator
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
while true
do
   vcmd -c /tmp/pycore.$CORE_SESSION/n17 -- ITGRecv -Sp 5060 &
   vcmd -c /tmp/pycore.$CORE_SESSION/n16 -- ITGRecv -Sp 5060 &
   vcmd -c /tmp/pycore.$CORE_SESSION/n22 -- ITGSend -a 10.0.11.10 -Sdp 5060 -rp 10001 VoIP -x G.711.2 -h RTP -VAD &
   vcmd -c /tmp/pycore.$CORE_SESSION/n38 -- ITGSend -a 10.0.11.11 -Sdp 5060 -rp 10001 VoIP -x G.711.2 -h RTP -VAD &
   sleep 30;
done
