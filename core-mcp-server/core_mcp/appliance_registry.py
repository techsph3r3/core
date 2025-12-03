"""
Appliance Registry - Extended container registry for network appliances and complex services.

This module provides:
1. ApplianceSpec - Rich data model for appliances (firewalls, routers, PLCs, etc.)
2. APPLIANCE_REGISTRY - Curated registry of tested appliances
3. Compose template management
4. Image availability verification
5. Configuration seeding helpers

DESIGN PRINCIPLES:
- Curated registry only (no auto-pull of unknown images)
- Compose-first for appliances (simple apps can use image-only)
- Configuration via bind mounts, not environment variables
- Multi-interface support is first-class

FUTURE EXTENSIONS (hooks in place):
- OpenPLC: will add "plc_program" field for ST/LD bindings
- OT-sim: will add "process_model" field for tank/pump/robot models
- Sensors: will add "sensor_config" for protocol bindings
- 3D/AR/VR: will link via node_id to Blender/Godot scene objects
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, List, Optional, Any
from pathlib import Path
import subprocess
import os


# =============================================================================
# ENUMS AND CONSTANTS
# =============================================================================

class ApplianceCategory(Enum):
    """Categories of appliances for filtering and UI grouping."""
    FIREWALL = "firewall"
    ROUTER = "router"
    SWITCH = "switch"          # Managed/smart switches
    LOAD_BALANCER = "load_balancer"
    VPN_GATEWAY = "vpn_gateway"
    IDS_IPS = "ids_ips"
    WEB_SERVER = "web_server"
    DATABASE = "database"
    PLC = "plc"                # Future: OpenPLC, etc.
    HMI = "hmi"                # Future: HMI interfaces
    HISTORIAN = "historian"   # Future: data historians
    SENSOR = "sensor"         # Future: sensor nodes
    WORKSTATION = "workstation"
    ATTACKER = "attacker"     # Red team tools
    GENERIC = "generic"


class ConfigMethod(Enum):
    """How configuration is injected into the appliance."""
    BIND_MOUNT = "bind_mount"      # Mount config file into container
    ENVIRONMENT = "environment"    # Environment variables (limited use)
    INIT_SCRIPT = "init_script"   # Run script on first boot
    API = "api"                    # Configure via REST/CLI after start
    NONE = "none"                  # No configuration needed


class NetworkRole(Enum):
    """Role of the appliance in network topology."""
    PERIMETER = "perimeter"        # Edge firewall, external-facing
    INTERNAL = "internal"          # Internal segmentation
    CORE = "core"                  # Core routing/switching
    ACCESS = "access"              # Access layer
    DMZ = "dmz"                    # DMZ placement
    OT_IT_BOUNDARY = "ot_it_boundary"  # IT/OT segmentation point
    ENDPOINT = "endpoint"          # End device, not infrastructure


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class InterfaceSpec:
    """Specification for a network interface on an appliance."""
    name: str                      # e.g., "eth0", "wan", "lan"
    role: str                      # e.g., "wan", "lan", "dmz", "ot", "it"
    description: str
    default_zone: Optional[str] = None  # Firewall zone assignment


@dataclass
class VolumeSpec:
    """Specification for a volume mount."""
    container_path: str            # Path inside container
    description: str
    required: bool = False         # Must be mounted for appliance to work
    default_template: Optional[str] = None  # Template file to use if not provided


@dataclass
class ComposeSpec:
    """Specification for compose-based deployment."""
    template_file: str             # Path to compose template (relative to templates/)
    service_name: str              # Primary service name in compose file
    depends_on: List[str] = field(default_factory=list)  # Other services it needs


@dataclass
class ApplianceSpec:
    """
    Complete specification for a network appliance.

    This is the core data structure for the appliance registry.
    It captures everything needed to deploy and configure an appliance in CORE.
    """
    # Identity
    name: str                      # Unique identifier (e.g., "vyos", "frr-router")
    display_name: str              # Human-readable name
    description: str
    category: ApplianceCategory
    keywords: List[str]            # For natural language matching

    # Docker configuration
    image: str                     # Docker image name (must be pre-pulled)
    image_tag: str = "latest"      # Default tag
    base_image: str = ""           # What it's built from (for documentation)

    # Compose support (optional - if None, uses simple image mode)
    compose: Optional[ComposeSpec] = None

    # Network configuration
    supports_multi_nic: bool = True      # Can handle multiple interfaces
    min_interfaces: int = 1              # Minimum interfaces required
    max_interfaces: int = 8              # Maximum interfaces supported
    interfaces: List[InterfaceSpec] = field(default_factory=list)  # Predefined interfaces

    # Container requirements
    privileged: bool = True              # CORE needs this for networking
    capabilities: List[str] = field(default_factory=list)  # Extra caps if not privileged

    # Configuration
    config_method: ConfigMethod = ConfigMethod.BIND_MOUNT
    config_paths: Dict[str, str] = field(default_factory=dict)  # config_name -> container_path
    volumes: List[VolumeSpec] = field(default_factory=list)

    # Runtime
    ports: List[int] = field(default_factory=list)  # Exposed ports (for documentation)
    health_check: Optional[str] = None   # Command to verify appliance is ready
    startup_time: int = 10               # Seconds to wait for startup

    # Topology hints
    network_roles: List[NetworkRole] = field(default_factory=list)  # Where it fits
    typical_placement: str = ""          # Hint for topology generator

    # CORE-specific
    core_services: List[str] = field(default_factory=list)  # CORE services to enable

    # Future extensions (hooks)
    # plc_program: Optional[str] = None      # Future: PLC program path
    # process_model: Optional[str] = None    # Future: OT-sim model reference
    # sensor_config: Optional[Dict] = None   # Future: sensor protocol config
    # physical_twin_id: Optional[str] = None # Future: Blender/Godot object ID

    def full_image_name(self) -> str:
        """Return full image:tag string."""
        return f"{self.image}:{self.image_tag}"


@dataclass
class ApplianceRequest:
    """
    Request from topology generator to instantiate an appliance.

    This is the API contract between the natural language topology builder
    and the appliance system.
    """
    # What appliance
    appliance_type: str            # Key into APPLIANCE_REGISTRY or category

    # Where in topology
    node_id: int
    node_name: str
    x: float = 100.0
    y: float = 100.0

    # Network configuration
    interfaces: List[Dict[str, Any]] = field(default_factory=list)
    # Each interface: {"name": "eth0", "ip": "10.0.1.1", "mask": 24, "zone": "wan"}

    # Configuration overrides
    config_overrides: Dict[str, Any] = field(default_factory=dict)
    # e.g., {"enable_nat": True, "enable_dhcp": True, "dhcp_range": "10.0.1.100-200"}

    # Custom compose variables (for Mako templating)
    compose_vars: Dict[str, Any] = field(default_factory=dict)


# =============================================================================
# APPLIANCE REGISTRY
# =============================================================================

# Templates directory (relative to this file)
TEMPLATES_DIR = Path(__file__).parent.parent / "templates" / "appliances"


APPLIANCE_REGISTRY: Dict[str, ApplianceSpec] = {

    # =========================================================================
    # ROUTERS / FIREWALLS
    # =========================================================================

    "vyos": ApplianceSpec(
        name="vyos",
        display_name="VyOS Router/Firewall",
        description="Full-featured open-source router/firewall based on Debian. "
                    "Supports BGP, OSPF, firewall rules, NAT, VPN, and more.",
        category=ApplianceCategory.FIREWALL,
        keywords=["vyos", "firewall", "router", "gateway", "nat", "vpn",
                  "bgp", "ospf", "network", "perimeter"],
        image="2stacks/vyos",
        image_tag="latest",
        base_image="Debian-based VyOS (2stacks community image)",
        compose=ComposeSpec(
            template_file="vyos-compose.yml",
            service_name="vyos",
        ),
        supports_multi_nic=True,
        min_interfaces=2,
        max_interfaces=8,
        interfaces=[
            InterfaceSpec("eth0", "wan", "WAN/External interface", "WAN"),
            InterfaceSpec("eth1", "lan", "LAN/Internal interface", "LAN"),
            InterfaceSpec("eth2", "dmz", "DMZ interface (optional)", "DMZ"),
            InterfaceSpec("eth3", "ot", "OT network interface (optional)", "OT"),
        ],
        privileged=True,
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "config": "/config/config.boot",
        },
        volumes=[
            VolumeSpec("/config", "VyOS configuration directory", required=False),
        ],
        ports=[22, 443, 8443],
        health_check="pgrep vyattad",
        startup_time=30,
        network_roles=[NetworkRole.PERIMETER, NetworkRole.INTERNAL, NetworkRole.OT_IT_BOUNDARY],
        typical_placement="Between network zones (IT/OT boundary, perimeter, DMZ)",
    ),

    "frr": ApplianceSpec(
        name="frr",
        display_name="FRRouting (FRR)",
        description="Modern IP routing protocol suite supporting BGP, OSPF, IS-IS, RIP, "
                    "PIM, LDP, VRRP. Lightweight alternative to full router OS.",
        category=ApplianceCategory.ROUTER,
        keywords=["frr", "frrouting", "router", "bgp", "ospf", "routing",
                  "quagga", "zebra", "dynamic routing"],
        image="frrouting/frr",
        image_tag="latest",
        base_image="Alpine Linux + FRRouting",
        compose=ComposeSpec(
            template_file="frr-compose.yml",
            service_name="frr",
        ),
        supports_multi_nic=True,
        min_interfaces=2,
        max_interfaces=16,
        interfaces=[
            InterfaceSpec("eth0", "uplink", "Uplink/WAN interface"),
            InterfaceSpec("eth1", "lan", "LAN interface"),
        ],
        privileged=True,
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "frr_conf": "/etc/frr/frr.conf",
            "daemons": "/etc/frr/daemons",
        },
        volumes=[
            VolumeSpec("/etc/frr", "FRR configuration directory", required=True,
                      default_template="frr-default.conf"),
        ],
        ports=[179, 2601, 2605],  # BGP, zebra vty, bgpd vty
        health_check="vtysh -c 'show version'",
        startup_time=10,
        network_roles=[NetworkRole.CORE, NetworkRole.INTERNAL],
        typical_placement="Core routing, inter-VLAN routing",
    ),

    "iptables-firewall": ApplianceSpec(
        name="iptables-firewall",
        display_name="Linux iptables Firewall",
        description="Lightweight Linux firewall using iptables/nftables. "
                    "Good for simple firewalling without full router features.",
        category=ApplianceCategory.FIREWALL,
        keywords=["iptables", "nftables", "firewall", "linux", "simple",
                  "lightweight", "packet filter"],
        image="alpine-firewall-core",  # Custom image we build
        image_tag="latest",
        base_image="Alpine Linux + iptables",
        supports_multi_nic=True,
        min_interfaces=2,
        max_interfaces=4,
        interfaces=[
            InterfaceSpec("eth0", "external", "External/untrusted interface"),
            InterfaceSpec("eth1", "internal", "Internal/trusted interface"),
        ],
        privileged=True,
        config_method=ConfigMethod.INIT_SCRIPT,
        config_paths={
            "rules": "/etc/iptables/rules.v4",
            "init_script": "/etc/init.d/firewall",
        },
        volumes=[
            VolumeSpec("/etc/iptables", "iptables rules directory", required=False),
        ],
        ports=[],
        health_check="iptables -L -n",
        startup_time=5,
        network_roles=[NetworkRole.INTERNAL, NetworkRole.OT_IT_BOUNDARY],
        typical_placement="Simple zone separation, OT/IT boundary",
    ),

    # =========================================================================
    # SECURITY APPLIANCES
    # =========================================================================

    "suricata": ApplianceSpec(
        name="suricata",
        display_name="Suricata IDS/IPS",
        description="High-performance Network IDS, IPS and Security Monitoring engine. "
                    "Supports rules-based detection and protocol analysis.",
        category=ApplianceCategory.IDS_IPS,
        keywords=["suricata", "ids", "ips", "intrusion", "detection",
                  "security", "monitoring", "nids"],
        image="jasonish/suricata",
        image_tag="latest",
        base_image="Ubuntu + Suricata",
        compose=ComposeSpec(
            template_file="suricata-compose.yml",
            service_name="suricata",
        ),
        supports_multi_nic=True,
        min_interfaces=1,
        max_interfaces=4,
        interfaces=[
            InterfaceSpec("eth0", "monitor", "Monitor/span interface"),
            InterfaceSpec("eth1", "management", "Management interface"),
        ],
        privileged=True,
        capabilities=["NET_ADMIN", "NET_RAW", "SYS_NICE"],
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "suricata_yaml": "/etc/suricata/suricata.yaml",
            "rules": "/var/lib/suricata/rules",
        },
        volumes=[
            VolumeSpec("/var/log/suricata", "Suricata logs", required=False),
            VolumeSpec("/var/lib/suricata", "Suricata data (rules, etc.)", required=False),
        ],
        ports=[],
        health_check="suricatasc -c uptime",
        startup_time=15,
        network_roles=[NetworkRole.INTERNAL, NetworkRole.PERIMETER],
        typical_placement="Inline or span port for traffic inspection",
    ),

    # =========================================================================
    # LOAD BALANCERS / PROXIES
    # =========================================================================

    "haproxy": ApplianceSpec(
        name="haproxy",
        display_name="HAProxy Load Balancer",
        description="High-performance TCP/HTTP load balancer. "
                    "Supports health checks, SSL termination, rate limiting.",
        category=ApplianceCategory.LOAD_BALANCER,
        keywords=["haproxy", "load balancer", "lb", "proxy", "reverse proxy",
                  "http", "tcp", "ssl"],
        image="haproxy",
        image_tag="latest",
        base_image="Alpine Linux + HAProxy",
        compose=ComposeSpec(
            template_file="haproxy-compose.yml",
            service_name="haproxy",
        ),
        supports_multi_nic=True,
        min_interfaces=1,
        max_interfaces=2,
        interfaces=[
            InterfaceSpec("eth0", "frontend", "Frontend/client-facing interface"),
            InterfaceSpec("eth1", "backend", "Backend/server-facing interface (optional)"),
        ],
        privileged=True,
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "haproxy_cfg": "/usr/local/etc/haproxy/haproxy.cfg",
        },
        volumes=[
            VolumeSpec("/usr/local/etc/haproxy", "HAProxy configuration", required=True,
                      default_template="haproxy-default.cfg"),
        ],
        ports=[80, 443, 8404],  # HTTP, HTTPS, stats
        health_check="haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg",
        startup_time=5,
        network_roles=[NetworkRole.DMZ, NetworkRole.INTERNAL],
        typical_placement="In front of web server farms, API gateways",
    ),

    # =========================================================================
    # VPN GATEWAYS
    # =========================================================================

    "wireguard": ApplianceSpec(
        name="wireguard",
        display_name="WireGuard VPN Gateway",
        description="Modern, fast VPN using WireGuard protocol. "
                    "Simple configuration, excellent performance.",
        category=ApplianceCategory.VPN_GATEWAY,
        keywords=["wireguard", "vpn", "tunnel", "gateway", "remote access",
                  "site to site", "wg"],
        image="linuxserver/wireguard",
        image_tag="latest",
        base_image="Alpine Linux + WireGuard",
        compose=ComposeSpec(
            template_file="wireguard-compose.yml",
            service_name="wireguard",
        ),
        supports_multi_nic=True,
        min_interfaces=1,
        max_interfaces=2,
        interfaces=[
            InterfaceSpec("eth0", "wan", "WAN interface for VPN traffic"),
            InterfaceSpec("eth1", "lan", "LAN interface (optional)"),
        ],
        privileged=True,
        capabilities=["NET_ADMIN", "SYS_MODULE"],
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "wg_conf": "/config/wg0.conf",
        },
        volumes=[
            VolumeSpec("/config", "WireGuard configuration", required=True),
        ],
        ports=[51820],  # Default WireGuard port
        health_check="wg show",
        startup_time=5,
        network_roles=[NetworkRole.PERIMETER, NetworkRole.INTERNAL],
        typical_placement="Edge for remote access, site-to-site tunnels",
    ),

    # =========================================================================
    # FUTURE: OT/ICS APPLIANCES (Placeholders)
    # =========================================================================

    # These will be extended when we implement OpenPLC and OT-sim support

    "openplc": ApplianceSpec(
        name="openplc",
        display_name="OpenPLC Runtime",
        description="IEC 61131-3 compliant PLC runtime. Supports Ladder, "
                    "Structured Text, FBD, IL, SFC. Web interface on 8080, Modbus on 502.",
        category=ApplianceCategory.PLC,
        keywords=["openplc", "plc", "ics", "scada", "ot", "modbus",
                  "ladder", "structured text", "industrial", "controller"],
        image="openplc-core",
        image_tag="latest",
        base_image="openplc/openplc-runtime",
        compose=ComposeSpec(
            template_file="openplc-compose.yml",
            service_name="openplc",
        ),
        supports_multi_nic=True,
        min_interfaces=1,
        max_interfaces=2,
        interfaces=[
            InterfaceSpec("eth0", "ot", "OT network interface"),
            InterfaceSpec("eth1", "engineering", "Engineering workstation network (optional)"),
        ],
        privileged=True,
        config_method=ConfigMethod.BIND_MOUNT,
        config_paths={
            "program": "/workdir/program.st",
            "mbconfig": "/workdir/mbconfig.cfg",
        },
        volumes=[
            VolumeSpec("/workdir", "OpenPLC working directory", required=False),
        ],
        ports=[8080, 502],  # Web UI, Modbus TCP
        health_check="curl -s http://localhost:8080 > /dev/null",
        startup_time=15,
        network_roles=[NetworkRole.ENDPOINT],
        typical_placement="OT network, controlling field devices",
        # Future: plc_program field will link to ST/LD source
    ),

    # =========================================================================
    # HMI / WORKSTATIONS
    # =========================================================================

    "hmi-workstation": ApplianceSpec(
        name="hmi-workstation",
        display_name="HMI Workstation with Browser",
        description="Ubuntu-based workstation with Firefox browser and VNC access. "
                    "Use for accessing web interfaces (OpenPLC, SCADA) from within CORE networks. "
                    "VNC available on port 5900.",
        category=ApplianceCategory.HMI,
        keywords=["hmi", "workstation", "browser", "firefox", "vnc", "desktop",
                  "gui", "operator", "scada", "engineering"],
        image="hmi-workstation",
        image_tag="latest",
        base_image="Ubuntu 22.04 + Firefox + Fluxbox + VNC",
        supports_multi_nic=True,
        min_interfaces=1,
        max_interfaces=2,
        interfaces=[
            InterfaceSpec("eth0", "ot", "OT network interface - access PLCs/HMIs"),
            InterfaceSpec("eth1", "management", "Management network (optional)"),
        ],
        privileged=False,
        config_method=ConfigMethod.NONE,
        config_paths={},
        volumes=[],
        ports=[5900],  # VNC
        health_check="pgrep Xvfb",
        startup_time=10,
        network_roles=[NetworkRole.ENDPOINT],
        typical_placement="OT network, operator console for viewing HMI/SCADA",
    ),
}


# =============================================================================
# REGISTRY FUNCTIONS
# =============================================================================

def get_appliance(name: str) -> Optional[ApplianceSpec]:
    """
    Look up an appliance by name or keyword.

    Args:
        name: Appliance name, keyword, or category

    Returns:
        ApplianceSpec or None if not found
    """
    name_lower = name.lower().strip()

    # Direct match
    if name_lower in APPLIANCE_REGISTRY:
        return APPLIANCE_REGISTRY[name_lower]

    # Keyword match
    for app_name, spec in APPLIANCE_REGISTRY.items():
        if any(kw in name_lower for kw in spec.keywords):
            return spec

    # Category match (return first of that category)
    try:
        category = ApplianceCategory(name_lower)
        for spec in APPLIANCE_REGISTRY.values():
            if spec.category == category:
                return spec
    except ValueError:
        pass

    return None


def get_appliance_for_role(role: NetworkRole) -> List[ApplianceSpec]:
    """Get all appliances suitable for a network role."""
    return [
        spec for spec in APPLIANCE_REGISTRY.values()
        if role in spec.network_roles
    ]


def list_appliances(category: Optional[ApplianceCategory] = None) -> List[ApplianceSpec]:
    """List all appliances, optionally filtered by category."""
    if category:
        return [s for s in APPLIANCE_REGISTRY.values() if s.category == category]
    return list(APPLIANCE_REGISTRY.values())


def get_firewall_for_boundary(boundary_type: str) -> Optional[ApplianceSpec]:
    """
    Get recommended firewall for a specific boundary type.

    Used by topology generator when it detects zone boundaries.

    Args:
        boundary_type: "it_ot", "perimeter", "dmz", "internal"
    """
    role_map = {
        "it_ot": NetworkRole.OT_IT_BOUNDARY,
        "ot_it": NetworkRole.OT_IT_BOUNDARY,
        "perimeter": NetworkRole.PERIMETER,
        "edge": NetworkRole.PERIMETER,
        "dmz": NetworkRole.DMZ,
        "internal": NetworkRole.INTERNAL,
    }

    role = role_map.get(boundary_type.lower())
    if not role:
        return get_appliance("vyos")  # Default to VyOS

    candidates = get_appliance_for_role(role)

    # Prefer VyOS for full-featured firewalls, iptables for simple cases
    for spec in candidates:
        if spec.category == ApplianceCategory.FIREWALL:
            return spec

    return candidates[0] if candidates else get_appliance("vyos")


# =============================================================================
# IMAGE AVAILABILITY
# =============================================================================

def check_image_available(image_name: str, tag: str = "latest") -> bool:
    """
    Check if a Docker image is available locally.

    Args:
        image_name: Image name (e.g., "vyos/vyos")
        tag: Image tag (e.g., "current")

    Returns:
        True if image exists locally, False otherwise
    """
    full_name = f"{image_name}:{tag}"
    try:
        result = subprocess.run(
            ["docker", "image", "inspect", full_name],
            capture_output=True,
            timeout=10
        )
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return False


def check_appliance_ready(spec: ApplianceSpec) -> Dict[str, Any]:
    """
    Check if an appliance is ready to be deployed.

    Returns a status dict with:
    - ready: bool
    - image_available: bool
    - missing_templates: List[str]
    - warnings: List[str]
    """
    status = {
        "ready": True,
        "image_available": False,
        "missing_templates": [],
        "warnings": [],
    }

    # Check image
    status["image_available"] = check_image_available(spec.image, spec.image_tag)
    if not status["image_available"]:
        status["ready"] = False
        status["warnings"].append(
            f"Image {spec.full_image_name()} not found locally. "
            f"Run: docker pull {spec.full_image_name()}"
        )

    # Check compose template if needed
    if spec.compose:
        template_path = TEMPLATES_DIR / spec.compose.template_file
        if not template_path.exists():
            status["ready"] = False
            status["missing_templates"].append(spec.compose.template_file)
            status["warnings"].append(
                f"Compose template not found: {template_path}"
            )

    return status


def verify_all_appliances() -> Dict[str, Dict[str, Any]]:
    """
    Verify all registered appliances are ready to deploy.

    Returns dict mapping appliance name to status.
    """
    return {
        name: check_appliance_ready(spec)
        for name, spec in APPLIANCE_REGISTRY.items()
    }


# =============================================================================
# COMPOSE TEMPLATE HELPERS
# =============================================================================

def get_compose_template_path(spec: ApplianceSpec) -> Optional[Path]:
    """Get the full path to an appliance's compose template."""
    if not spec.compose:
        return None
    return TEMPLATES_DIR / spec.compose.template_file


def render_compose_template(
    spec: ApplianceSpec,
    node_name: str,
    hostname: str,
    extra_vars: Optional[Dict[str, Any]] = None
) -> Optional[str]:
    """
    Render a compose template with Mako.

    Args:
        spec: Appliance specification
        node_name: CORE node name
        hostname: Container hostname
        extra_vars: Additional template variables

    Returns:
        Rendered compose file content, or None if no compose template
    """
    if not spec.compose:
        return None

    template_path = get_compose_template_path(spec)
    if not template_path or not template_path.exists():
        return None

    try:
        from mako.template import Template

        with open(template_path, 'r') as f:
            template = Template(f.read())

        vars_dict = {
            "node": {"name": node_name},
            "hostname": hostname,
            "appliance": spec,
            **(extra_vars or {})
        }

        return template.render(**vars_dict)
    except ImportError:
        # Mako not installed, return raw template
        with open(template_path, 'r') as f:
            return f.read()
    except Exception as e:
        raise RuntimeError(f"Failed to render compose template: {e}")


# =============================================================================
# CONFIGURATION GENERATION
# =============================================================================

def generate_firewall_config(
    spec: ApplianceSpec,
    interfaces: List[Dict[str, Any]],
    enable_nat: bool = True,
    enable_dhcp: bool = False,
    dhcp_range: Optional[str] = None,
    custom_rules: Optional[List[str]] = None
) -> Dict[str, str]:
    """
    Generate firewall configuration files.

    Args:
        spec: Appliance specification
        interfaces: List of interface configs [{"name": "eth0", "ip": "...", "zone": "wan"}, ...]
        enable_nat: Enable NAT/masquerading on WAN interface
        enable_dhcp: Enable DHCP server on LAN interface
        dhcp_range: DHCP range (e.g., "10.0.1.100-10.0.1.200")
        custom_rules: Additional firewall rules

    Returns:
        Dict mapping config file names to content
    """
    configs = {}

    if spec.name == "vyos":
        configs["config.boot"] = _generate_vyos_config(
            interfaces, enable_nat, enable_dhcp, dhcp_range, custom_rules
        )
    elif spec.name == "frr":
        configs["frr.conf"] = _generate_frr_config(interfaces)
        configs["daemons"] = _generate_frr_daemons()
    elif spec.name == "iptables-firewall":
        configs["rules.v4"] = _generate_iptables_rules(
            interfaces, enable_nat, custom_rules
        )

    return configs


def _generate_vyos_config(
    interfaces: List[Dict[str, Any]],
    enable_nat: bool,
    enable_dhcp: bool,
    dhcp_range: Optional[str],
    custom_rules: Optional[List[str]]
) -> str:
    """Generate VyOS config.boot content."""
    lines = [
        "interfaces {",
    ]

    wan_iface = None
    lan_iface = None

    for iface in interfaces:
        name = iface.get("name", "eth0")
        ip = iface.get("ip", "")
        mask = iface.get("mask", 24)
        zone = iface.get("zone", "").lower()

        lines.append(f"    ethernet {name} {{")
        if ip:
            lines.append(f"        address {ip}/{mask}")
        lines.append(f"        description \"{zone.upper()} interface\"")
        lines.append("    }")

        if zone in ["wan", "external", "untrusted"]:
            wan_iface = name
        elif zone in ["lan", "internal", "trusted"]:
            lan_iface = name

    lines.append("}")

    # NAT configuration
    if enable_nat and wan_iface:
        lines.extend([
            "nat {",
            "    source {",
            "        rule 100 {",
            f"            outbound-interface {wan_iface}",
            "            source {",
            "                address 0.0.0.0/0",
            "            }",
            "            translation {",
            "                address masquerade",
            "            }",
            "        }",
            "    }",
            "}",
        ])

    # Firewall zones
    lines.extend([
        "firewall {",
        "    all-ping enable",
        "    broadcast-ping disable",
        "    state-policy {",
        "        established action accept",
        "        related action accept",
        "        invalid action drop",
        "    }",
        "}",
    ])

    # System configuration
    lines.extend([
        "system {",
        "    host-name vyos-firewall",
        "    login {",
        "        user vyos {",
        "            authentication {",
        "                plaintext-password vyos",
        "            }",
        "        }",
        "    }",
        "}",
    ])

    return "\n".join(lines)


def _generate_frr_config(interfaces: List[Dict[str, Any]]) -> str:
    """Generate FRR frr.conf content."""
    lines = [
        "frr version 8.5",
        "frr defaults traditional",
        "hostname frr-router",
        "log syslog informational",
        "service integrated-vtysh-config",
        "!",
    ]

    for iface in interfaces:
        name = iface.get("name", "eth0")
        ip = iface.get("ip", "")
        mask = iface.get("mask", 24)

        if ip:
            lines.extend([
                f"interface {name}",
                f" ip address {ip}/{mask}",
                "!",
            ])

    lines.extend([
        "router ospf",
        " ospf router-id 1.1.1.1",
        " redistribute connected",
        "!",
        "line vty",
        "!",
    ])

    return "\n".join(lines)


def _generate_frr_daemons() -> str:
    """Generate FRR daemons file."""
    return """zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
pimd=no
ldpd=no
nhrpd=no
eigrpd=no
babeld=no
sharpd=no
pbrd=no
bfdd=no
fabricd=no
vrrpd=no
"""


def _generate_iptables_rules(
    interfaces: List[Dict[str, Any]],
    enable_nat: bool,
    custom_rules: Optional[List[str]]
) -> str:
    """Generate iptables rules.v4 content."""
    lines = [
        "*filter",
        ":INPUT DROP [0:0]",
        ":FORWARD DROP [0:0]",
        ":OUTPUT ACCEPT [0:0]",
        "",
        "# Allow established connections",
        "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT",
        "-A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT",
        "",
        "# Allow loopback",
        "-A INPUT -i lo -j ACCEPT",
        "",
        "# Allow ICMP",
        "-A INPUT -p icmp -j ACCEPT",
        "-A FORWARD -p icmp -j ACCEPT",
        "",
    ]

    # Find WAN and LAN interfaces
    wan_iface = None
    lan_iface = None

    for iface in interfaces:
        zone = iface.get("zone", "").lower()
        name = iface.get("name", "")

        if zone in ["wan", "external"]:
            wan_iface = name
        elif zone in ["lan", "internal"]:
            lan_iface = name

    # Forward from LAN to WAN
    if lan_iface and wan_iface:
        lines.extend([
            f"# Allow LAN to WAN",
            f"-A FORWARD -i {lan_iface} -o {wan_iface} -j ACCEPT",
            "",
        ])

    # Custom rules
    if custom_rules:
        lines.append("# Custom rules")
        lines.extend(custom_rules)
        lines.append("")

    lines.append("COMMIT")

    # NAT table
    if enable_nat and wan_iface:
        lines.extend([
            "",
            "*nat",
            ":PREROUTING ACCEPT [0:0]",
            ":INPUT ACCEPT [0:0]",
            ":OUTPUT ACCEPT [0:0]",
            ":POSTROUTING ACCEPT [0:0]",
            "",
            f"-A POSTROUTING -o {wan_iface} -j MASQUERADE",
            "",
            "COMMIT",
        ])

    return "\n".join(lines)
