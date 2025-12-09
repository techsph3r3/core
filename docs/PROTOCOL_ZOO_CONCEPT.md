# Protocol Zoo Concept

## Overview

Create four distinct "Protocol Zoos" - network environments where multiple protocols of each type are running simultaneously for training, testing, and security research purposes.

---

## 1. OT Protocol Zoo (Industrial/SCADA)

### Protocols to Include

| Protocol | Port | Library/Tool | Complexity | Status |
|----------|------|--------------|------------|--------|
| **Modbus TCP** | 502 | pymodbus | Easy | Ready (OpenPLC) |
| **EtherNet/IP (CIP)** | 44818 | cpppo, pycomm3 | Medium | To Build |
| **DNP3** | 20000 | opendnp3, pydnp3 | Medium | To Build |
| **IEC 61850 MMS** | 102 | libiec61850 | Hard | To Build |
| **IEC 61850 GOOSE** | Layer 2 | libiec61850 | Hard | To Build |
| **IEC 60870-5-104** | 2404 | lib60870 | Medium | To Build |
| **OPC-UA** | 4840 | python-opcua | Medium | To Build |
| **BACnet/IP** | 47808 | bacpypes | Medium | To Build |
| **PROFINET** | Various | Custom | Hard | Future |
| **S7comm (Siemens)** | 102 | snap7 | Medium | To Build |

### Docker Images to Create

```
Dockerfile.modbus-server      # pymodbus server with configurable registers
Dockerfile.enip-server        # EtherNet/IP CIP server (cpppo)
Dockerfile.dnp3-outstation    # DNP3 outstation (opendnp3)
Dockerfile.iec61850-ied       # IEC 61850 IED simulator (libiec61850)
Dockerfile.opcua-server       # OPC-UA server (python-opcua)
Dockerfile.bacnet-device      # BACnet device (bacpypes)
Dockerfile.s7comm-plc         # S7comm simulator (snap7)
```

### Reference Projects

- [libiec61850](https://github.com/mz-automation/libiec61850) - IEC 61850 MMS/GOOSE/SV
- [TSSG/libiec61850-docker](https://github.com/TSSG/libiec61850-docker) - Docker container
- [st-ing/61850-sim](https://github.com/st-ing/61850-sim) - Fuzzy IEC61850 Simulator
- [ITI/ICS-Security-Tools](https://github.com/ITI/ICS-Security-Tools) - Protocol tools collection
- [pymodbus](https://github.com/pymodbus-dev/pymodbus) - Modbus implementation
- [cpppo](https://github.com/pjkundert/cpppo) - EtherNet/IP CIP

---

## 2. IT Protocol Zoo (Enterprise/Corporate)

### Protocols to Include

| Protocol | Port | Tool | Complexity | Status |
|----------|------|------|------------|--------|
| **DNS** | 53 | dnsmasq, bind9 | Easy | To Build |
| **DHCP** | 67/68 | dnsmasq, isc-dhcp | Easy | To Build |
| **HTTP/HTTPS** | 80/443 | nginx, apache | Easy | Ready |
| **FTP** | 21 | vsftpd, proftpd | Easy | To Build |
| **SFTP/SSH** | 22 | openssh | Easy | Ready |
| **SMB/CIFS** | 445 | samba | Easy | To Build |
| **LDAP** | 389/636 | openldap | Medium | To Build |
| **Kerberos** | 88 | MIT Kerberos | Hard | Future |
| **RADIUS** | 1812 | freeradius | Medium | To Build |
| **SNMP** | 161/162 | net-snmp | Easy | To Build |
| **NTP** | 123 | chrony, ntpd | Easy | To Build |
| **Syslog** | 514 | rsyslog | Easy | To Build |
| **RDP** | 3389 | xrdp | Medium | To Build |
| **VNC** | 5900 | x11vnc | Easy | Ready |

### Docker Images to Create

```
Dockerfile.dns-server         # dnsmasq with zone files
Dockerfile.file-server        # Samba + FTP + HTTP file shares
Dockerfile.ldap-server        # OpenLDAP with sample directory
Dockerfile.radius-server      # FreeRADIUS for auth testing
Dockerfile.snmp-device        # SNMP agent with MIBs
Dockerfile.syslog-server      # rsyslog collector
```

---

## 3. Internet Protocol Zoo (WAN/Public)

### Protocols to Include

| Protocol | Port | Tool | Complexity | Status |
|----------|------|------|------------|--------|
| **BGP** | 179 | FRR, BIRD | Medium | Ready (FRR) |
| **OSPF** | - | FRR, Quagga | Medium | Ready (FRR) |
| **HTTP/2** | 443 | nginx | Easy | To Build |
| **QUIC/HTTP3** | 443/UDP | nginx, caddy | Medium | Future |
| **WebSocket** | 80/443 | Various | Easy | Ready |
| **gRPC** | Various | grpcio | Medium | To Build |
| **GraphQL** | 443 | graphene | Medium | Future |
| **REST API** | 443 | flask, fastapi | Easy | Ready |
| **SMTP** | 25/587 | postfix | Medium | To Build |
| **IMAP/POP3** | 143/110 | dovecot | Medium | To Build |
| **SIP/VoIP** | 5060 | asterisk | Hard | Future |
| **WebRTC** | Various | janus | Hard | Future |

### Docker Images to Create

```
Dockerfile.mail-server        # Postfix + Dovecot
Dockerfile.api-server         # REST/gRPC endpoints
Dockerfile.voip-server        # Asterisk PBX
```

---

## 4. IoT Protocol Zoo

### Protocols to Include

| Protocol | Port | Tool | Complexity | Status |
|----------|------|------|------------|--------|
| **MQTT** | 1883/8883 | mosquitto | Easy | Ready |
| **MQTT-SN** | 1885/UDP | mosquitto.rsmb | Medium | To Build |
| **CoAP** | 5683/UDP | aiocoap, libcoap | Medium | To Build |
| **LwM2M** | 5683 | leshan, wakaama | Medium | To Build |
| **AMQP** | 5672 | rabbitmq | Medium | To Build |
| **DDS** | Various | cyclonedds | Hard | Future |
| **Zigbee** | - | zigbee2mqtt | Medium | To Build |
| **Z-Wave** | - | zwave-js | Medium | Future |
| **BLE** | - | bluez | Medium | To Build |
| **LoRaWAN** | - | chirpstack | Hard | To Build |
| **Thread/Matter** | - | openthread | Hard | Future |
| **KNX** | 3671 | knxd | Medium | Future |

### Docker Images to Create

```
Dockerfile.mqtt-broker        # Mosquitto with auth (exists)
Dockerfile.coap-server        # CoAP resource server
Dockerfile.lwm2m-server       # LwM2M bootstrap/device mgmt
Dockerfile.amqp-broker        # RabbitMQ
Dockerfile.lorawan-server     # ChirpStack network server
Dockerfile.zigbee-gateway     # Zigbee2MQTT coordinator
```

---

## Implementation Priority

### Phase 1: Easy Wins (Use existing libraries)

1. **OT Zoo**
   - Modbus TCP server (pymodbus) - extend OpenPLC
   - EtherNet/IP server (cpppo)
   - DNP3 outstation (opendnp3)

2. **IT Zoo**
   - DNS server (dnsmasq)
   - File server (Samba + FTP)
   - SNMP device (net-snmp)

3. **IoT Zoo**
   - MQTT broker (already have)
   - CoAP server (aiocoap)
   - AMQP broker (RabbitMQ)

### Phase 2: Medium Complexity

1. **OT Zoo**
   - OPC-UA server
   - BACnet device
   - S7comm simulator

2. **IT Zoo**
   - LDAP server
   - RADIUS server
   - Mail server

3. **IoT Zoo**
   - LwM2M server
   - LoRaWAN network server

### Phase 3: Advanced (Requires significant effort)

1. **OT Zoo**
   - IEC 61850 IED (MMS + GOOSE)
   - IEC 60870-5-104
   - PROFINET

2. **Internet Zoo**
   - VoIP/SIP
   - WebRTC

3. **IoT Zoo**
   - Thread/Matter
   - DDS

---

## Topology Templates

### OT Protocol Zoo Topology

```yaml
name: "OT Protocol Zoo"
description: "All major industrial protocols in one network"

zones:
  scada_network:
    subnet: "172.16.100.0/24"
    nodes:
      - name: modbus-plc
        type: modbus-server
        ip: "172.16.100.10"
        ports: [502]
      - name: enip-plc
        type: enip-server
        ip: "172.16.100.11"
        ports: [44818]
      - name: dnp3-rtu
        type: dnp3-outstation
        ip: "172.16.100.12"
        ports: [20000]
      - name: iec61850-ied
        type: iec61850-server
        ip: "172.16.100.13"
        ports: [102]
      - name: opcua-server
        type: opcua-server
        ip: "172.16.100.14"
        ports: [4840]
      - name: hmi-workstation
        type: hmi-workstation
        ip: "172.16.100.100"
      - name: historian
        type: historian
        ip: "172.16.100.101"
```

### IoT Protocol Zoo Topology

```yaml
name: "IoT Protocol Zoo"
description: "IoT protocols for smart building/home scenarios"

zones:
  iot_network:
    subnet: "192.168.50.0/24"
    nodes:
      - name: mqtt-broker
        type: mqtt-broker
        ip: "192.168.50.10"
        ports: [1883, 8883]
      - name: coap-server
        type: coap-server
        ip: "192.168.50.11"
        ports: [5683/udp]
      - name: lwm2m-server
        type: lwm2m-server
        ip: "192.168.50.12"
        ports: [5683, 5684]
      - name: amqp-broker
        type: amqp-broker
        ip: "192.168.50.13"
        ports: [5672]
      - name: zigbee-gateway
        type: zigbee-gateway
        ip: "192.168.50.20"
      - name: iot-dashboard
        type: hmi-workstation
        ip: "192.168.50.100"
```

---

## Training Scenarios

### OT Zoo Exercises

1. **Protocol Discovery** - Use Wireshark to identify all running protocols
2. **Modbus Attacks** - Read/write registers without authentication
3. **DNP3 Fuzzing** - Send malformed DNP3 packets
4. **IEC 61850 GOOSE Injection** - Inject false GOOSE messages
5. **OPC-UA Enumeration** - Browse server namespace

### IT Zoo Exercises

1. **DNS Poisoning** - Redirect queries to attacker
2. **LDAP Enumeration** - Extract directory information
3. **SMB Relay** - Man-in-the-middle file shares
4. **SNMP Walk** - Extract device configurations

### IoT Zoo Exercises

1. **MQTT Sniffing** - Capture unencrypted messages
2. **CoAP Discovery** - Find CoAP resources
3. **Zigbee Sniffing** - Capture Zigbee traffic
4. **LoRaWAN Replay** - Replay captured packets

---

## Sources & References

- [ITI/ICS-Security-Tools](https://github.com/ITI/ICS-Security-Tools/tree/master/protocols) - Protocol tools
- [libiec61850](https://github.com/mz-automation/libiec61850) - IEC 61850 library
- [pymodbus](https://github.com/pymodbus-dev/pymodbus) - Modbus library
- [cpppo](https://github.com/pjkundert/cpppo) - EtherNet/IP CIP
- [iotechsys/pymodbus-sim](https://hub.docker.com/r/iotechsys/pymodbus-sim) - Modbus Docker
- [SCADA-LTS](https://github.com/SCADA-LTS/Scada-LTS) - Open source SCADA
- [GRFICSv2 Tutorial](https://sagittarius.hashnode.dev/going-out-with-a-bang-virtual-scada-hacking-with-grficsv2-part-2) - SCADA hacking

---

## Notes

- All protocol servers should support CORE network namespaces
- Each container needs iproute2, ethtool, net-tools for CORE compatibility
- Servers should be configurable via environment variables or config files
- Consider adding traffic generators that produce realistic protocol traffic
- IEC 61850 GOOSE operates at Layer 2 - requires special handling in Docker
