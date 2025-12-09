#!/usr/bin/env python

from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.exceptions import ConnectionException
import logging

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)

#####################################
# Code
#####################################
client = ModbusClient('172.16.192.2', port=502)

try:
    client.connect()
    rq = client.write_register(0x10, 1) # Run Plant, Run!
except KeyboardInterrupt:
    client.close()
except ConnectionException:
    print "Unable to connect / Connection lost"
