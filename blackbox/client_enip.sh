#!/bin/bash
while :
    do
        enip_client -a 172.16.192.12 SCADA[1]=99 SCADA[0-10]
        sleep 1
done
