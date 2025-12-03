#!/usr/bin/env python3
"""
Digital Twin Topology Builder - Progressive Mode
Provides iterative environment building with session persistence and future capability placeholders.
"""

import json
import os
import uuid
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass, field, asdict
from typing import Dict, List, Optional, Any
from enum import Enum


class CapabilityStatus(Enum):
    READY = "ready"
    PLACEHOLDER = "placeholder"
    FUTURE = "future"


class DesignStage(Enum):
    A_NETWORK = "network"           # Base network skeleton
    B_HOSTS = "hosts"               # Hosts, tools, containers
    C_PLCS = "plcs"                 # PLCs (placeholder)
    D_OTSIM = "otsim"               # OT-sim process models (placeholder)
    E_SENSORS = "sensors"           # Sensors & remote data (placeholder)
    F_PROTOCOLS = "protocols"       # Protocol modeling (placeholder)
    G_TWIN_ALIGN = "twin_alignment" # Digital twin alignment
    H_GENERATE = "generate"         # Generate CORE XML
    I_3D_ARVR = "3d_arvr"           # 3D/AR/VR pipeline (future)


@dataclass
class ZoneConfig:
    """Network zone configuration"""
    name: str
    zone_type: str  # OT-Control, OT-Field, DMZ, IT, Corporate
    subnet: str = ""
    description: str = ""


@dataclass
class NodeConfig:
    """Node configuration for the topology"""
    node_id: int
    name: str
    node_type: str  # router, switch, host, docker, plc_placeholder, otsim_placeholder
    zone: str = ""
    x: float = 0.0
    y: float = 0.0
    services: List[str] = field(default_factory=list)
    docker_image: str = ""
    # Placeholder metadata for future capabilities
    placeholder_type: str = ""  # plc, otsim, sensor, protocol_endpoint
    placeholder_config: Dict[str, Any] = field(default_factory=dict)


@dataclass
class LinkConfig:
    """Link configuration"""
    node1_id: int
    node2_id: int
    bandwidth: int = 100000000
    delay: int = 0
    loss: float = 0.0


@dataclass
class PLCPlaceholder:
    """Placeholder for PLC configuration (future capability)"""
    name: str
    plc_type: str = "OpenPLC"  # OpenPLC, SoftPLC, etc.
    language: str = "ST"  # ST, Ladder, FBD
    io_mapping: Dict[str, str] = field(default_factory=dict)  # signal_name -> address
    process_description: str = ""
    connected_otsim: str = ""


@dataclass
class OTSimPlaceholder:
    """Placeholder for OT-sim process model (future capability)"""
    name: str
    process_type: str = ""  # tank, pump, valve, conveyor, transformer, etc.
    physical_units: Dict[str, str] = field(default_factory=dict)  # signal -> unit
    signals: List[str] = field(default_factory=list)  # Level, Flow, Pressure, etc.
    behavior_description: str = ""
    connected_plcs: List[str] = field(default_factory=list)


@dataclass
class SensorPlaceholder:
    """Placeholder for sensor/remote data (future capability)"""
    name: str
    sensor_type: str = ""  # online_feed, local_sensor, remote_tailscale
    data_source: str = ""  # URL, device ID, etc.
    signals: List[str] = field(default_factory=list)
    update_interval: int = 60  # seconds
    description: str = ""


@dataclass
class ProtocolPlaceholder:
    """Placeholder for protocol configuration (future capability)"""
    name: str
    protocol: str = ""  # Modbus, DNP3, OPC-UA, IEC61850, MQTT
    role: str = ""  # master, slave, client, server
    endpoints: List[str] = field(default_factory=list)
    description: str = ""


@dataclass
class PhysicalTwinPlaceholder:
    """Placeholder for 3D/AR/VR physical twin (future capability)"""
    name: str
    model_type: str = ""  # valve, tank, pipeline, robot, transformer, etc.
    scale: Dict[str, float] = field(default_factory=dict)  # x, y, z dimensions
    materials: List[str] = field(default_factory=list)
    moving_parts: List[str] = field(default_factory=list)
    physics_type: str = ""  # rigid, joints, fluids, conveyors
    interactions: List[str] = field(default_factory=list)
    cyber_mappings: Dict[str, str] = field(default_factory=dict)  # plc_signal -> 3d_property
    ar_vr_targets: List[str] = field(default_factory=list)  # Quest, WebXR, ARKit, etc.
    description: str = ""


@dataclass
class FeatureProgressLog:
    """Tracks implemented, planned, and future features"""
    implemented: List[str] = field(default_factory=list)
    planned: List[str] = field(default_factory=list)
    future_3d_arvr: List[str] = field(default_factory=list)
    notes: List[str] = field(default_factory=list)


@dataclass
class DigitalTwinProject:
    """Complete project state for persistence"""
    project_id: str
    name: str
    description: str
    created_at: str
    updated_at: str
    current_stage: str
    is_real_site: bool  # True = digital twin of real site, False = conceptual model

    # Core topology elements (SUPPORTED)
    zones: List[ZoneConfig] = field(default_factory=list)
    nodes: List[NodeConfig] = field(default_factory=list)
    links: List[LinkConfig] = field(default_factory=list)

    # Placeholders for future capabilities
    plc_placeholders: List[PLCPlaceholder] = field(default_factory=list)
    otsim_placeholders: List[OTSimPlaceholder] = field(default_factory=list)
    sensor_placeholders: List[SensorPlaceholder] = field(default_factory=list)
    protocol_placeholders: List[ProtocolPlaceholder] = field(default_factory=list)
    physical_twin_placeholders: List[PhysicalTwinPlaceholder] = field(default_factory=list)

    # Progress tracking
    progress_log: FeatureProgressLog = field(default_factory=FeatureProgressLog)

    # Generated outputs
    last_generated_xml: str = ""


class DigitalTwinBuilder:
    """Progressive Digital Twin Builder with session management"""

    PROJECTS_DIR = Path("/workspaces/core/core-mcp-server/projects")

    # Capability status mapping
    CAPABILITIES = {
        DesignStage.A_NETWORK: CapabilityStatus.READY,
        DesignStage.B_HOSTS: CapabilityStatus.READY,
        DesignStage.C_PLCS: CapabilityStatus.PLACEHOLDER,
        DesignStage.D_OTSIM: CapabilityStatus.PLACEHOLDER,
        DesignStage.E_SENSORS: CapabilityStatus.PLACEHOLDER,
        DesignStage.F_PROTOCOLS: CapabilityStatus.PLACEHOLDER,
        DesignStage.G_TWIN_ALIGN: CapabilityStatus.READY,
        DesignStage.H_GENERATE: CapabilityStatus.READY,
        DesignStage.I_3D_ARVR: CapabilityStatus.FUTURE,
    }

    def __init__(self):
        self.current_project: Optional[DigitalTwinProject] = None
        self.PROJECTS_DIR.mkdir(parents=True, exist_ok=True)

    # =========================================================================
    # Project Management
    # =========================================================================

    def new_project(self, name: str, description: str = "", is_real_site: bool = False) -> DigitalTwinProject:
        """Create a new digital twin project"""
        project = DigitalTwinProject(
            project_id=str(uuid.uuid4())[:8],
            name=name,
            description=description,
            created_at=datetime.now().isoformat(),
            updated_at=datetime.now().isoformat(),
            current_stage=DesignStage.A_NETWORK.value,
            is_real_site=is_real_site,
            progress_log=FeatureProgressLog(
                implemented=[],
                planned=[],
                future_3d_arvr=[],
                notes=[f"Project created: {name}"]
            )
        )
        self.current_project = project
        self.save_project()
        return project

    def save_project(self) -> bool:
        """Save current project to disk"""
        if not self.current_project:
            return False

        self.current_project.updated_at = datetime.now().isoformat()

        filepath = self.PROJECTS_DIR / f"{self.current_project.project_id}.json"

        # Convert dataclasses to dicts for JSON serialization
        data = self._project_to_dict(self.current_project)

        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)

        return True

    def load_project(self, project_id: str) -> Optional[DigitalTwinProject]:
        """Load a project from disk"""
        filepath = self.PROJECTS_DIR / f"{project_id}.json"

        if not filepath.exists():
            return None

        with open(filepath, 'r') as f:
            data = json.load(f)

        self.current_project = self._dict_to_project(data)
        return self.current_project

    def list_projects(self) -> List[Dict[str, str]]:
        """List all saved projects"""
        projects = []
        for filepath in self.PROJECTS_DIR.glob("*.json"):
            try:
                with open(filepath, 'r') as f:
                    data = json.load(f)
                projects.append({
                    'project_id': data.get('project_id', ''),
                    'name': data.get('name', ''),
                    'description': data.get('description', ''),
                    'updated_at': data.get('updated_at', ''),
                    'current_stage': data.get('current_stage', '')
                })
            except:
                pass
        return sorted(projects, key=lambda x: x.get('updated_at', ''), reverse=True)

    def delete_project(self, project_id: str) -> bool:
        """Delete a project"""
        filepath = self.PROJECTS_DIR / f"{project_id}.json"
        if filepath.exists():
            filepath.unlink()
            if self.current_project and self.current_project.project_id == project_id:
                self.current_project = None
            return True
        return False

    # =========================================================================
    # Stage A: Network Zones (SUPPORTED)
    # =========================================================================

    def add_zone(self, name: str, zone_type: str, subnet: str = "", description: str = "") -> ZoneConfig:
        """Add a network zone"""
        if not self.current_project:
            raise ValueError("No project loaded")

        zone = ZoneConfig(
            name=name,
            zone_type=zone_type,
            subnet=subnet,
            description=description
        )
        self.current_project.zones.append(zone)
        self._log_implemented(f"Zone: {name} ({zone_type})")
        self.save_project()
        return zone

    # =========================================================================
    # Stage B: Hosts & Containers (SUPPORTED)
    # =========================================================================

    def add_node(self, name: str, node_type: str, zone: str = "",
                 services: List[str] = None, docker_image: str = "",
                 x: float = 0, y: float = 0) -> NodeConfig:
        """Add a network node (host, router, switch, docker container)"""
        if not self.current_project:
            raise ValueError("No project loaded")

        node_id = len(self.current_project.nodes) + 1
        node = NodeConfig(
            node_id=node_id,
            name=name,
            node_type=node_type,
            zone=zone,
            x=x,
            y=y,
            services=services or [],
            docker_image=docker_image
        )
        self.current_project.nodes.append(node)
        self._log_implemented(f"Node: {name} ({node_type})")
        self.save_project()
        return node

    def add_link(self, node1_name: str, node2_name: str,
                 bandwidth: int = 100000000, delay: int = 0, loss: float = 0.0) -> Optional[LinkConfig]:
        """Add a link between two nodes"""
        if not self.current_project:
            raise ValueError("No project loaded")

        # Find node IDs by name
        node1_id = None
        node2_id = None
        for node in self.current_project.nodes:
            if node.name == node1_name:
                node1_id = node.node_id
            if node.name == node2_name:
                node2_id = node.node_id

        if node1_id is None or node2_id is None:
            return None

        link = LinkConfig(
            node1_id=node1_id,
            node2_id=node2_id,
            bandwidth=bandwidth,
            delay=delay,
            loss=loss
        )
        self.current_project.links.append(link)
        self._log_implemented(f"Link: {node1_name} <-> {node2_name}")
        self.save_project()
        return link

    # =========================================================================
    # Stage C: PLCs (PLACEHOLDER - captures requirements only)
    # =========================================================================

    def add_plc_placeholder(self, name: str, plc_type: str = "OpenPLC",
                           language: str = "ST", io_mapping: Dict[str, str] = None,
                           process_description: str = "", connected_otsim: str = "") -> PLCPlaceholder:
        """Add a PLC placeholder (requirements capture only)"""
        if not self.current_project:
            raise ValueError("No project loaded")

        plc = PLCPlaceholder(
            name=name,
            plc_type=plc_type,
            language=language,
            io_mapping=io_mapping or {},
            process_description=process_description,
            connected_otsim=connected_otsim
        )
        self.current_project.plc_placeholders.append(plc)

        # Also add as a placeholder node in the topology
        self.add_node(
            name=name,
            node_type="host",
            services=["DefaultRoute"],
            docker_image=""  # Will be OpenPLC when supported
        )
        self.current_project.nodes[-1].placeholder_type = "plc"
        self.current_project.nodes[-1].placeholder_config = asdict(plc)

        self._log_planned(f"PLC: {name} ({plc_type}, {language})")
        self.save_project()
        return plc

    # =========================================================================
    # Stage D: OT-sim Process Models (PLACEHOLDER)
    # =========================================================================

    def add_otsim_placeholder(self, name: str, process_type: str,
                              physical_units: Dict[str, str] = None,
                              signals: List[str] = None,
                              behavior_description: str = "",
                              connected_plcs: List[str] = None) -> OTSimPlaceholder:
        """Add an OT-sim process model placeholder"""
        if not self.current_project:
            raise ValueError("No project loaded")

        otsim = OTSimPlaceholder(
            name=name,
            process_type=process_type,
            physical_units=physical_units or {},
            signals=signals or [],
            behavior_description=behavior_description,
            connected_plcs=connected_plcs or []
        )
        self.current_project.otsim_placeholders.append(otsim)

        # Add as placeholder node
        self.add_node(name=name, node_type="host", services=[])
        self.current_project.nodes[-1].placeholder_type = "otsim"
        self.current_project.nodes[-1].placeholder_config = asdict(otsim)

        self._log_planned(f"OT-sim: {name} ({process_type})")
        self.save_project()
        return otsim

    # =========================================================================
    # Stage E: Sensors & Remote Data (PLACEHOLDER)
    # =========================================================================

    def add_sensor_placeholder(self, name: str, sensor_type: str,
                               data_source: str = "", signals: List[str] = None,
                               update_interval: int = 60, description: str = "") -> SensorPlaceholder:
        """Add a sensor/remote data placeholder"""
        if not self.current_project:
            raise ValueError("No project loaded")

        sensor = SensorPlaceholder(
            name=name,
            sensor_type=sensor_type,
            data_source=data_source,
            signals=signals or [],
            update_interval=update_interval,
            description=description
        )
        self.current_project.sensor_placeholders.append(sensor)

        # Add as placeholder node
        self.add_node(name=name, node_type="host", services=[])
        self.current_project.nodes[-1].placeholder_type = "sensor"
        self.current_project.nodes[-1].placeholder_config = asdict(sensor)

        self._log_planned(f"Sensor: {name} ({sensor_type})")
        self.save_project()
        return sensor

    # =========================================================================
    # Stage F: Protocol Modeling (PLACEHOLDER)
    # =========================================================================

    def add_protocol_placeholder(self, name: str, protocol: str,
                                 role: str = "", endpoints: List[str] = None,
                                 description: str = "") -> ProtocolPlaceholder:
        """Add a protocol configuration placeholder"""
        if not self.current_project:
            raise ValueError("No project loaded")

        proto = ProtocolPlaceholder(
            name=name,
            protocol=protocol,
            role=role,
            endpoints=endpoints or [],
            description=description
        )
        self.current_project.protocol_placeholders.append(proto)
        self._log_planned(f"Protocol: {protocol} ({role}) - {name}")
        self.save_project()
        return proto

    # =========================================================================
    # Stage I: 3D/AR/VR Physical Twin (FUTURE - requirements capture)
    # =========================================================================

    def add_physical_twin_placeholder(self, name: str, model_type: str,
                                      scale: Dict[str, float] = None,
                                      materials: List[str] = None,
                                      moving_parts: List[str] = None,
                                      physics_type: str = "",
                                      interactions: List[str] = None,
                                      cyber_mappings: Dict[str, str] = None,
                                      ar_vr_targets: List[str] = None,
                                      description: str = "") -> PhysicalTwinPlaceholder:
        """Add a 3D/AR/VR physical twin placeholder"""
        if not self.current_project:
            raise ValueError("No project loaded")

        twin = PhysicalTwinPlaceholder(
            name=name,
            model_type=model_type,
            scale=scale or {},
            materials=materials or [],
            moving_parts=moving_parts or [],
            physics_type=physics_type,
            interactions=interactions or [],
            cyber_mappings=cyber_mappings or {},
            ar_vr_targets=ar_vr_targets or [],
            description=description
        )
        self.current_project.physical_twin_placeholders.append(twin)
        self._log_future_3d(f"3D Model: {name} ({model_type}) - AR/VR: {', '.join(ar_vr_targets or ['TBD'])}")
        self.save_project()
        return twin

    # =========================================================================
    # Stage H: Generate CORE XML (SUPPORTED)
    # =========================================================================

    def generate_xml(self) -> str:
        """Generate CORE XML from current project"""
        if not self.current_project:
            raise ValueError("No project loaded")

        # Use the existing topology generator
        from core_mcp.topology_generator import TopologyGenerator

        gen = TopologyGenerator()

        # Add nodes
        for node in self.current_project.nodes:
            gen.add_node(
                name=node.name,
                node_type=node.node_type,
                x=node.x,
                y=node.y,
                services=node.services,
                image=node.docker_image if node.docker_image else None
            )

        # Add links
        for link in self.current_project.links:
            node1_name = None
            node2_name = None
            for node in self.current_project.nodes:
                if node.node_id == link.node1_id:
                    node1_name = node.name
                if node.node_id == link.node2_id:
                    node2_name = node.name
            if node1_name and node2_name:
                gen.add_link(node1_name, node2_name, bandwidth=link.bandwidth, delay=link.delay)

        xml = gen.to_xml()

        # Add placeholder comments
        xml = self._add_placeholder_comments(xml)

        self.current_project.last_generated_xml = xml
        self.save_project()
        return xml

    def _add_placeholder_comments(self, xml: str) -> str:
        """Add XML comments for placeholder elements"""
        comments = []

        if self.current_project.plc_placeholders:
            comments.append("<!-- PLC PLACEHOLDERS (Future: OpenPLC Docker) -->")
            for plc in self.current_project.plc_placeholders:
                comments.append(f"<!--   {plc.name}: {plc.plc_type}, Language={plc.language} -->")

        if self.current_project.otsim_placeholders:
            comments.append("<!-- OT-SIM PLACEHOLDERS (Future: Process Models) -->")
            for otsim in self.current_project.otsim_placeholders:
                comments.append(f"<!--   {otsim.name}: {otsim.process_type}, Signals={otsim.signals} -->")

        if self.current_project.sensor_placeholders:
            comments.append("<!-- SENSOR PLACEHOLDERS (Future: Remote Data) -->")
            for sensor in self.current_project.sensor_placeholders:
                comments.append(f"<!--   {sensor.name}: {sensor.sensor_type}, Source={sensor.data_source} -->")

        if self.current_project.protocol_placeholders:
            comments.append("<!-- PROTOCOL PLACEHOLDERS (Future: Modbus/DNP3/OPC-UA) -->")
            for proto in self.current_project.protocol_placeholders:
                comments.append(f"<!--   {proto.name}: {proto.protocol} ({proto.role}) -->")

        if self.current_project.physical_twin_placeholders:
            comments.append("<!-- 3D/AR/VR PLACEHOLDERS (Future: Physical Twin) -->")
            for twin in self.current_project.physical_twin_placeholders:
                comments.append(f"<!--   {twin.name}: {twin.model_type}, AR/VR={twin.ar_vr_targets} -->")

        if comments:
            # Insert comments before closing </scenario> tag
            comment_block = "\n  " + "\n  ".join(comments) + "\n"
            xml = xml.replace("</scenario>", comment_block + "</scenario>")

        return xml

    # =========================================================================
    # Progress Log Management
    # =========================================================================

    def _log_implemented(self, item: str):
        if self.current_project:
            self.current_project.progress_log.implemented.append(item)

    def _log_planned(self, item: str):
        if self.current_project:
            self.current_project.progress_log.planned.append(item)

    def _log_future_3d(self, item: str):
        if self.current_project:
            self.current_project.progress_log.future_3d_arvr.append(item)

    def add_note(self, note: str):
        if self.current_project:
            self.current_project.progress_log.notes.append(f"[{datetime.now().strftime('%Y-%m-%d %H:%M')}] {note}")
            self.save_project()

    def get_progress_summary(self) -> Dict[str, Any]:
        """Get a summary of project progress"""
        if not self.current_project:
            return {}

        return {
            'project_name': self.current_project.name,
            'current_stage': self.current_project.current_stage,
            'is_real_site': self.current_project.is_real_site,
            'counts': {
                'zones': len(self.current_project.zones),
                'nodes': len(self.current_project.nodes),
                'links': len(self.current_project.links),
                'plc_placeholders': len(self.current_project.plc_placeholders),
                'otsim_placeholders': len(self.current_project.otsim_placeholders),
                'sensor_placeholders': len(self.current_project.sensor_placeholders),
                'protocol_placeholders': len(self.current_project.protocol_placeholders),
                'physical_twin_placeholders': len(self.current_project.physical_twin_placeholders),
            },
            'progress_log': asdict(self.current_project.progress_log)
        }

    # =========================================================================
    # Serialization Helpers
    # =========================================================================

    def _project_to_dict(self, project: DigitalTwinProject) -> Dict:
        """Convert project to dictionary for JSON serialization"""
        return {
            'project_id': project.project_id,
            'name': project.name,
            'description': project.description,
            'created_at': project.created_at,
            'updated_at': project.updated_at,
            'current_stage': project.current_stage,
            'is_real_site': project.is_real_site,
            'zones': [asdict(z) for z in project.zones],
            'nodes': [asdict(n) for n in project.nodes],
            'links': [asdict(l) for l in project.links],
            'plc_placeholders': [asdict(p) for p in project.plc_placeholders],
            'otsim_placeholders': [asdict(o) for o in project.otsim_placeholders],
            'sensor_placeholders': [asdict(s) for s in project.sensor_placeholders],
            'protocol_placeholders': [asdict(p) for p in project.protocol_placeholders],
            'physical_twin_placeholders': [asdict(t) for t in project.physical_twin_placeholders],
            'progress_log': asdict(project.progress_log),
            'last_generated_xml': project.last_generated_xml,
        }

    def _dict_to_project(self, data: Dict) -> DigitalTwinProject:
        """Convert dictionary to project"""
        return DigitalTwinProject(
            project_id=data.get('project_id', ''),
            name=data.get('name', ''),
            description=data.get('description', ''),
            created_at=data.get('created_at', ''),
            updated_at=data.get('updated_at', ''),
            current_stage=data.get('current_stage', ''),
            is_real_site=data.get('is_real_site', False),
            zones=[ZoneConfig(**z) for z in data.get('zones', [])],
            nodes=[NodeConfig(**n) for n in data.get('nodes', [])],
            links=[LinkConfig(**l) for l in data.get('links', [])],
            plc_placeholders=[PLCPlaceholder(**p) for p in data.get('plc_placeholders', [])],
            otsim_placeholders=[OTSimPlaceholder(**o) for o in data.get('otsim_placeholders', [])],
            sensor_placeholders=[SensorPlaceholder(**s) for s in data.get('sensor_placeholders', [])],
            protocol_placeholders=[ProtocolPlaceholder(**p) for p in data.get('protocol_placeholders', [])],
            physical_twin_placeholders=[PhysicalTwinPlaceholder(**t) for t in data.get('physical_twin_placeholders', [])],
            progress_log=FeatureProgressLog(**data.get('progress_log', {})),
            last_generated_xml=data.get('last_generated_xml', ''),
        )


# Singleton instance for web UI
builder = DigitalTwinBuilder()
