"""
OpenPLC Monitoring Module - Modified with Force Support

This module handles monitoring of PLC variables via Modbus and supports
forcing point values - a critical ICS feature for maintenance and testing
(but also a potential attack vector if access is not properly controlled).

Modifications by CybatiWorks for ICS Security Education.

NOTE: This file must be Python 2.7 compatible for OpenPLC!
"""
import time, threading
from struct import *
from pymodbus.client.sync import ModbusTcpClient

class debug_var():
    name = ''
    location = ''
    type = ''
    forced = 'No'
    forced_value = None  # The value to force (True/False for BOOL, int for others)
    value = 0

debug_vars = []
monitor_active = False
mb_client = None

def parse_st(st_file):
    global debug_vars
    filepath = './st_files/' + st_file

    st_program = open(filepath, 'r')

    for line in st_program.readlines():
        if line.find(' AT ') > 0 and line.find('%') > 0 and line.find('(*') < 0 and line.find('*)') < 0:
            debug_data = debug_var()
            tmp = line.strip().split(' ')
            debug_data.name = tmp[0]
            debug_data.location = tmp[2]
            debug_data.type = tmp[4].split(';')[0]

            #don't add special functions (%ML1024 and up) as they are not accessible
            if (debug_data.location.find('ML')) > 0:
                mb_address = debug_data.location.split('%ML')[1]
                if (int(mb_address) < 1024):
                    debug_vars.append(debug_data)
            else:
                debug_vars.append(debug_data)

    for debugs in debug_vars:
        print('Name: ' + debugs.name)
        print('Location: ' + debugs.location)
        print('Type: ' + debugs.type)
        print('')


def cleanup():
    del debug_vars[:]


def force_point(point_id, enable, value):
    """
    Force a point to a specific value.

    Args:
        point_id: Index into debug_vars array
        enable: True to enable force, False to release
        value: The value to force (bool for BOOL type, int for others)

    Returns:
        True if successful, False otherwise
    """
    global debug_vars, mb_client

    if point_id < 0 or point_id >= len(debug_vars):
        print("Force error: Invalid point_id " + str(point_id))
        return False

    debug_data = debug_vars[point_id]

    if enable:
        debug_data.forced = 'Yes'
        debug_data.forced_value = value
        print("Force enabled: " + debug_data.name + " (" + debug_data.location + ") = " + str(value))

        # Immediately write the forced value
        if mb_client is not None:
            try:
                _write_forced_value(debug_data)
            except Exception as e:
                print("Force write error: " + str(e))
                return False
    else:
        debug_data.forced = 'No'
        debug_data.forced_value = None
        print("Force released: " + debug_data.name + " (" + debug_data.location + ")")

    return True


def _write_forced_value(debug_data):
    """Write the forced value to the PLC via Modbus."""
    global mb_client

    if debug_data.forced != 'Yes' or debug_data.forced_value is None:
        return

    if mb_client is None:
        return

    location = debug_data.location
    value = debug_data.forced_value

    try:
        if location.find('QX') > 0:
            # Writing to Coils (digital outputs)
            mb_address = location.split('%QX')[1].split('.')
            if len(mb_address) < 2:
                addr = int(mb_address[0]) * 8
            else:
                addr = int(mb_address[0]) * 8 + int(mb_address[1])

            if isinstance(value, bool):
                bool_value = value
            else:
                bool_value = (str(value).upper() == 'TRUE' or value == 1)
            mb_client.write_coil(addr, bool_value)
            print("  -> Wrote coil " + str(addr) + " = " + str(bool_value))

        elif location.find('MW') > 0:
            # Writing to Word Memory (holding registers)
            mb_address = int(location.split('%MW')[1])
            if isinstance(value, bool):
                int_value = 1 if value else 0
            else:
                int_value = int(value)
            mb_client.write_register(mb_address + 1024, int_value)
            print("  -> Wrote register " + str(mb_address + 1024) + " = " + str(int_value))

        elif location.find('QW') > 0:
            # Writing to Output Word (holding registers)
            mb_address = int(location.split('%QW')[1])
            int_value = int(value)
            mb_client.write_register(mb_address, int_value)
            print("  -> Wrote register " + str(mb_address) + " = " + str(int_value))

        elif location.find('MD') > 0:
            # Writing to Double Memory (32-bit)
            mb_address = int(location.split('%MD')[1])
            # Pack value appropriately based on type
            if debug_data.type == 'REAL':
                float_pack = pack('>f', float(value))
                regs = unpack('>HH', float_pack)
            else:
                int_pack = pack('>i', int(value))
                regs = unpack('>HH', int_pack)
            mb_client.write_registers((mb_address * 2) + 2048, list(regs))
            print("  -> Wrote double " + str((mb_address * 2) + 2048) + " = " + str(value))

    except Exception as e:
        print("Error writing forced value: " + str(e))


def get_force_status():
    """Get a summary of all forced points."""
    forced_points = []
    for i, debug_data in enumerate(debug_vars):
        if debug_data.forced == 'Yes':
            forced_points.append({
                'id': i,
                'name': debug_data.name,
                'location': debug_data.location,
                'type': debug_data.type,
                'forced_value': debug_data.forced_value
            })
    return forced_points


def modbus_monitor():
    global mb_client
    for debug_data in debug_vars:
        # If point is forced, write the forced value instead of just reading
        if debug_data.forced == 'Yes' and debug_data.forced_value is not None:
            try:
                _write_forced_value(debug_data)
            except Exception as e:
                print("Force write error in monitor: " + str(e))

        # Still read the current value for display
        try:
            if (debug_data.location.find('IX')) > 0:
                #Reading Input Status
                mb_address = debug_data.location.split('%IX')[1].split('.')
                result = mb_client.read_discrete_inputs(int(mb_address[0])*8 + int(mb_address[1]), 1)
                debug_data.value = result.bits[0]

            elif (debug_data.location.find('QX')) > 0:
                #Reading Coils
                mb_address = debug_data.location.split('%QX')[1].split('.')
                if (len(mb_address) < 2):
                    result = mb_client.read_coils(int(mb_address[0])*8, 1)
                else:
                    result = mb_client.read_coils(int(mb_address[0])*8 + int(mb_address[1]), 1)
                debug_data.value = result.bits[0]

            elif (debug_data.location.find('IW')) > 0:
                #Reading Input Registers
                mb_address = debug_data.location.split('%IW')[1]
                result = mb_client.read_input_registers(int(mb_address), 1)
                debug_data.value = result.registers[0]

            elif (debug_data.location.find('QW')) > 0:
                #Reading Holding Registers
                mb_address = debug_data.location.split('%QW')[1]
                result = mb_client.read_holding_registers(int(mb_address), 1)
                debug_data.value = result.registers[0]

            elif (debug_data.location.find('MW')) > 0:
                #Reading Word Memory
                mb_address = debug_data.location.split('%MW')[1]
                result = mb_client.read_holding_registers(int(mb_address) + 1024, 1)
                debug_data.value = result.registers[0]

            elif (debug_data.location.find('MD')) > 0:
                #Reading Double Memory
                mb_address = debug_data.location.split('%MD')[1]
                result = mb_client.read_holding_registers((int(mb_address)*2) + 2048, 2)
                if (debug_data.type == 'SINT') or (debug_data.type == 'INT') or (debug_data.type == 'DINT'):
                    #signed integer
                    float_pack = pack('>HH', result.registers[0], result.registers[1])
                    debug_data.value = unpack('>i', float_pack)[0]

                if (debug_data.type == 'USINT') or (debug_data.type == 'UINT') or (debug_data.type == 'UDINT'):
                    #unsigned integer
                    float_pack = pack('>HH', result.registers[0], result.registers[1])
                    debug_data.value = unpack('>I', float_pack)[0]

                if (debug_data.type == 'REAL'):
                    #32-bit float
                    float_pack = pack('>HH', result.registers[0], result.registers[1])
                    debug_data.value = unpack('>f', float_pack)[0]

            elif (debug_data.location.find('ML')) > 0:
                #Reading Long Memory
                mb_address = debug_data.location.split('%ML')[1]
                result = mb_client.read_holding_registers((int(mb_address)*4) + 4096, 4)
                if (debug_data.type == 'SINT') or (debug_data.type == 'INT') or (debug_data.type == 'DINT') or (debug_data.type == 'LINT'):
                    #signed integer
                    float_pack = pack('>HHHH', result.registers[0], result.registers[1], result.registers[2], result.registers[3])
                    debug_data.value = unpack('>q', float_pack)[0]

                if (debug_data.type == 'USINT') or (debug_data.type == 'UINT') or (debug_data.type == 'UDINT') or (debug_data.type == 'ULINT'):
                    #unsigned integer
                    float_pack = pack('>HHHH', result.registers[0], result.registers[1], result.registers[2], result.registers[3])
                    debug_data.value = unpack('>Q', float_pack)[0]

                if (debug_data.type == 'REAL') or (debug_data.type == 'LREAL'):
                    #64-bit float
                    float_pack = pack('>HHHH', result.registers[0], result.registers[1], result.registers[2], result.registers[3])
                    debug_data.value = unpack('>d', float_pack)[0]
        except Exception as e:
            # Don't crash on read errors
            pass


    if (monitor_active == True):
        threading.Timer(0.5, modbus_monitor).start()

def start_monitor(modbus_port_cfg):
    global monitor_active
    global mb_client

    if (monitor_active != True):
        monitor_active = True
        mb_client = ModbusTcpClient('127.0.0.1', port=modbus_port_cfg)

        modbus_monitor()

def stop_monitor():
    global monitor_active
    global mb_client

    if (monitor_active != False):
        monitor_active = False
        mb_client.close()
