# VyOS Configuration Generator

## Overview

The VyOS configuration generator creates complete `config.boot` files for VyOS router/firewall appliances. It supports enterprise-grade routing protocols, VLANs, DHCP, NAT, and custom firewall rules.

## Supported Features

| Feature | Parameter | Status |
|---------|-----------|--------|
| **IP Addresses** | `interfaces` | ✅ Full support |
| **Multi-NIC** | `interfaces` (2-8 NICs) | ✅ Full support |
| **VLANs (802.1Q)** | `vlans` | ✅ Full support |
| **OSPF** | `ospf_config` | ✅ Full support |
| **BGP** | `bgp_config` | ✅ Full support |
| **Static Routes** | `static_routes` | ✅ Full support |
| **NAT/Masquerade** | `enable_nat` | ✅ Full support |
| **DHCP Server** | `enable_dhcp` + `dhcp_range` | ✅ Full support |
| **Firewall Rules** | `custom_rules` | ✅ Full support |
| **Zone-based FW** | Auto-generated | ✅ WAN-TO-LAN, LAN-TO-WAN |

## Usage

```python
from core_mcp.appliance_registry import generate_firewall_config, get_appliance

vyos = get_appliance('vyos')

config = generate_firewall_config(
    spec=vyos,
    interfaces=[...],
    # options...
)

# config['config.boot'] contains the VyOS configuration
```

## Parameter Reference

### `interfaces` (Required)

List of network interfaces with IP addresses and zone assignments.

```python
interfaces=[
    {'name': 'eth0', 'ip': '10.0.1.1', 'mask': 24, 'zone': 'wan'},
    {'name': 'eth1', 'ip': '10.0.2.1', 'mask': 24, 'zone': 'lan'},
    {'name': 'eth2', 'ip': '10.0.3.1', 'mask': 24, 'zone': 'dmz'},
    {'name': 'eth3', 'ip': '10.0.4.1', 'mask': 24, 'zone': 'ot'},
]
```

**Zone types:**
- `wan`, `external`, `untrusted` → WAN interface (NAT outbound)
- `lan`, `internal`, `trusted` → LAN interface (DHCP server)
- Any other value → Custom zone

### `vlans` (Optional)

802.1Q VLAN subinterfaces.

```python
vlans=[
    {'parent': 'eth1', 'id': 100, 'ip': '10.100.0.1', 'mask': 24, 'description': 'IT VLAN'},
    {'parent': 'eth1', 'id': 200, 'ip': '10.200.0.1', 'mask': 24, 'description': 'OT VLAN'},
    {'parent': 'eth1', 'id': 300, 'ip': '10.300.0.1', 'mask': 24, 'description': 'Guest VLAN'},
]
```

**Generated config:**
```
interfaces {
    ethernet eth1 {
        address 10.0.2.1/24
        vif 100 {
            address 10.100.0.1/24
            description "IT VLAN"
        }
        vif 200 {
            address 10.200.0.1/24
            description "OT VLAN"
        }
    }
}
```

### `ospf_config` (Optional)

Open Shortest Path First routing protocol configuration.

```python
ospf_config={
    'router_id': '10.0.1.1',           # Router ID (usually loopback or main IP)
    'areas': [
        {
            'id': '0',                  # Area ID (0 = backbone)
            'networks': ['10.0.0.0/8'], # Networks in this area (auto-detected if omitted)
            'type': 'normal'            # normal, stub, or nssa
        }
    ],
    'redistribute': ['connected', 'static', 'bgp'],  # Route redistribution
    'passive_interfaces': ['eth0'],     # Don't send OSPF hellos on these
}
```

**Generated config:**
```
protocols {
    ospf {
        parameters {
            router-id 10.0.1.1
        }
        area 0 {
            network 10.0.0.0/8
        }
        redistribute connected
        redistribute static
        passive-interface eth0
    }
}
```

### `bgp_config` (Optional)

Border Gateway Protocol configuration for inter-AS routing.

```python
bgp_config={
    'asn': 65001,                       # Local AS number
    'router_id': '10.0.1.1',            # BGP router ID
    'neighbors': [
        {
            'ip': '10.0.1.2',           # Neighbor IP
            'remote_as': 65002,          # Neighbor's AS
            'description': 'ISP-1',      # Optional description
            'password': 'secret',        # Optional MD5 password
            'update_source': 'eth0',     # Optional source interface
        }
    ],
    'networks': ['10.0.0.0/8'],         # Networks to advertise
    'redistribute': ['connected', 'static', 'ospf'],  # Redistribution
}
```

**Generated config:**
```
protocols {
    bgp {
        local-as 65001
        parameters {
            router-id 10.0.1.1
        }
        neighbor 10.0.1.2 {
            remote-as 65002
            description "ISP-1"
            address-family {
                ipv4-unicast {
                }
            }
        }
        address-family {
            ipv4-unicast {
                network 10.0.0.0/8
                redistribute connected
            }
        }
    }
}
```

### `static_routes` (Optional)

Static routing entries.

```python
static_routes=[
    {'destination': '0.0.0.0/0', 'next_hop': '10.0.1.254'},              # Default route
    {'destination': '192.168.0.0/16', 'next_hop': '10.0.2.254', 'distance': 10},
]
```

### `enable_nat` (Default: True)

Enable source NAT (masquerade) on the WAN interface.

```python
enable_nat=True
```

### `enable_dhcp` + `dhcp_range` (Optional)

Enable DHCP server on LAN interface.

```python
enable_dhcp=True,
dhcp_range='192.168.1.100-192.168.1.200'
```

**Generated config:**
```
service {
    dhcp-server {
        shared-network-name LAN {
            subnet 192.168.1.0/24 {
                range 0 {
                    start 192.168.1.100
                    stop 192.168.1.200
                }
                default-router 192.168.1.1
                lease 86400
            }
        }
    }
}
```

### `custom_rules` (Optional)

Custom firewall rules as a list of rule dictionaries.

```python
custom_rules=[
    {
        'action': 'accept',          # accept, drop, reject
        'source': '10.0.2.0/24',     # Source network
        'destination': '10.0.3.0/24', # Destination network
        'dport': '443',              # Destination port
        'protocol': 'tcp',           # tcp, udp, icmp
        'description': 'Allow HTTPS to OT zone',
    },
    {
        'action': 'drop',
        'source': '0.0.0.0/0',
        'destination': '10.0.3.0/24',
        'description': 'Block all to OT',
    },
]
```

### `hostname` (Default: 'vyos-firewall')

Router hostname.

```python
hostname='it-ot-gateway'
```

## Complete Example: IT/OT Segmentation

```python
from core_mcp.appliance_registry import generate_firewall_config, get_appliance

vyos = get_appliance('vyos')

config = generate_firewall_config(
    spec=vyos,
    interfaces=[
        {'name': 'eth0', 'ip': '10.0.1.1', 'mask': 24, 'zone': 'wan'},
        {'name': 'eth1', 'ip': '10.0.2.1', 'mask': 24, 'zone': 'lan'},  # IT
        {'name': 'eth2', 'ip': '10.0.3.1', 'mask': 24, 'zone': 'ot'},   # OT
    ],
    enable_nat=True,
    enable_dhcp=True,
    dhcp_range='10.0.2.100-10.0.2.200',
    ospf_config={
        'router_id': '10.0.1.1',
        'areas': [{'id': '0'}],
        'redistribute': ['connected'],
    },
    custom_rules=[
        # Allow IT to access OT HMI on port 443
        {'action': 'accept', 'source': '10.0.2.0/24', 'destination': '10.0.3.100/32',
         'dport': '443', 'protocol': 'tcp', 'description': 'IT to HMI HTTPS'},
        # Allow IT to ping OT
        {'action': 'accept', 'source': '10.0.2.0/24', 'destination': '10.0.3.0/24',
         'protocol': 'icmp', 'description': 'IT to OT ICMP'},
        # Block everything else from IT to OT
        {'action': 'drop', 'source': '10.0.2.0/24', 'destination': '10.0.3.0/24',
         'description': 'Block IT to OT'},
    ],
    hostname='it-ot-firewall',
)

# Write to file for VyOS container
with open('/tmp/vyos-config.boot', 'w') as f:
    f.write(config['config.boot'])
```

## Deployment in CORE

The VyOS appliance is deployed via Docker with the configuration bind-mounted:

```yaml
# vyos-compose.yml template
services:
  vyos:
    image: 2stacks/vyos:latest
    privileged: true
    volumes:
      - vyos-config:/config  # config.boot goes here
    sysctls:
      - net.ipv4.ip_forward=1
```

VyOS automatically loads `/config/config.boot` on startup.

## Auto-Generated Features

The generator automatically creates:

1. **Loopback interface** - For router-id stability
2. **Zone-based firewall rules**:
   - `WAN-TO-LAN`: Default drop, allow established/related
   - `LAN-TO-WAN`: Default accept (allow outbound)
3. **State tracking**: Accept established, related; drop invalid
4. **System config**: Hostname, user (vyos/vyos), syslog, NTP

## VyOS Capabilities Not Yet Implemented

These VyOS features could be added in the future:

- VPN (WireGuard, IPSec, OpenVPN)
- IPv6 support
- Policy-based routing
- QoS / Traffic shaping
- High Availability (VRRP)
- RADIUS/TACACS+ authentication
- SNMPv3
- NetFlow/sFlow export
