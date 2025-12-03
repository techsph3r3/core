# Network Appliance Architecture for Digital Twin Platform

## Feature Progress Log

```
[Implemented / Ready]
- ApplianceSpec data model with compose support
- APPLIANCE_REGISTRY with 7 appliances (VyOS, FRR, iptables, Suricata, HAProxy, WireGuard, OpenPLC)
- Compose template system with Mako support
- Image availability verification
- Multi-interface appliance support
- Configuration generation (VyOS, FRR, iptables)
- Integration with TopologyGenerator (add_appliance method)
- XML generation with compose attributes

[In Design / Next Steps]
- Natural language → appliance selection (AI integration)
- Zone-based topology generation ("firewall between IT and OT")
- Web UI for appliance configuration
- Pre-seeded config file mounting

[Future / Out of Scope for Now]
- OpenPLC program binding (plc_program field)
- OT-sim process model integration (process_model field)
- Sensor node configuration (sensor_config field)
- 3D/AR/VR physical twin linking (physical_twin_id field)
- Protocol semantics layer (Modbus/DNP3 register maps)
```

---

## Architecture Overview

### Core Components

```
core_mcp/
├── appliance_registry.py    # ApplianceSpec, APPLIANCE_REGISTRY, helpers
├── topology_generator.py    # Extended with add_appliance(), compose support
└── ...

templates/
└── appliances/
    ├── vyos-compose.yml
    ├── frr-compose.yml
    ├── suricata-compose.yml
    ├── haproxy-compose.yml
    ├── wireguard-compose.yml
    ├── openplc-compose.yml
    ├── haproxy-default.cfg
    └── frr-default.conf

dockerfiles/
├── Dockerfile.alpine-firewall-core
└── ...
```

### Data Model

```python
@dataclass
class ApplianceSpec:
    # Identity
    name: str                      # Unique key (e.g., "vyos")
    display_name: str              # Human-readable
    category: ApplianceCategory    # FIREWALL, ROUTER, PLC, etc.
    keywords: List[str]            # For NL matching

    # Docker
    image: str                     # Docker image name
    image_tag: str                 # Default tag
    compose: Optional[ComposeSpec] # Compose template info

    # Network
    supports_multi_nic: bool
    min_interfaces: int
    max_interfaces: int
    interfaces: List[InterfaceSpec]  # Predefined interface roles

    # Configuration
    config_method: ConfigMethod    # BIND_MOUNT, INIT_SCRIPT, API
    config_paths: Dict[str, str]   # Config file locations
    volumes: List[VolumeSpec]

    # Runtime
    privileged: bool
    health_check: Optional[str]
    network_roles: List[NetworkRole]  # PERIMETER, OT_IT_BOUNDARY, etc.
```

---

## Registered Appliances

| Name | Category | Image | Use Case |
|------|----------|-------|----------|
| vyos | Firewall | vyos/vyos:current | Full router/firewall, IT/OT boundary |
| frr | Router | frrouting/frr:latest | Dynamic routing (BGP, OSPF) |
| iptables-firewall | Firewall | alpine-firewall-core | Lightweight zone separation |
| suricata | IDS/IPS | jasonish/suricata:latest | Network monitoring |
| haproxy | Load Balancer | haproxy:latest | Web server farms |
| wireguard | VPN Gateway | linuxserver/wireguard | Remote access, tunnels |
| openplc | PLC | openplc-core:latest | ICS/SCADA simulation |

---

## Usage Examples

### 1. Add a Firewall via API

```python
from core_mcp.topology_generator import TopologyGenerator

gen = TopologyGenerator()

# Add VyOS firewall between zones
fw = gen.add_appliance(
    node_id=1,
    name="fw1",
    appliance_type="vyos",
    x=500.0,
    y=300.0,
    interfaces=[
        {"name": "eth0", "ip": "192.168.1.1", "mask": 24, "zone": "wan"},
        {"name": "eth1", "ip": "10.0.1.1", "mask": 24, "zone": "lan"},
        {"name": "eth2", "ip": "10.0.2.1", "mask": 24, "zone": "ot"},
    ]
)

# Verify image is available
status = gen.verify_appliances()
if not status["ready"]:
    print("Missing images:")
    for issue in status["issues"]:
        print(f"  - {issue}")
```

### 2. Lookup Appliance by Keyword

```python
from core_mcp.appliance_registry import get_appliance, get_firewall_for_boundary

# Find by keyword
ids = get_appliance("intrusion detection")  # Returns suricata

# Find firewall for specific boundary
fw = get_firewall_for_boundary("it_ot")  # Returns vyos
```

### 3. Generate Configuration

```python
from core_mcp.appliance_registry import generate_firewall_config, get_appliance

spec = get_appliance("vyos")
configs = generate_firewall_config(
    spec,
    interfaces=[
        {"name": "eth0", "ip": "192.168.1.1", "mask": 24, "zone": "wan"},
        {"name": "eth1", "ip": "10.0.1.1", "mask": 24, "zone": "lan"},
    ],
    enable_nat=True,
    enable_dhcp=False,
)

# configs["config.boot"] contains VyOS configuration
```

---

## Compose Template System

Templates use Mako syntax with these variables:
- `{{ node }}` - Node object with `.name`, `.id`
- `{{ hostname }}` - Sanitized hostname
- `{{ appliance }}` - ApplianceSpec object

Example template excerpt:
```yaml
services:
  vyos:
    image: vyos/vyos:current
    hostname: ${hostname}
    container_name: ${node.name}
    privileged: true
    sysctls:
      - net.ipv4.ip_forward=1
```

---

## Adding New Appliances

### Step 1: Create Dockerfile (if needed)

```dockerfile
# dockerfiles/Dockerfile.myapp-core
FROM myapp:latest
RUN apt-get update && apt-get install -y iproute2 ethtool
```

### Step 2: Build and Push

```bash
docker build -t myapp-core -f Dockerfile.myapp-core .
```

### Step 3: Create Compose Template

```yaml
# templates/appliances/myapp-compose.yml
version: '3.8'
services:
  myapp:
    image: myapp-core:latest
    hostname: ${hostname}
    container_name: ${node.name}
    privileged: true
```

### Step 4: Register in APPLIANCE_REGISTRY

```python
"myapp": ApplianceSpec(
    name="myapp",
    display_name="My Application",
    description="Description here",
    category=ApplianceCategory.GENERIC,
    keywords=["myapp", "keyword1", "keyword2"],
    image="myapp-core",
    image_tag="latest",
    compose=ComposeSpec(
        template_file="myapp-compose.yml",
        service_name="myapp",
    ),
    ...
)
```

---

## Future Extensions

### OpenPLC Integration (Planned)
```python
# Future: plc_program field
"openplc": ApplianceSpec(
    ...
    plc_program="/path/to/program.st",  # Auto-load on startup
    modbus_config={
        "registers": [...],  # Register definitions
    }
)
```

### OT-sim Process Models (Planned)
```python
# Future: process_model field
"tank-sim": ApplianceSpec(
    ...
    process_model="tank_level_controller",
    process_params={
        "tank_capacity": 1000,
        "fill_rate": 10,
    }
)
```

### 3D/AR/VR Linking (Planned)
```python
# Future: physical_twin_id field
node.physical_twin_id = "blender://scene/pump_001"
```

---

## Image Availability

CORE does not auto-pull images. Before deploying:

```bash
# Pull required images
docker pull vyos/vyos:current
docker pull frrouting/frr:latest
docker pull jasonish/suricata:latest
docker pull haproxy:latest
docker pull linuxserver/wireguard:latest

# Build custom images
cd /workspaces/core/dockerfiles
docker build -t alpine-firewall-core -f Dockerfile.alpine-firewall-core .
docker build -t openplc-core -f Dockerfile.openplc-core .
```

---

## API Reference

### appliance_registry.py

| Function | Description |
|----------|-------------|
| `get_appliance(name)` | Lookup by name or keyword |
| `get_appliance_for_role(role)` | Get all appliances for a NetworkRole |
| `get_firewall_for_boundary(type)` | Get recommended firewall for boundary |
| `list_appliances(category)` | List all or by category |
| `check_appliance_ready(spec)` | Verify image and templates exist |
| `verify_all_appliances()` | Check all registered appliances |
| `generate_firewall_config(...)` | Generate config files |

### topology_generator.py (Extended)

| Method | Description |
|--------|-------------|
| `add_appliance(...)` | Add appliance node with compose support |
| `get_available_appliances()` | List appliances for UI/AI |
| `verify_appliances()` | Check topology's appliances are ready |
