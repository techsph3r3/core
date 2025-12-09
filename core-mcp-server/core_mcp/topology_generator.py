"""
Topology Generator - Converts natural language to CORE network topologies.

NETWORK ENGINEERING RULES (enforced by this generator):
==========================================

1. LAYER 2 DEVICES (Switch/Hub):
   - All connected devices MUST be on the same subnet
   - Switches/hubs cannot route between different subnets
   - Example: All hosts on switch use 10.0.1.2/24, 10.0.1.3/24, 10.0.1.4/24

2. LAYER 3 DEVICES (Routers):
   - Each router-to-router link is a separate subnet
   - Each router interface to different networks uses different subnets
   - Example: R1-R2 link uses 10.0.1.0/24, R2-R3 link uses 10.0.2.0/24

3. STAR TOPOLOGY:
   - If central node is Switch/Hub → same subnet for all spokes
   - If central node is Router → different subnet for each spoke

4. WIRELESS NETWORKS:
   - All nodes on same WLAN are on the same subnet
   - WLAN operates at Layer 2 (like a wireless switch)

5. DHCP/STATIC ADDRESSING:
   - Hosts use DHCP or static addresses within their subnet
   - Routers use static addresses on their interfaces

These rules can be overridden by explicit user specifications.
"""

import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
import xml.etree.ElementTree as ET
from xml.dom import minidom
from pathlib import Path

# Import appliance registry for network appliances (firewalls, routers, etc.)
try:
    from .appliance_registry import (
        APPLIANCE_REGISTRY,
        get_appliance,
        get_firewall_for_boundary,
        check_appliance_ready,
        ApplianceSpec,
        ApplianceCategory,
        NetworkRole,
        TEMPLATES_DIR,
    )
    APPLIANCE_SUPPORT = True
except ImportError:
    APPLIANCE_SUPPORT = False
    APPLIANCE_REGISTRY = {}


# =============================================================================
# CORE-COMPATIBLE DOCKER IMAGE REGISTRY
# =============================================================================
# Each entry defines a Docker image that has been wrapped for CORE compatibility.
# These images have iproute2, ethtool, iputils-ping, net-tools, tcpdump installed.
#
# To add a new image:
# 1. Create Dockerfile wrapping the base image (see dockerfiles/Dockerfile.nginx-core)
# 2. Build it: docker build -t <name>-core -f Dockerfile.<name>-core .
# 3. Add entry here with metadata
# =============================================================================

DOCKER_IMAGE_REGISTRY = {
    "nginx": {
        "image": "nginx-core",
        "base_image": "nginx:latest",
        "description": "Nginx web server - serves HTTP on port 80",
        "default_services": [],  # Nginx runs via entrypoint, not CORE services
        "ports": [80, 443],
        "category": "web",
        "keywords": ["nginx", "web", "http", "webserver", "web server"],
    },
    "ubuntu": {
        "image": "ubuntu:22.04",
        "base_image": "ubuntu:22.04",
        "description": "Ubuntu base image for general purpose containers",
        "default_services": [],
        "ports": [],
        "category": "base",
        "keywords": ["ubuntu", "linux", "base", "general"],
    },
    "alpine": {
        "image": "alpine:latest",
        "base_image": "alpine:latest",
        "description": "Lightweight Alpine Linux",
        "default_services": [],
        "ports": [],
        "category": "base",
        "keywords": ["alpine", "lightweight", "minimal"],
    },
    "caldera": {
        "image": "caldera-mcp-core",
        "base_image": "mitre/caldera (built from source with MCP plugin)",
        "description": "MITRE Caldera adversary emulation platform with MCP plugin - Web UI on port 8888, default creds: red/admin or blue/admin",
        "default_services": [],
        "ports": [8888, 7010, 7011, 7012, 8022, 5000],
        "category": "security",
        "keywords": ["caldera", "mitre", "adversary", "red team", "security", "c2", "attack", "apt", "emulation"],
    },
    "openplc": {
        "image": "openplc-core",
        "base_image": "openplc/openplc-runtime",
        "description": "OpenPLC Runtime - IEC 61131-3 PLC with web interface on port 8080. Supports Ladder, ST, FBD, IL, SFC.",
        "default_services": [],
        "ports": [8080, 502],  # Web UI + Modbus
        "category": "ot",
        "keywords": ["openplc", "plc", "ics", "scada", "ot", "modbus", "ladder", "structured text", "industrial"],
    },
    "kali": {
        "image": "kali-novnc-core",
        "base_image": "kalilinux/kali-rolling",
        "description": "Kali Linux with noVNC desktop - access via browser on port 6080. Full penetration testing toolkit.",
        "default_services": [],
        "ports": [6080, 5901, 22],  # noVNC, VNC, SSH
        "category": "security",
        "keywords": ["kali", "pentest", "security", "hacking", "red team", "offensive", "vnc", "novnc", "desktop"],
    },
    "mqtt-broker": {
        "image": "mqtt-broker-core",
        "base_image": "eclipse-mosquitto:2",
        "description": "Eclipse Mosquitto MQTT broker for IoT sensor data. Ports: 1883 (MQTT), 9001 (WebSocket).",
        "default_services": [],
        "ports": [1883, 9001],
        "category": "iot",
        "keywords": ["mqtt", "mosquitto", "broker", "iot", "sensor", "pubsub", "message"],
    },
    "iot-sensor-server": {
        "image": "iot-sensor-server",
        "base_image": "python:3.11-alpine",
        "description": "IoT Sensor Data Server - subscribes to MQTT and serves web dashboard on port 80.",
        "default_services": [],
        "ports": [80],
        "category": "iot",
        "keywords": ["iot", "sensor", "server", "display", "dashboard", "data"],
    },
    "hmi-workstation": {
        "image": "hmi-workstation:latest",
        "base_image": "ubuntu:22.04",
        "description": "HMI Workstation with noVNC desktop and Firefox browser for accessing sensor displays.",
        "default_services": [],
        "ports": [6080, 5901],
        "category": "ot",
        "keywords": ["hmi", "workstation", "desktop", "browser", "operator", "scada"],
    },
}


def get_docker_image(name: str) -> Optional[Dict]:
    """
    Look up a Docker image by name or keyword.
    Returns the image configuration or None if not found.
    """
    name_lower = name.lower()

    # Direct match
    if name_lower in DOCKER_IMAGE_REGISTRY:
        return DOCKER_IMAGE_REGISTRY[name_lower]

    # Keyword match
    for img_name, config in DOCKER_IMAGE_REGISTRY.items():
        if any(kw in name_lower for kw in config.get("keywords", [])):
            return config

    return None


def list_available_docker_images() -> List[Dict]:
    """Return list of all available Docker images with their metadata."""
    return [
        {"name": name, **config}
        for name, config in DOCKER_IMAGE_REGISTRY.items()
    ]


@dataclass
class NodeConfig:
    """Configuration for a network node."""
    node_id: int
    name: str
    node_type: str  # router, switch, hub, host, pc, mdr, wireless, emane, docker
    x: float = 100.0
    y: float = 100.0
    model: Optional[str] = None
    image: Optional[str] = None
    services: List[str] = field(default_factory=list)
    # Compose support for complex appliances
    compose: Optional[str] = None       # Path to compose file
    compose_name: Optional[str] = None  # Service name in compose file
    # Appliance metadata
    appliance_type: Optional[str] = None  # Key into APPLIANCE_REGISTRY
    interfaces: List[Dict] = field(default_factory=list)  # Interface configs


@dataclass
class LinkConfig:
    """Configuration for a link between nodes."""
    node1_id: int
    node2_id: int
    iface1_id: Optional[int] = None
    iface2_id: Optional[int] = None
    ip4_1: Optional[str] = None
    ip4_2: Optional[str] = None
    bandwidth: int = 100000000  # 100 Mbps
    delay: int = 0  # microseconds
    loss: float = 0.0  # percentage
    jitter: int = 0  # microseconds


@dataclass
class ServiceConfig:
    """Configuration for a service on a node."""
    node_id: int
    service_name: str
    config: Dict[str, str] = field(default_factory=dict)


@dataclass
class StartupScript:
    """Configuration for a startup script on a node."""
    node_id: int
    script_content: str
    delay_seconds: int = 0  # Delay before running the script


@dataclass
class WLANConfig:
    """Configuration for a WLAN node."""
    node_id: int
    range_meters: int = 275
    bandwidth: int = 54000000
    delay: int = 20000
    jitter: int = 0
    loss: float = 0.0


class TopologyGenerator:
    """
    Generates CORE network topologies from natural language descriptions
    or programmatic API calls.
    """

    def __init__(self):
        self.nodes: Dict[int, NodeConfig] = {}
        self.links: List[LinkConfig] = []
        self.wlan_configs: Dict[int, WLANConfig] = {}
        self.startup_scripts: Dict[int, StartupScript] = {}  # node_id -> StartupScript
        self.session_name: str = "Generated Topology"
        self.next_subnet_id: int = 0

        # Caldera/Sandcat deployment tracking
        self.caldera_server_ip: Optional[str] = None
        self.sandcat_deployment: Optional[Dict] = None
        self.auto_deploy: bool = True  # Auto-deploy agents when session starts

        # Canvas dimensions for proper layout (fits typical screen)
        self.canvas_width = 1000
        self.canvas_height = 700
        self.center_x = self.canvas_width / 2
        self.center_y = self.canvas_height / 2
        self.margin = 80  # Keep nodes away from edges

    def clear(self):
        """Clear all topology data."""
        self.nodes.clear()
        self.links.clear()
        self.wlan_configs.clear()
        self.startup_scripts.clear()
        self.caldera_server_ip = None
        self.sandcat_deployment = None
        self.next_subnet_id = 0

    def add_startup_script(self, node_id: int, script_content: str, delay_seconds: int = 0):
        """Add a startup script to a node that runs when the session starts."""
        self.startup_scripts[node_id] = StartupScript(
            node_id=node_id,
            script_content=script_content,
            delay_seconds=delay_seconds
        )

    def add_node(self, node: NodeConfig):
        """Add a node to the topology."""
        self.nodes[node.node_id] = node

    def add_link(self, link: LinkConfig):
        """Add a link to the topology."""
        self.links.append(link)

    def add_appliance(
        self,
        node_id: int,
        name: str,
        appliance_type: str,
        x: float = 100.0,
        y: float = 100.0,
        interfaces: Optional[List[Dict[str, Any]]] = None,
        config_overrides: Optional[Dict[str, Any]] = None,
    ) -> Optional[NodeConfig]:
        """
        Add a network appliance (firewall, router, IDS, etc.) to the topology.

        This method handles the complexity of compose-based appliances,
        multi-interface configuration, and configuration seeding.

        Args:
            node_id: Unique node ID
            name: Node name (e.g., "fw1", "router1")
            appliance_type: Key into APPLIANCE_REGISTRY (e.g., "vyos", "frr")
            x, y: Canvas position
            interfaces: List of interface configs [{"name": "eth0", "ip": "10.0.1.1", "mask": 24, "zone": "wan"}]
            config_overrides: Extra config (enable_nat, enable_dhcp, etc.)

        Returns:
            NodeConfig if successful, None if appliance not found
        """
        if not APPLIANCE_SUPPORT:
            # Fall back to simple docker node
            node = NodeConfig(
                node_id=node_id,
                name=name,
                node_type="docker",
                image="alpine:latest",
                x=x,
                y=y,
            )
            self.add_node(node)
            return node

        spec = get_appliance(appliance_type)
        if not spec:
            return None

        # For now, use image-only mode (no compose) for better compatibility
        # Compose requires templates to be accessible inside CORE container
        # TODO: Enable compose when templates are properly deployed to CORE container
        #
        # compose_path = None
        # compose_name = None
        # if spec.compose:
        #     compose_path = "/opt/core-mcp/templates/appliances/" + spec.compose.template_file
        #     compose_name = spec.compose.service_name

        # Create the node config - using image-only mode
        node = NodeConfig(
            node_id=node_id,
            name=name,
            node_type="docker",
            image=spec.full_image_name(),
            x=x,
            y=y,
            services=spec.core_services,
            compose=None,  # Disabled for now - use image-only mode
            compose_name=None,
            appliance_type=appliance_type,
            interfaces=interfaces or [],
        )

        self.add_node(node)
        return node

    def get_available_appliances(self) -> List[Dict[str, Any]]:
        """
        Get list of available appliances for the topology generator.

        Returns list of appliance info suitable for UI display or AI context.
        """
        if not APPLIANCE_SUPPORT:
            return []

        return [
            {
                "name": spec.name,
                "display_name": spec.display_name,
                "description": spec.description,
                "category": spec.category.value,
                "keywords": spec.keywords,
                "supports_multi_nic": spec.supports_multi_nic,
                "min_interfaces": spec.min_interfaces,
                "max_interfaces": spec.max_interfaces,
                "typical_placement": spec.typical_placement,
            }
            for spec in APPLIANCE_REGISTRY.values()
        ]

    def verify_appliances(self) -> Dict[str, Any]:
        """
        Verify all appliances used in the current topology are ready.

        Returns:
            Dict with "ready" bool and "issues" list
        """
        if not APPLIANCE_SUPPORT:
            return {"ready": True, "issues": []}

        issues = []
        for node in self.nodes.values():
            if node.appliance_type:
                status = check_appliance_ready(get_appliance(node.appliance_type))
                if not status["ready"]:
                    issues.extend([
                        f"{node.name}: {warning}"
                        for warning in status["warnings"]
                    ])

        return {
            "ready": len(issues) == 0,
            "issues": issues,
        }

    def set_wlan_config(self, node_id: int, **kwargs):
        """Configure a WLAN node."""
        if node_id not in self.wlan_configs:
            self.wlan_configs[node_id] = WLANConfig(node_id=node_id)
        for key, value in kwargs.items():
            setattr(self.wlan_configs[node_id], key, value)

    def get_node_name(self, node_id: int) -> str:
        """Get node name by ID."""
        return self.nodes.get(node_id, NodeConfig(node_id, f"n{node_id}", "unknown")).name

    def generate_from_description(self, description: str) -> str:
        """
        Generate a topology from a natural language description.

        Examples:
        - "Create a simple network with 3 routers connected in a line"
        - "Build a star topology with a switch in the center and 5 hosts"
        - "Make a wireless mesh network with 4 MDR nodes"
        - "Create a tailscale mesh with 5 docker nodes running tailscale"
        - "Create 3 nginx web servers with 2 clients"
        - "Build a web server farm with 5 nginx containers"
        - "Create an IT/OT network with VyOS firewall"
        - "Create an OT network with Suricata IDS monitoring PLCs"
        - "Create a web farm with HAProxy load balancer"
        """
        description_lower = description.lower()

        # Parse node count
        node_count = self._extract_number(description_lower, default=3)

        # =================================================================
        # Check for APPLIANCE-BASED topologies FIRST (most specific)
        # =================================================================

        # IT/OT Network with Firewall
        if (("it" in description_lower and "ot" in description_lower) or
            "it/ot" in description_lower or "ot/it" in description_lower) and \
           any(fw in description_lower for fw in ["firewall", "vyos", "pfsense", "frr"]):
            return self._generate_it_ot_network(description)

        # OT Network with IDS
        if ("ot" in description_lower or "plc" in description_lower or "scada" in description_lower) and \
           any(ids in description_lower for ids in ["ids", "ips", "suricata", "monitor"]):
            return self._generate_ot_ids_network(description)

        # Load balanced web farm
        if any(lb in description_lower for lb in ["haproxy", "load balanc", "lb"]) and \
           any(web in description_lower for web in ["nginx", "web", "server", "backend"]):
            return self._generate_loadbalanced_webfarm(description)

        # VPN Gateway network
        if any(vpn in description_lower for vpn in ["vpn", "wireguard", "tunnel"]) and \
           any(net in description_lower for net in ["gateway", "remote", "connect"]):
            return self._generate_vpn_network(description)

        # Phone Sensor Network (phone accelerometer/gyroscope data via MQTT bridge)
        # Check this BEFORE IoT to catch "phone sensor" specifically
        if any(phone in description_lower for phone in ["phone", "mobile", "smartphone", "accelerometer", "gyroscope"]) and \
           any(net in description_lower for net in ["network", "deploy", "sensor", "stream"]):
            return self._generate_phone_sensor_network(description)

        # IoT Sensor Network (quick deploy for micro:bit/sensor integration)
        if any(iot in description_lower for iot in ["iot", "sensor", "mqtt", "micro:bit", "microbit"]) and \
           any(net in description_lower for net in ["network", "deploy", "quick", "template"]):
            return self._generate_iot_sensor_network(description)

        # =================================================================
        # Check for Docker application keywords (next priority)
        # =================================================================
        # Check each registered Docker image for keyword matches
        for app_name, config in DOCKER_IMAGE_REGISTRY.items():
            keywords = config.get("keywords", [])
            if any(kw in description_lower for kw in keywords):
                return self._generate_docker_app_topology(node_count, description, app_name)

        # =================================================================
        # Standard topology type detection
        # =================================================================
        if "star" in description_lower or "hub" in description_lower:
            return self._generate_star_topology(node_count, description)
        elif "mesh" in description_lower and "wireless" in description_lower:
            return self._generate_wireless_mesh(node_count, description)
        elif "mesh" in description_lower and ("tailscale" in description_lower or "docker" in description_lower):
            return self._generate_tailscale_mesh(node_count, description)
        elif "line" in description_lower or "chain" in description_lower:
            return self._generate_line_topology(node_count, description)
        elif "ring" in description_lower:
            return self._generate_ring_topology(node_count, description)
        else:
            # Default to simple network with switch
            return self._generate_star_topology(node_count, description)

    def _extract_number(self, text: str, default: int = 3) -> int:
        """Extract a number from text."""
        # Look for patterns like "3 routers", "five hosts", etc.
        word_to_num = {
            "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
            "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10
        }

        # Try to find digit
        match = re.search(r'\b(\d+)\b', text)
        if match:
            return int(match.group(1))

        # Try to find word
        for word, num in word_to_num.items():
            if word in text:
                return num

        return default

    def _generate_star_topology(self, node_count: int, description: str) -> str:
        """
        Generate a star topology following network engineering rules.

        Rules:
        - If central node is Switch/Hub (Layer 2): All spokes on SAME subnet
        - If central node is Router (Layer 3): Each spoke on DIFFERENT subnet
        """
        self.clear()

        # Determine central node type
        desc_lower = description.lower()
        if "switch" in desc_lower:
            central_type = "switch"
            central_name = "switch1"
        elif "hub" in desc_lower:
            central_type = "hub"
            central_name = "hub1"
        elif "router" in desc_lower and "center" in desc_lower:
            central_type = "router"
            central_name = "router1"
        else:
            # Default to switch for star topology
            central_type = "switch"
            central_name = "switch1"

        # Create central node
        is_layer2_central = central_type in ["switch", "hub"]

        if central_type == "router":
            services = ["zebra", "OSPFv2", "OSPFv3", "IPForward"]
        else:
            services = []

        central_node = NodeConfig(
            node_id=1,
            name=central_name,
            node_type=central_type,
            x=self.center_x,
            y=self.center_y,
            services=services
        )
        self.add_node(central_node)

        # Create peripheral nodes (routers or hosts)
        node_type = "router" if "router" in desc_lower and "center" not in desc_lower else "host"
        services = ["DefaultRoute"] if node_type == "host" else ["zebra", "OSPFv2", "OSPFv3", "IPForward"]

        # Calculate radius based on node count (more nodes = larger circle)
        import math
        base_radius = 180
        radius = min(base_radius + (node_count * 10),
                    (min(self.canvas_width, self.canvas_height) / 2) - self.margin)

        for i in range(node_count):
            angle = (2 * math.pi * i) / node_count - (math.pi / 2)  # Start from top
            x = self.center_x + radius * math.cos(angle)
            y = self.center_y + radius * math.sin(angle)

            node = NodeConfig(
                node_id=i + 2,
                name=f"{node_type}{i+1}",
                node_type=node_type,
                x=x,
                y=y,
                services=services
            )
            self.add_node(node)

            # Link to central node with proper IP addressing
            # CRITICAL RULE: Layer 2 devices (switch/hub) = same subnet for all
            #                Layer 3 devices (router) = different subnet per spoke
            if is_layer2_central:
                # Same subnet for all (10.0.1.0/24)
                link = LinkConfig(
                    node1_id=1,
                    node2_id=i + 2,
                    ip4_2=f"10.0.1.{i+2}",  # All on 10.0.1.0/24
                    bandwidth=100000000
                )
            else:
                # Different subnet for each spoke (10.0.1.0/24, 10.0.2.0/24, etc.)
                link = LinkConfig(
                    node1_id=1,
                    node2_id=i + 2,
                    ip4_1=f"10.0.{i+1}.1",   # Router interface
                    ip4_2=f"10.0.{i+1}.2",   # Spoke device interface
                    bandwidth=100000000
                )
            self.add_link(link)

        return f"Created star topology with 1 {central_type} and {node_count} {node_type}s"

    def _generate_line_topology(self, node_count: int, description: str) -> str:
        """
        Generate a line/chain topology following network engineering rules.

        Rules:
        - Routers: Each link is a separate subnet (router-to-router links)
        - Hosts: All on same subnet (hosts typically don't route)
        """
        self.clear()

        node_type = "router" if "router" in description.lower() else "host"
        services = ["DefaultRoute"] if node_type == "host" else ["zebra", "OSPFv2", "OSPFv3", "IPForward"]
        is_router = node_type == "router"

        # Calculate spacing to fit all nodes horizontally
        usable_width = self.canvas_width - (2 * self.margin)
        spacing = usable_width / max(node_count - 1, 1) if node_count > 1 else 0

        for i in range(node_count):
            node = NodeConfig(
                node_id=i + 1,
                name=f"{node_type}{i+1}",
                node_type=node_type,
                x=self.margin + (i * spacing),
                y=self.center_y,
                services=services
            )
            self.add_node(node)

            if i > 0:
                if is_router:
                    # Routers: Each link is separate subnet
                    link = LinkConfig(
                        node1_id=i,
                        node2_id=i + 1,
                        ip4_1=f"10.0.{i}.1",
                        ip4_2=f"10.0.{i}.2"
                    )
                else:
                    # Hosts: All on same subnet (10.0.1.0/24)
                    link = LinkConfig(
                        node1_id=i,
                        node2_id=i + 1,
                        ip4_1=f"10.0.1.{i}",
                        ip4_2=f"10.0.1.{i+1}"
                    )
                self.add_link(link)

        return f"Created line topology with {node_count} {node_type}s"

    def _generate_ring_topology(self, node_count: int, description: str) -> str:
        """
        Generate a ring topology following network engineering rules.

        Rules:
        - Routers: Each link is a separate subnet (router-to-router links)
        - Hosts: All on same subnet (hosts typically don't route)
        """
        self.clear()

        node_type = "router" if "router" in description.lower() else "host"
        services = ["DefaultRoute"] if node_type == "host" else ["zebra", "OSPFv2", "OSPFv3", "IPForward"]
        is_router = node_type == "router"

        import math
        # Calculate radius based on node count
        base_radius = 180
        radius = min(base_radius + (node_count * 8),
                    (min(self.canvas_width, self.canvas_height) / 2) - self.margin)

        for i in range(node_count):
            angle = (2 * math.pi * i) / node_count - (math.pi / 2)  # Start from top
            x = self.center_x + radius * math.cos(angle)
            y = self.center_y + radius * math.sin(angle)

            node = NodeConfig(
                node_id=i + 1,
                name=f"{node_type}{i+1}",
                node_type=node_type,
                x=x,
                y=y,
                services=services
            )
            self.add_node(node)

            # Link to previous node
            if i > 0:
                if is_router:
                    # Routers: Each link is separate subnet
                    link = LinkConfig(
                        node1_id=i,
                        node2_id=i + 1,
                        ip4_1=f"10.0.{i}.1",
                        ip4_2=f"10.0.{i}.2"
                    )
                else:
                    # Hosts: All on same subnet (10.0.1.0/24)
                    link = LinkConfig(
                        node1_id=i,
                        node2_id=i + 1,
                        ip4_1=f"10.0.1.{i}",
                        ip4_2=f"10.0.1.{i+1}"
                    )
                self.add_link(link)

        # Close the ring
        if node_count > 2:
            if is_router:
                # Routers: Separate subnet for closing link
                link = LinkConfig(
                    node1_id=node_count,
                    node2_id=1,
                    ip4_1=f"10.0.{node_count}.1",
                    ip4_2=f"10.0.{node_count}.2"
                )
            else:
                # Hosts: Same subnet for closing link
                link = LinkConfig(
                    node1_id=node_count,
                    node2_id=1,
                    ip4_1=f"10.0.1.{node_count}",
                    ip4_2=f"10.0.1.1"
                )
            self.add_link(link)

        return f"Created ring topology with {node_count} {node_type}s"

    def _generate_wireless_mesh(self, node_count: int, description: str) -> str:
        """Generate a wireless mesh network."""
        self.clear()

        # Create WLAN node
        wlan = NodeConfig(
            node_id=1,
            name="wlan1",
            node_type="wireless",
            x=self.center_x,
            y=self.center_y
        )
        self.add_node(wlan)
        self.set_wlan_config(1, range_meters=500, bandwidth=54000000)

        # Create MDR nodes
        import math
        # Calculate radius based on node count
        base_radius = 150
        radius = min(base_radius + (node_count * 8),
                    (min(self.canvas_width, self.canvas_height) / 2) - self.margin)

        for i in range(node_count):
            angle = (2 * math.pi * i) / node_count - (math.pi / 2)  # Start from top
            x = self.center_x + radius * math.cos(angle)
            y = self.center_y + radius * math.sin(angle)

            node = NodeConfig(
                node_id=i + 2,
                name=f"mdr{i+1}",
                node_type="mdr",
                model="mdr",
                x=x,
                y=y,
                services=["zebra", "OSPFv3MDR", "IPForward"]
            )
            self.add_node(node)

            # Link to WLAN
            link = LinkConfig(
                node1_id=1,
                node2_id=i + 2,
                ip4_2=f"10.0.0.{i+2}"
            )
            self.add_link(link)

        return f"Created wireless mesh with 1 WLAN and {node_count} MDR nodes"

    def _generate_tailscale_mesh(self, node_count: int, description: str) -> str:
        """Generate a tailscale mesh network with Docker nodes."""
        self.clear()

        # Create nodes with tailscale
        for i in range(node_count):
            x = 100.0 + (i % 3) * 200
            y = 100.0 + (i // 3) * 200

            node = NodeConfig(
                node_id=i + 1,
                name=f"tailscale{i+1}",
                node_type="docker",
                image="ubuntu:22.04",
                x=x,
                y=y,
                services=[]  # Custom tailscale service would be added here
            )
            self.add_node(node)

        return f"Created tailscale mesh with {node_count} Docker nodes (tailscale service needs to be configured separately)"

    # =========================================================================
    # APPLIANCE-BASED TOPOLOGY GENERATORS
    # =========================================================================

    def _generate_it_ot_network(self, description: str) -> str:
        """
        Generate an IT/OT segmented network with firewall.

        Architecture:
        - VyOS firewall at the boundary between IT and OT zones
        - IT zone: switch + workstations
        - OT zone: switch + PLCs + HMI
        - Firewall has interfaces in both zones
        """
        self.clear()
        import math

        desc_lower = description.lower()

        # Count IT workstations and OT devices
        it_count = 2  # Default IT workstations
        ot_count = 2  # Default OT devices (PLCs)

        # Try to extract counts from description
        if "workstation" in desc_lower:
            match = re.search(r'(\d+)\s*workstation', desc_lower)
            if match:
                it_count = int(match.group(1))

        if "plc" in desc_lower or "openplc" in desc_lower:
            match = re.search(r'(\d+)\s*(?:plc|openplc)', desc_lower)
            if match:
                ot_count = int(match.group(1))

        # Determine firewall type
        if "frr" in desc_lower:
            fw_type = "frr"
        else:
            fw_type = "vyos"  # Default

        # Include IDS?
        include_ids = "ids" in desc_lower or "suricata" in desc_lower or "monitor" in desc_lower

        # Layout constants
        center_x, center_y = 500, 350
        node_id = 1

        # === Create VyOS Firewall (center) ===
        fw_node = self.add_appliance(
            node_id=node_id,
            name="fw-itot",
            appliance_type=fw_type,
            x=center_x,
            y=center_y,
            interfaces=[
                {"name": "eth0", "ip": "192.168.1.1", "mask": 24, "zone": "it"},
                {"name": "eth1", "ip": "10.0.100.1", "mask": 24, "zone": "ot"},
            ]
        )
        node_id += 1

        # === IT Zone (left side) ===
        it_switch_id = node_id
        it_switch = NodeConfig(
            node_id=it_switch_id,
            name="it-switch",
            node_type="switch",
            x=center_x - 250,
            y=center_y,
        )
        self.add_node(it_switch)
        node_id += 1

        # Link IT switch to firewall
        self.add_link(LinkConfig(
            node1_id=it_switch_id,
            node2_id=1,
            ip4_2="192.168.1.1"
        ))

        # IT Workstations
        for i in range(it_count):
            angle = math.pi + (math.pi * (i + 1)) / (it_count + 1)
            x = (center_x - 250) + 150 * math.cos(angle)
            y = center_y + 150 * math.sin(angle)

            ws = NodeConfig(
                node_id=node_id,
                name=f"it-ws{i+1}",
                node_type="host",
                x=x,
                y=y,
            )
            self.add_node(ws)
            self.add_link(LinkConfig(
                node1_id=it_switch_id,
                node2_id=node_id,
                ip4_2=f"192.168.1.{10 + i}"
            ))
            node_id += 1

        # === OT Zone (right side) ===
        ot_switch_id = node_id
        ot_switch = NodeConfig(
            node_id=ot_switch_id,
            name="ot-switch",
            node_type="switch",
            x=center_x + 250,
            y=center_y,
        )
        self.add_node(ot_switch)
        node_id += 1

        # Link OT switch to firewall
        self.add_link(LinkConfig(
            node1_id=ot_switch_id,
            node2_id=1,
            ip4_2="10.0.100.1"
        ))

        # OpenPLC Controllers
        for i in range(ot_count):
            angle = (math.pi * (i + 1)) / (ot_count + 1)
            x = (center_x + 250) + 150 * math.cos(angle)
            y = center_y + 150 * math.sin(angle)

            plc = self.add_appliance(
                node_id=node_id,
                name=f"plc{i+1}",
                appliance_type="openplc",
                x=x,
                y=y,
            )
            self.add_link(LinkConfig(
                node1_id=ot_switch_id,
                node2_id=node_id,
                ip4_2=f"10.0.100.{10 + i}"
            ))
            node_id += 1

        # HMI Workstation with Browser (Docker-based for VNC access)
        hmi = self.add_appliance(
            node_id=node_id,
            name="hmi1",
            appliance_type="hmi-workstation",
            x=center_x + 400,
            y=center_y + 150,
        )
        self.add_link(LinkConfig(
            node1_id=ot_switch_id,
            node2_id=node_id,
            ip4_2="10.0.100.50"
        ))
        node_id += 1

        # Optional: Suricata IDS on OT network
        if include_ids:
            ids = self.add_appliance(
                node_id=node_id,
                name="ids-ot",
                appliance_type="suricata",
                x=center_x + 250,
                y=center_y + 200,
            )
            self.add_link(LinkConfig(
                node1_id=ot_switch_id,
                node2_id=node_id,
                ip4_2="10.0.100.250"
            ))
            node_id += 1

        fw_name = "VyOS" if fw_type == "vyos" else "FRRouting"
        ids_msg = " with Suricata IDS monitoring" if include_ids else ""
        return f"Created IT/OT network with {fw_name} firewall, {it_count} IT workstations, {ot_count} OpenPLC controllers, and HMI{ids_msg}"

    def _generate_ot_ids_network(self, description: str) -> str:
        """
        Generate an OT network with IDS monitoring.

        Architecture:
        - Suricata IDS monitoring OT traffic
        - Multiple PLCs
        - HMI workstation
        - Engineering workstation
        """
        self.clear()
        import math

        desc_lower = description.lower()

        # Count PLCs
        plc_count = 2
        match = re.search(r'(\d+)\s*(?:plc|openplc)', desc_lower)
        if match:
            plc_count = int(match.group(1))

        center_x, center_y = 500, 350
        node_id = 1

        # Central OT Switch
        ot_switch = NodeConfig(
            node_id=node_id,
            name="ot-switch",
            node_type="switch",
            x=center_x,
            y=center_y,
        )
        self.add_node(ot_switch)
        ot_switch_id = node_id
        node_id += 1

        # Suricata IDS (monitoring mode)
        ids = self.add_appliance(
            node_id=node_id,
            name="ids-ot",
            appliance_type="suricata",
            x=center_x,
            y=center_y - 150,
        )
        self.add_link(LinkConfig(
            node1_id=ot_switch_id,
            node2_id=node_id,
            ip4_2="10.0.100.250"
        ))
        node_id += 1

        # PLCs arranged in arc
        for i in range(plc_count):
            angle = math.pi/4 + (math.pi/2 * i) / max(plc_count - 1, 1)
            x = center_x + 200 * math.cos(angle)
            y = center_y + 200 * math.sin(angle)

            plc = self.add_appliance(
                node_id=node_id,
                name=f"plc{i+1}",
                appliance_type="openplc",
                x=x,
                y=y,
            )
            self.add_link(LinkConfig(
                node1_id=ot_switch_id,
                node2_id=node_id,
                ip4_2=f"10.0.100.{10 + i}"
            ))
            node_id += 1

        # HMI
        hmi = NodeConfig(
            node_id=node_id,
            name="hmi1",
            node_type="host",
            x=center_x - 200,
            y=center_y + 100,
        )
        self.add_node(hmi)
        self.add_link(LinkConfig(
            node1_id=ot_switch_id,
            node2_id=node_id,
            ip4_2="10.0.100.50"
        ))
        node_id += 1

        # Engineering Workstation
        eng_ws = NodeConfig(
            node_id=node_id,
            name="eng-ws",
            node_type="host",
            x=center_x - 200,
            y=center_y - 100,
        )
        self.add_node(eng_ws)
        self.add_link(LinkConfig(
            node1_id=ot_switch_id,
            node2_id=node_id,
            ip4_2="10.0.100.51"
        ))

        return f"Created OT network with Suricata IDS monitoring {plc_count} PLCs, HMI, and Engineering workstation"

    def _generate_loadbalanced_webfarm(self, description: str) -> str:
        """
        Generate a load-balanced web farm with HAProxy.

        Architecture:
        - HAProxy load balancer (frontend)
        - Multiple nginx backend servers
        - Client for testing
        """
        self.clear()
        import math

        desc_lower = description.lower()

        # Count backend servers
        backend_count = 3
        match = re.search(r'(\d+)\s*(?:nginx|backend|server|web)', desc_lower)
        if match:
            backend_count = int(match.group(1))

        center_x, center_y = 500, 350
        node_id = 1

        # Frontend switch (client-facing)
        frontend_switch = NodeConfig(
            node_id=node_id,
            name="frontend-sw",
            node_type="switch",
            x=center_x - 200,
            y=center_y,
        )
        self.add_node(frontend_switch)
        frontend_sw_id = node_id
        node_id += 1

        # Backend switch
        backend_switch = NodeConfig(
            node_id=node_id,
            name="backend-sw",
            node_type="switch",
            x=center_x + 200,
            y=center_y,
        )
        self.add_node(backend_switch)
        backend_sw_id = node_id
        node_id += 1

        # HAProxy Load Balancer (between switches)
        haproxy = self.add_appliance(
            node_id=node_id,
            name="haproxy-lb",
            appliance_type="haproxy",
            x=center_x,
            y=center_y,
        )
        # Connect to frontend
        self.add_link(LinkConfig(
            node1_id=frontend_sw_id,
            node2_id=node_id,
            ip4_2="192.168.1.10"
        ))
        # Connect to backend
        self.add_link(LinkConfig(
            node1_id=backend_sw_id,
            node2_id=node_id,
            ip4_2="10.0.1.1"
        ))
        node_id += 1

        # Client
        client = NodeConfig(
            node_id=node_id,
            name="client1",
            node_type="host",
            x=center_x - 350,
            y=center_y,
        )
        self.add_node(client)
        self.add_link(LinkConfig(
            node1_id=frontend_sw_id,
            node2_id=node_id,
            ip4_2="192.168.1.100"
        ))
        node_id += 1

        # Nginx backend servers
        for i in range(backend_count):
            angle = (math.pi * (i + 1)) / (backend_count + 1)
            x = (center_x + 200) + 150 * math.cos(angle)
            y = center_y + 150 * math.sin(angle)

            nginx = NodeConfig(
                node_id=node_id,
                name=f"nginx{i+1}",
                node_type="docker",
                image="nginx-core" if get_docker_image("nginx") else "nginx:latest",
                x=x,
                y=y,
            )
            self.add_node(nginx)
            self.add_link(LinkConfig(
                node1_id=backend_sw_id,
                node2_id=node_id,
                ip4_2=f"10.0.1.{10 + i}"
            ))
            node_id += 1

        return f"Created load-balanced web farm with HAProxy and {backend_count} nginx backend servers"

    def _generate_vpn_network(self, description: str) -> str:
        """
        Generate a VPN gateway network.

        Architecture:
        - WireGuard VPN gateway
        - Internal servers
        - Remote clients (simulated)
        """
        self.clear()

        desc_lower = description.lower()

        # Count internal servers
        server_count = 2
        match = re.search(r'(\d+)\s*(?:server|internal)', desc_lower)
        if match:
            server_count = int(match.group(1))

        center_x, center_y = 500, 350
        node_id = 1

        # External switch (WAN side)
        wan_switch = NodeConfig(
            node_id=node_id,
            name="wan-switch",
            node_type="switch",
            x=center_x - 250,
            y=center_y,
        )
        self.add_node(wan_switch)
        wan_sw_id = node_id
        node_id += 1

        # Internal switch (LAN side)
        lan_switch = NodeConfig(
            node_id=node_id,
            name="lan-switch",
            node_type="switch",
            x=center_x + 250,
            y=center_y,
        )
        self.add_node(lan_switch)
        lan_sw_id = node_id
        node_id += 1

        # WireGuard VPN Gateway
        wg = self.add_appliance(
            node_id=node_id,
            name="vpn-gw",
            appliance_type="wireguard",
            x=center_x,
            y=center_y,
        )
        # WAN connection
        self.add_link(LinkConfig(
            node1_id=wan_sw_id,
            node2_id=node_id,
            ip4_2="203.0.113.1"  # Public IP simulation
        ))
        # LAN connection
        self.add_link(LinkConfig(
            node1_id=lan_sw_id,
            node2_id=node_id,
            ip4_2="10.0.1.1"
        ))
        node_id += 1

        # Remote clients (on WAN side)
        for i in range(2):
            client = NodeConfig(
                node_id=node_id,
                name=f"remote-client{i+1}",
                node_type="host",
                x=center_x - 400,
                y=center_y - 100 + (i * 200),
            )
            self.add_node(client)
            self.add_link(LinkConfig(
                node1_id=wan_sw_id,
                node2_id=node_id,
                ip4_2=f"203.0.113.{100 + i}"
            ))
            node_id += 1

        # Internal servers
        for i in range(server_count):
            server = NodeConfig(
                node_id=node_id,
                name=f"server{i+1}",
                node_type="host",
                x=center_x + 400,
                y=center_y - 100 + (i * 100),
            )
            self.add_node(server)
            self.add_link(LinkConfig(
                node1_id=lan_sw_id,
                node2_id=node_id,
                ip4_2=f"10.0.1.{10 + i}"
            ))
            node_id += 1

        return f"Created VPN network with WireGuard gateway, 2 remote clients, and {server_count} internal servers"

    def _generate_iot_sensor_network(self, description: str) -> str:
        """
        Generate an IoT sensor network for quick deployment.

        This is a ready-to-use topology for bridging physical sensors (micro:bit, etc.)
        into the CORE network simulation via MQTT.

        Architecture:
        - MQTT Broker (Mosquitto) - central message hub
        - IoT Sensor Server - subscribes to MQTT, serves web display
        - HMI Workstation(s) - browser-based operator displays
        - All on same subnet for simple connectivity

        Data Flow:
        Physical micro:bit -> Browser WebSerial -> REST API -> MQTT Broker
                                                                   |
                                                                   v
        HMI Workstation <- Web Display <- IoT Sensor Server <- MQTT Subscribe

        To use:
        1. Deploy this topology
        2. Configure web_ui.py MQTT to point to the broker node IP
        3. Open micro:bit page in browser, connect sensor
        4. Open HMI workstation VNC, browse to IoT Sensor Server
        """
        self.clear()
        import math

        desc_lower = description.lower()

        # Count HMI workstations
        hmi_count = 1
        match = re.search(r'(\d+)\s*(?:hmi|workstation|operator)', desc_lower)
        if match:
            hmi_count = int(match.group(1))

        center_x, center_y = 500, 350
        node_id = 1

        # Central Switch
        iot_switch = NodeConfig(
            node_id=node_id,
            name="iot-switch",
            node_type="switch",
            x=center_x,
            y=center_y,
        )
        self.add_node(iot_switch)
        switch_id = node_id
        node_id += 1

        # MQTT Broker (Mosquitto) - top center
        mqtt_broker = NodeConfig(
            node_id=node_id,
            name="mqtt-broker",
            node_type="docker",
            image="mqtt-broker-core",
            x=center_x,
            y=center_y - 180,
        )
        self.add_node(mqtt_broker)
        mqtt_broker_ip = "10.0.1.10"
        self.add_link(LinkConfig(
            node1_id=switch_id,
            node2_id=node_id,
            ip4_2=mqtt_broker_ip,
        ))
        node_id += 1

        # IoT Sensor Server - right of center
        sensor_server = NodeConfig(
            node_id=node_id,
            name="sensor-server",
            node_type="docker",
            image="iot-sensor-server",
            x=center_x + 200,
            y=center_y - 100,
        )
        self.add_node(sensor_server)
        sensor_server_ip = "10.0.1.20"
        self.add_link(LinkConfig(
            node1_id=switch_id,
            node2_id=node_id,
            ip4_2=sensor_server_ip,
        ))
        # Add startup script to configure MQTT broker address
        sensor_startup = f'''#!/bin/bash
# Configure IoT Sensor Server to connect to MQTT broker
export MQTT_BROKER="{mqtt_broker_ip}"
export MQTT_PORT="1883"
export MQTT_TOPIC="core/sensors/#"

echo "[IoT Server] Starting with MQTT broker at $MQTT_BROKER:$MQTT_PORT"
# The container entrypoint will use these environment variables
'''
        self.add_startup_script(node_id, sensor_startup, delay_seconds=5)
        node_id += 1

        # HMI Workstations - arranged at bottom
        for i in range(hmi_count):
            angle = math.pi/4 + (math.pi/2 * i) / max(hmi_count, 1)
            x = center_x + 180 * math.cos(angle)
            y = center_y + 180 * math.sin(angle)

            hmi = NodeConfig(
                node_id=node_id,
                name=f"hmi{i+1}",
                node_type="docker",
                image="hmi-workstation:latest",
                x=x,
                y=y,
            )
            self.add_node(hmi)
            hmi_ip = f"10.0.1.{50 + i}"
            self.add_link(LinkConfig(
                node1_id=switch_id,
                node2_id=node_id,
                ip4_2=hmi_ip,
            ))
            node_id += 1

        # Build result message with usage instructions
        result = f"""Created IoT Sensor Network with MQTT broker, sensor server, and {hmi_count} HMI workstation(s)

=== NETWORK LAYOUT ===
- mqtt-broker    @ {mqtt_broker_ip}:1883 (MQTT), :9001 (WebSocket)
- sensor-server  @ {sensor_server_ip}:80 (Web Display)
- hmi1-{hmi_count}        @ 10.0.1.50-{50+hmi_count-1} (VNC on :6080)

=== DATA FLOW ===
Physical Sensor -> Web UI -> REST API -> MQTT -> Sensor Server -> HMI Display

=== QUICK START ===
1. Start this CORE session
2. Open the Web UI micro:bit page in your browser
3. Connect your micro:bit via WebSerial
4. Configure MQTT broker IP in Web UI settings: {mqtt_broker_ip}
5. Access HMI workstation via noVNC (port 6080)
6. In HMI Firefox, browse to: http://{sensor_server_ip}/

=== ALTERNATIVE: Direct HTTP Mode ===
If MQTT is not available, sensor-server supports HTTP polling:
- Browse to http://{sensor_server_ip}/ with ?mode=http query param
"""

        return result

    def _generate_phone_sensor_network(self, description: str) -> str:
        """
        Generate a Phone Sensor Network for streaming phone accelerometer/gyroscope data.

        This creates a topology specifically designed to bridge phone sensor data
        (from the browser Device Motion API) into the CORE network via MQTT.

        Architecture:
        - MQTT Broker (Mosquitto) - central message hub inside CORE
        - Sensor Display Server - web dashboard to view phone data
        - HMI Workstation(s) - VNC-accessible browsers to view displays
        - All on same subnet for simple connectivity

        Data Flow (with bridge):
        Phone Browser (DeviceMotion API)
            -> Phone Web UI (port 8081)
            -> MQTT Injector (docker exec into CORE)
            -> MQTT Broker inside CORE network
            -> Sensor Display Server (subscribes to MQTT)
            -> HMI Workstation (browser viewing display)

        The key difference from micro:bit network is:
        - Phone streams accelerometer/gyroscope via REST API
        - phone_web_ui.py has embedded MQTT injector that bridges to CORE
        - Data flows: Phone -> REST -> Injector -> docker exec -> CORE MQTT broker
        """
        self.clear()
        import math

        desc_lower = description.lower()

        # Count HMI workstations
        hmi_count = 1
        match = re.search(r'(\d+)\s*(?:hmi|workstation|operator|display)', desc_lower)
        if match:
            hmi_count = int(match.group(1))

        center_x, center_y = 500, 350
        node_id = 1

        # Central Switch
        phone_switch = NodeConfig(
            node_id=node_id,
            name="phone-switch",
            node_type="switch",
            x=center_x,
            y=center_y,
        )
        self.add_node(phone_switch)
        switch_id = node_id
        node_id += 1

        # MQTT Broker (Mosquitto) - top center
        # This is where phone data gets injected via docker exec
        mqtt_broker = NodeConfig(
            node_id=node_id,
            name="mqtt-broker",
            node_type="docker",
            image="mqtt-broker-core",
            x=center_x,
            y=center_y - 180,
        )
        self.add_node(mqtt_broker)
        mqtt_broker_ip = "10.0.1.10"
        self.add_link(LinkConfig(
            node1_id=switch_id,
            node2_id=node_id,
            ip4_2=mqtt_broker_ip,
        ))
        node_id += 1

        # Phone Sensor Display Server - subscribes to MQTT, shows phone data
        sensor_server = NodeConfig(
            node_id=node_id,
            name="phone-display-server",
            node_type="docker",
            image="iot-sensor-server",
            x=center_x + 200,
            y=center_y - 100,
        )
        self.add_node(sensor_server)
        sensor_server_ip = "10.0.1.20"
        self.add_link(LinkConfig(
            node1_id=switch_id,
            node2_id=node_id,
            ip4_2=sensor_server_ip,
        ))
        # Startup script to configure MQTT subscription for phone topics
        phone_sensor_startup = f'''#!/bin/bash
# Configure Phone Sensor Display Server to connect to MQTT broker
export MQTT_BROKER="{mqtt_broker_ip}"
export MQTT_PORT="1883"
export MQTT_TOPIC="core/sensors/phone-#"

echo "[Phone Display] Starting with MQTT broker at $MQTT_BROKER:$MQTT_PORT"
echo "[Phone Display] Subscribing to topic: $MQTT_TOPIC"
# The container entrypoint will use these environment variables
'''
        self.add_startup_script(node_id, phone_sensor_startup, delay_seconds=5)
        node_id += 1

        # HMI Workstations - for viewing the phone sensor display
        for i in range(hmi_count):
            angle = math.pi/4 + (math.pi/2 * i) / max(hmi_count, 1)
            x = center_x + 180 * math.cos(angle)
            y = center_y + 180 * math.sin(angle)

            hmi = NodeConfig(
                node_id=node_id,
                name=f"phone-hmi{i+1}",
                node_type="docker",
                image="hmi-workstation:latest",
                x=x,
                y=y,
            )
            self.add_node(hmi)
            hmi_ip = f"10.0.1.{50 + i}"
            self.add_link(LinkConfig(
                node1_id=switch_id,
                node2_id=node_id,
                ip4_2=hmi_ip,
            ))
            node_id += 1

        # Build result message with usage instructions
        result = f"""Created Phone Sensor Network with MQTT broker, display server, and {hmi_count} HMI workstation(s)

=== NETWORK LAYOUT (inside CORE) ===
- mqtt-broker          @ {mqtt_broker_ip}:1883 (MQTT), :9001 (WebSocket)
- phone-display-server @ {sensor_server_ip}:80 (Web Display)
- phone-hmi1-{hmi_count}         @ 10.0.1.50-{50+hmi_count-1} (VNC on :6080)

=== DATA FLOW ===
Phone (DeviceMotion API) -> Phone Web UI (8081) -> MQTT Injector -> CORE MQTT Broker -> Display Server

=== SETUP STEPS ===

1. START THE CORE SESSION
   - Deploy this topology and start the session
   - Wait for all containers to initialize (~30 seconds)

2. START THE PHONE WEB UI (outside CORE, on host)
   cd /workspaces/core/core-mcp-server
   ./start_phone_system.sh

3. CONFIGURE THE MQTT BRIDGE
   The phone_web_ui.py has an embedded MQTT injector.
   Configure it to point to this CORE topology:

   curl -X POST http://localhost:8081/api/inject/configure \\
     -H "Content-Type: application/json" \\
     -d '{{"session_id": 1, "broker_node": "mqtt-broker", "broker_ip": "{mqtt_broker_ip}", "source_node": "mqtt-broker"}}'

4. CONNECT YOUR PHONE
   - Open the Phone Sensor page in your browser (port 8081)
   - Scan the QR code with your phone
   - Grant sensor permissions and tap "Start Streaming"

5. VIEW DATA IN CORE NETWORK
   - Open HMI workstation via noVNC (port 6080)
   - In Firefox, browse to: http://{sensor_server_ip}/
   - You should see live phone accelerometer/gyroscope data!

=== WIRESHARK VERIFICATION ===
The MQTT packets are REAL network traffic inside CORE.
To verify:
1. In CORE GUI, right-click mqtt-broker -> Wireshark
2. Filter: mqtt
3. You should see PUBLISH packets with phone sensor data

=== TOPICS ===
Phone data is published to: core/sensors/phone-<id>/data
Example payload: {{"ax": 100, "ay": 200, "az": 980, "alpha": 45.2, "beta": 12.1, "gamma": -5.3, "device": "phone"}}

=== API ENDPOINTS (Phone Web UI on port 8081) ===
- GET  /phone           - Phone sensor page (open on mobile)
- GET  /phone-display   - Display page (open on desktop)
- GET  /api/sensors     - List connected phones
- POST /api/inject/<id> - Inject sensor data to CORE
- GET  /api/inject/status - Check injector status
- POST /api/inject/configure - Configure MQTT bridge
"""

        return result

    def _generate_docker_app_topology(self, node_count: int, description: str, app_name: str) -> str:
        """
        Generate a topology with Docker application nodes (nginx, etc.) connected via switch.

        This creates a realistic server farm / web cluster topology:
        - Central switch for Layer 2 connectivity
        - Multiple Docker app nodes (e.g., nginx web servers)
        - Optional client hosts for testing
        - All on same subnet (proper Layer 2 networking)

        Args:
            node_count: Number of app containers to create
            description: Original natural language description
            app_name: Name of the app (used to look up image in registry)
        """
        self.clear()
        import math

        # Look up the Docker image configuration
        docker_config = get_docker_image(app_name)
        if not docker_config:
            # Fallback to generic ubuntu if app not found
            docker_config = DOCKER_IMAGE_REGISTRY["ubuntu"]
            image_name = "ubuntu:22.04"
            app_display_name = "docker"
        else:
            image_name = docker_config["image"]
            app_display_name = app_name.lower()

        desc_lower = description.lower()

        # Check if user wants clients/targets too
        # For security tools (caldera, etc.), "targets", "victims", "hosts" are clients
        include_clients = any(word in desc_lower for word in [
            "client", "clients", "test", "browser",
            "target", "targets", "victim", "victims", "host", "hosts", "agent", "agents"
        ])

        # Determine if this is a "1 server + N targets" pattern
        # e.g., "1 caldera server with 3 targets" or "caldera with 5 target hosts"
        is_server_with_targets = any(word in desc_lower for word in [
            "target", "targets", "victim", "victims", "agent", "agents"
        ]) and docker_config.get("category") == "security"

        if is_server_with_targets:
            # For security tools: 1 server, N targets
            # Extract target count from description
            # Look for number before target/victim/host keywords
            import re
            target_match = re.search(r'(\d+)\s*(?:target|victim|host|agent)', desc_lower)
            if target_match:
                client_count = int(target_match.group(1))
            else:
                client_count = node_count  # Use the main count as target count
            node_count = 1  # Only 1 server (caldera, etc.)
        else:
            # Normal client detection
            client_count = self._extract_number(desc_lower.split("client")[0], default=0) if include_clients else 0
            if include_clients and client_count == 0:
                client_count = 2  # Default 2 clients if mentioned but no count

        # Create central switch
        switch_node = NodeConfig(
            node_id=1,
            name="switch1",
            node_type="switch",
            x=self.center_x,
            y=self.center_y,
            services=[]
        )
        self.add_node(switch_node)

        # Calculate layout - app nodes on top half, clients on bottom
        total_app_nodes = node_count
        app_radius = min(180 + (total_app_nodes * 10),
                        (min(self.canvas_width, self.canvas_height) / 2) - self.margin)

        # Create Docker app nodes (e.g., nginx servers)
        current_node_id = 2
        for i in range(total_app_nodes):
            # Arrange in arc on top half
            angle = math.pi + (math.pi * (i + 1)) / (total_app_nodes + 1)  # Top arc
            x = self.center_x + app_radius * math.cos(angle)
            y = self.center_y + app_radius * math.sin(angle)

            node = NodeConfig(
                node_id=current_node_id,
                name=f"{app_display_name}{i+1}",
                node_type="docker",
                image=image_name,
                x=x,
                y=y,
                services=docker_config.get("default_services", [])
            )
            self.add_node(node)

            # Link to switch - all on same subnet (Layer 2 rule)
            link = LinkConfig(
                node1_id=1,
                node2_id=current_node_id,
                ip4_2=f"10.0.1.{current_node_id}",  # 10.0.1.2, 10.0.1.3, etc.
                bandwidth=100000000
            )
            self.add_link(link)
            current_node_id += 1

        # Create client/target hosts if requested
        # For Caldera, track how many targets should have Sandcat agents
        caldera_server_ip = None
        sandcat_targets = []

        if is_server_with_targets and app_display_name == "caldera":
            # Caldera server is node 2 (first after switch), gets IP 10.0.1.2
            caldera_server_ip = "10.0.1.2"
            # Store metadata about the Caldera deployment
            self.caldera_server_ip = caldera_server_ip

        if client_count > 0:
            # Use "target" naming for security tools, "client" for others
            host_prefix = "target" if is_server_with_targets else "client"
            client_radius = app_radius * 0.8

            # Determine how many targets get Sandcat agents (random selection)
            # By default, deploy on 50-100% of targets randomly
            import random
            num_agents = max(1, random.randint(client_count // 2, client_count))
            agent_indices = set(random.sample(range(client_count), num_agents))

            for i in range(client_count):
                # Arrange in arc on bottom half
                angle = (math.pi * (i + 1)) / (client_count + 1)  # Bottom arc
                x = self.center_x + client_radius * math.cos(angle)
                y = self.center_y + client_radius * math.sin(angle)

                target_ip = f"10.0.1.{current_node_id}"

                # Check if this target should have a Sandcat agent
                has_agent = (i in agent_indices) and caldera_server_ip

                node = NodeConfig(
                    node_id=current_node_id,
                    name=f"{host_prefix}{i+1}",
                    node_type="host",
                    x=x,
                    y=y,
                    services=["DefaultRoute"]
                )
                self.add_node(node)

                if has_agent:
                    sandcat_targets.append({
                        "name": f"{host_prefix}{i+1}",
                        "ip": target_ip,
                        "node_id": current_node_id
                    })

                # Link to switch - same subnet as servers
                link = LinkConfig(
                    node1_id=1,
                    node2_id=current_node_id,
                    ip4_2=target_ip,
                    bandwidth=100000000
                )
                self.add_link(link)
                current_node_id += 1

        # Store Sandcat deployment info for later use
        if sandcat_targets:
            self.sandcat_deployment = {
                "caldera_server_ip": caldera_server_ip,
                "targets": sandcat_targets
            }

            # Add automatic startup scripts if auto_deploy is enabled
            if self.auto_deploy and caldera_server_ip:
                # Add startup script for Caldera server (node 2)
                caldera_startup = f'''#!/bin/bash
# Auto-start Caldera server
echo "[CALDERA] Starting Caldera server..."
nohup /start-caldera.sh > /tmp/caldera.log 2>&1 &
echo "[CALDERA] Caldera starting in background (log: /tmp/caldera.log)"
'''
                self.add_startup_script(2, caldera_startup, delay_seconds=0)

                # Add startup scripts for Sandcat agents with delay
                # Agents wait 90 seconds for Caldera to be ready, then deploy
                for target in sandcat_targets:
                    sandcat_startup = f'''#!/bin/bash
# Auto-deploy Sandcat agent after Caldera is ready
CALDERA_URL="http://{caldera_server_ip}:8888"
DELAY=90

echo "[SANDCAT] Waiting ${{DELAY}}s for Caldera to start..."
sleep $DELAY

# Check if Caldera is ready
for attempt in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{{http_code}}" $CALDERA_URL 2>/dev/null | grep -q "200"; then
        echo "[SANDCAT] Caldera is ready, deploying agent..."
        curl -s -X POST -H "file:sandcat.go" -H "platform:linux" "$CALDERA_URL/file/download" -o /tmp/sandcat
        if [ -f /tmp/sandcat ] && [ -s /tmp/sandcat ]; then
            chmod +x /tmp/sandcat
            nohup /tmp/sandcat -server "$CALDERA_URL" -group red -v > /tmp/sandcat.log 2>&1 &
            echo "[SANDCAT] Agent deployed successfully (PID: $!)"
            exit 0
        else
            echo "[SANDCAT] Failed to download agent"
            exit 1
        fi
    fi
    echo "[SANDCAT] Waiting for Caldera... (attempt $attempt/30)"
    sleep 5
done
echo "[SANDCAT] Caldera not ready after $((DELAY + 150))s, giving up"
'''
                    self.add_startup_script(target["node_id"], sandcat_startup, delay_seconds=0)

        # Build result message
        ports_info = ""
        if docker_config.get("ports"):
            ports_info = f" (listening on ports: {', '.join(map(str, docker_config['ports']))})"

        result = f"Created {app_display_name} topology with {total_app_nodes} {app_display_name} server(s){ports_info}"
        if client_count > 0:
            # Use "target host(s)" for security tools, "client host(s)" for others
            client_label = "target host(s)" if is_server_with_targets else "client host(s)"
            result += f" and {client_count} {client_label}"
        result += " connected via switch (all on 10.0.1.0/24)"

        # Add Sandcat agent deployment info
        if sandcat_targets:
            agent_names = [t["name"] for t in sandcat_targets]
            result += f"\n\n=== CALDERA RED TEAM DEPLOYMENT ==="
            result += f"\nCaldera server: caldera1 @ {caldera_server_ip}:8888"
            result += f"\nCredentials: red/admin or blue/admin"
            result += f"\nTarget hosts with agents: {', '.join(agent_names)}"

            if self.auto_deploy:
                result += f"\n\n=== AUTO-DEPLOYMENT ENABLED ==="
                result += f"\nWhen you start the session, everything will deploy automatically:"
                result += f"\n  1. Caldera server starts immediately"
                result += f"\n  2. After ~90 seconds, Sandcat agents deploy on target hosts"
                result += f"\n  3. Agents beacon back to Caldera at {caldera_server_ip}:8888"
                result += f"\n\nJust start the session and wait ~2 minutes for agents to appear!"
            else:
                result += f"\n\n=== MANUAL DEPLOYMENT ==="
                result += f"\nRun this command in the CORE container terminal to deploy:"
                result += f"\n"
                result += f"\n  /tmp/deploy-caldera-agents.sh <SESSION_ID> caldera1 {caldera_server_ip}"
                result += f"\n"
                result += f"\n(Replace <SESSION_ID> with the actual session number, usually 1)"

        return result

    def get_summary(self) -> str:
        """Get a summary of the current topology."""
        summary = f"Topology: {self.session_name}\n"
        summary += f"Nodes: {len(self.nodes)}\n"
        for node_id, node in self.nodes.items():
            summary += f"  - {node.name} (ID: {node_id}, Type: {node.node_type})\n"
        summary += f"Links: {len(self.links)}\n"
        for i, link in enumerate(self.links):
            node1 = self.get_node_name(link.node1_id)
            node2 = self.get_node_name(link.node2_id)
            summary += f"  - {node1} <-> {node2}\n"
        return summary

    def to_python_script(self) -> str:
        """Generate a Python script using CORE gRPC API."""
        script = """#!/usr/bin/env python3
\"\"\"
CORE Network Topology - Auto-generated script
\"\"\"

from core.api.grpc import client
from core.api.grpc.wrappers import NodeType, Position, Interface

# Interface helper for IP allocation
iface_helper = client.InterfaceHelper(ip4_prefix="10.0.0.0/16", ip6_prefix="2001::/64")

# Create gRPC client and connect
core = client.CoreGrpcClient()
core.connect()

# Create session
session = core.create_session()

# Create nodes
"""

        # Add nodes
        node_type_map = {
            "router": "NodeType.DEFAULT",
            "switch": "NodeType.SWITCH",
            "hub": "NodeType.HUB",
            "host": "NodeType.DEFAULT",
            "pc": "NodeType.DEFAULT",
            "mdr": "NodeType.DEFAULT",
            "wireless": "NodeType.WIRELESS",
            "emane": "NodeType.EMANE",
            "docker": "NodeType.DOCKER"
        }

        for node_id, node in sorted(self.nodes.items()):
            node_var = f"node{node_id}"
            node_type_str = node_type_map.get(node.node_type, "NodeType.DEFAULT")

            script += f"position_{node_id} = Position(x={node.x}, y={node.y})\n"

            if node.node_type == "docker" and node.image:
                script += f'{node_var} = session.add_node({node_id}, name="{node.name}", _type={node_type_str}, position=position_{node_id}, image="{node.image}")\n'
            elif node.model:
                script += f'{node_var} = session.add_node({node_id}, name="{node.name}", _type={node_type_str}, position=position_{node_id}, model="{node.model}")\n'
            else:
                script += f'{node_var} = session.add_node({node_id}, name="{node.name}", _type={node_type_str}, position=position_{node_id})\n'

            # Add services
            if node.services:
                services_str = '", "'.join(node.services)
                script += f'{node_var}.set_services(["{services_str}"])\n'

            script += "\n"

        # Add links
        script += "# Create links\n"
        for i, link in enumerate(self.links):
            node1_var = f"node{link.node1_id}"
            node2_var = f"node{link.node2_id}"

            iface1_id = link.iface1_id if link.iface1_id is not None else 0
            iface2_id = link.iface2_id if link.iface2_id is not None else 0

            if link.ip4_1 and link.ip4_2:
                script += f'iface1_{i} = Interface(id={iface1_id}, ip4="{link.ip4_1}", ip4_mask=24)\n'
                script += f'iface2_{i} = Interface(id={iface2_id}, ip4="{link.ip4_2}", ip4_mask=24)\n'
                script += f"session.add_link(node1={node1_var}, node2={node2_var}, iface1=iface1_{i}, iface2=iface2_{i})\n\n"
            else:
                script += f"iface1_{i} = iface_helper.create_iface({link.node1_id}, {iface1_id})\n"
                script += f"iface2_{i} = iface_helper.create_iface({link.node2_id}, {iface2_id})\n"
                script += f"session.add_link(node1={node1_var}, node2={node2_var}, iface1=iface1_{i}, iface2=iface2_{i})\n\n"

        # Add WLAN configs
        if self.wlan_configs:
            script += "# Configure WLAN nodes\n"
            for node_id, wlan_config in self.wlan_configs.items():
                node_var = f"node{node_id}"
                script += f"""{node_var}.set_wlan({{
    "range": "{wlan_config.range_meters}",
    "bandwidth": "{wlan_config.bandwidth}",
    "delay": "{wlan_config.delay}",
    "jitter": "{wlan_config.jitter}",
    "error": "{wlan_config.loss}"
}})

"""

        # Start session
        script += "# Start session\ncore.start_session(session)\nprint(\"Session started successfully!\")\n"

        return script

    def to_xml(self) -> str:
        """Generate a CORE XML file."""
        root = ET.Element("scenario", name=self.session_name)

        # Networks section
        networks = ET.SubElement(root, "networks")
        devices = ET.SubElement(root, "devices")

        for node_id, node in sorted(self.nodes.items()):
            if node.node_type in ["switch", "hub", "wireless", "emane"]:
                network = ET.SubElement(networks, "network",
                    id=str(node_id),
                    name=node.name,
                    type=node.node_type.upper().replace("WIRELESS", "WIRELESS_LAN")
                )
                pos = ET.SubElement(network, "position",
                    x=str(node.x),
                    y=str(node.y),
                    lat="0.0",
                    lon="0.0",
                    alt="0.0"
                )
            else:
                # Convert node type to CORE XML format
                # "host" -> "PC" for proper icon display in CORE GUI
                # "docker" -> class="docker" (CORE uses class attribute, not type)
                if node.node_type == "host":
                    xml_type = "PC"
                    device_attrs = {
                        "id": str(node_id),
                        "name": node.name,
                        "type": xml_type
                    }
                elif node.node_type == "docker":
                    # Docker uses class="docker" with empty type, per CORE format
                    device_attrs = {
                        "id": str(node_id),
                        "name": node.name,
                        "type": "",
                        "class": "docker"
                    }
                    # Add image and docker-specific attributes
                    if node.image:
                        device_attrs["image"] = node.image
                    # Add compose attributes for appliances
                    if node.compose:
                        device_attrs["compose"] = node.compose
                    if node.compose_name:
                        device_attrs["compose_name"] = node.compose_name
                else:
                    xml_type = node.node_type
                    device_attrs = {
                        "id": str(node_id),
                        "name": node.name,
                        "type": xml_type
                    }

                device = ET.SubElement(devices, "device", **device_attrs)
                pos = ET.SubElement(device, "position",
                    x=str(node.x),
                    y=str(node.y),
                    lat="0.0",
                    lon="0.0",
                    alt="0.0"
                )
                if node.services:
                    services_elem = ET.SubElement(device, "services")
                    for service_name in node.services:
                        ET.SubElement(services_elem, "service", name=service_name)

        # Links section - Track interface IDs per node
        iface_counters = {}  # node_id -> next_interface_id

        links_elem = ET.SubElement(root, "links")
        for link in self.links:
            # Get next interface ID for node1 and node2
            if link.node1_id not in iface_counters:
                iface_counters[link.node1_id] = 0
            if link.node2_id not in iface_counters:
                iface_counters[link.node2_id] = 0

            iface1_id = iface_counters[link.node1_id]
            iface2_id = iface_counters[link.node2_id]

            # Increment counters for next link
            iface_counters[link.node1_id] += 1
            iface_counters[link.node2_id] += 1

            link_elem = ET.SubElement(links_elem, "link",
                node1=str(link.node1_id),
                node2=str(link.node2_id)
            )

            # Add interface 1 if it has an IP
            if link.ip4_1:
                iface1 = ET.SubElement(link_elem, "iface1",
                    id=str(iface1_id),
                    name=f"eth{iface1_id}",
                    ip4=link.ip4_1,
                    ip4_mask="24"
                )

            # Add interface 2 if it has an IP
            if link.ip4_2:
                iface2 = ET.SubElement(link_elem, "iface2",
                    id=str(iface2_id),
                    name=f"eth{iface2_id}",
                    ip4=link.ip4_2,
                    ip4_mask="24"
                )

            if link.bandwidth or link.delay or link.loss:
                options = ET.SubElement(link_elem, "options",
                    bandwidth=str(link.bandwidth),
                    delay=str(link.delay),
                    loss=str(link.loss)
                )

        # Add session hooks for VNC proxy setup and cleanup
        session_hooks = ET.SubElement(root, "session_hooks")

        # RUNTIME_STATE hook (state=4) - runs when session starts
        # Sets up VNC proxies for all HMI nodes
        runtime_hook = ET.SubElement(session_hooks, "hook",
            name="setup_vnc_proxies.sh",
            state="4"  # EventTypes.RUNTIME_STATE = 4
        )
        runtime_hook.text = '''#!/bin/bash
# VNC Proxy Setup Hook - Auto-generated by topology generator
# Runs when CORE session reaches RUNTIME_STATE
# Sets up websockify/socat proxy chain for HMI containers

log() {
    echo "[VNC-HOOK] $1" | tee -a /tmp/vnc_hook.log
}

log "Session started - setting up VNC proxies..."

# Find HMI containers with x11vnc
PORT=6081
for container in $(docker ps --format '{{.Names}}' 2>/dev/null); do
    # Skip system containers
    [ "$container" = "core-novnc" ] && continue
    [ "$container" = "core-daemon" ] && continue

    # Check if container has x11vnc running
    if docker exec "$container" pgrep -f "x11vnc" >/dev/null 2>&1; then
        log "Found VNC container: $container"

        # Get container PID
        PID=$(docker inspect "$container" --format '{{.State.Pid}}' 2>/dev/null)
        if [ -z "$PID" ]; then
            log "  Could not get PID for $container, skipping"
            continue
        fi

        # Kill existing proxy for this port
        pkill -f "websockify.*$PORT" 2>/dev/null || true
        pkill -f "socat.*1$PORT" 2>/dev/null || true
        sleep 0.5

        # Create nsenter script that connects to x11vnc on port 5900
        cat > /tmp/ns_forward_$PORT.sh << EOFSCRIPT
#!/bin/sh
exec nsenter -n -t $PID socat STDIO TCP:localhost:5900
EOFSCRIPT
        chmod +x /tmp/ns_forward_$PORT.sh

        # Start socat and websockify
        socat TCP-LISTEN:1$PORT,fork,reuseaddr EXEC:/tmp/ns_forward_$PORT.sh &
        sleep 0.5
        python3 -m websockify --web /opt/noVNC $PORT localhost:1$PORT &

        log "  VNC proxy ready on port $PORT for $container"
        PORT=$((PORT + 1))
    fi
done

log "VNC proxy setup complete"
'''

        # SHUTDOWN_STATE hook (state=6) - runs when session stops
        # Cleans up VNC proxies
        shutdown_hook = ET.SubElement(session_hooks, "hook",
            name="cleanup_vnc_proxies.sh",
            state="6"  # EventTypes.SHUTDOWN_STATE = 6
        )
        shutdown_hook.text = '''#!/bin/bash
# VNC Proxy Cleanup Hook - Auto-generated by topology generator
# Runs when CORE session reaches SHUTDOWN_STATE

log() {
    echo "[VNC-HOOK] $1" | tee -a /tmp/vnc_hook.log
}

log "Session stopping - cleaning up VNC proxies..."

# Kill websockify HMI proxies (ports 6081-6089, NOT 6080 which is main VNC)
pkill -f "websockify.*608[1-9]" 2>/dev/null || true

# Kill socat internal proxies
pkill -f "socat.*TCP-LISTEN:160" 2>/dev/null || true

# Remove wrapper scripts
rm -f /tmp/ns_forward_*.sh 2>/dev/null || true

log "VNC proxy cleanup complete"
'''

        # Pretty print XML
        xml_str = ET.tostring(root, encoding='unicode')
        dom = minidom.parseString(xml_str)
        return dom.toprettyxml(indent="  ")

    def get_startup_scripts_json(self) -> str:
        """
        Export startup scripts as JSON for use with start_and_deploy.py.

        Returns JSON array with:
        [
            {
                "node_id": 2,
                "node_name": "caldera1",
                "script_content": "#!/bin/bash\n...",
                "delay_seconds": 0
            },
            ...
        ]
        """
        import json

        scripts = []
        for node_id, startup_script in self.startup_scripts.items():
            node = self.nodes.get(node_id)
            node_name = node.name if node else f"n{node_id}"

            scripts.append({
                "node_id": node_id,
                "node_name": node_name,
                "script_content": startup_script.script_content,
                "delay_seconds": startup_script.delay_seconds
            })

        return json.dumps(scripts, indent=2)

    def has_startup_scripts(self) -> bool:
        """Check if this topology has any startup scripts defined."""
        return len(self.startup_scripts) > 0
