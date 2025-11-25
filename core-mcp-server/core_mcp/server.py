#!/usr/bin/env python3
"""
CORE MCP Server - Provides LLM tools for generating CORE network topologies.

This server implements the Model Context Protocol (MCP) to allow LLMs to:
- Create CORE network topologies from natural language descriptions
- Add nodes (routers, switches, hosts, wireless networks, EMANE networks)
- Create links between nodes
- Configure services (routing, DHCP, HTTP, FTP, SSH, etc.)
- Generate Python scripts or XML files for CORE
"""

import asyncio
import json
import logging
from typing import Any

from mcp.server import Server
from mcp.types import Tool, TextContent, ImageContent, EmbeddedResource
from pydantic import BaseModel, Field

from .topology_generator import TopologyGenerator, NodeConfig, LinkConfig, ServiceConfig

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create MCP server instance
app = Server("core-topology-generator")

# Global topology generator
generator = TopologyGenerator()


class CreateNodeArgs(BaseModel):
    """Arguments for creating a node"""
    node_id: int = Field(description="Unique node ID")
    name: str = Field(description="Node name")
    node_type: str = Field(
        description="Node type: 'router', 'switch', 'hub', 'host', 'pc', 'mdr', 'wireless', 'emane', 'docker'"
    )
    x: float = Field(default=100.0, description="X position")
    y: float = Field(default=100.0, description="Y position")
    model: str | None = Field(default=None, description="Node model (e.g., 'mdr' for wireless)")
    image: str | None = Field(default=None, description="Docker image for docker nodes")
    services: list[str] = Field(
        default_factory=list,
        description="List of services: zebra, OSPFv2, OSPFv3, OSPFv3MDR, IPForward, DefaultRoute, SSH, HTTP, FTP, DHCP, etc."
    )


class CreateLinkArgs(BaseModel):
    """Arguments for creating a link"""
    node1_id: int = Field(description="First node ID")
    node2_id: int = Field(description="Second node ID")
    iface1_id: int | None = Field(default=None, description="Interface ID on node1")
    iface2_id: int | None = Field(default=None, description="Interface ID on node2")
    ip4_1: str | None = Field(default=None, description="IPv4 address for node1 interface")
    ip4_2: str | None = Field(default=None, description="IPv4 address for node2 interface")
    bandwidth: int = Field(default=100000000, description="Bandwidth in bps")
    delay: int = Field(default=0, description="Delay in microseconds")
    loss: float = Field(default=0.0, description="Loss percentage (0-100)")
    jitter: int = Field(default=0, description="Jitter in microseconds")


class GenerateTopologyArgs(BaseModel):
    """Arguments for generating a complete topology from natural language"""
    description: str = Field(description="Natural language description of the network topology")
    output_format: str = Field(
        default="python",
        description="Output format: 'python' for Python script, 'xml' for CORE XML file"
    )


class SetWLANConfigArgs(BaseModel):
    """Arguments for configuring a WLAN node"""
    node_id: int = Field(description="WLAN node ID")
    range_meters: int = Field(default=275, description="Wireless range in meters")
    bandwidth: int = Field(default=54000000, description="Bandwidth in bps")
    delay: int = Field(default=20000, description="Delay in microseconds")
    jitter: int = Field(default=0, description="Jitter in microseconds")
    loss: float = Field(default=0.0, description="Loss percentage")


@app.list_tools()
async def list_tools() -> list[Tool]:
    """List available MCP tools for CORE topology generation."""
    return [
        Tool(
            name="create_node",
            description="Create a network node (router, switch, host, wireless network, etc.)",
            inputSchema=CreateNodeArgs.model_json_schema()
        ),
        Tool(
            name="create_link",
            description="Create a link between two nodes with optional bandwidth/delay/loss settings",
            inputSchema=CreateLinkArgs.model_json_schema()
        ),
        Tool(
            name="set_wlan_config",
            description="Configure a WLAN node's wireless parameters",
            inputSchema=SetWLANConfigArgs.model_json_schema()
        ),
        Tool(
            name="generate_topology",
            description="Generate a complete CORE network topology from a natural language description",
            inputSchema=GenerateTopologyArgs.model_json_schema()
        ),
        Tool(
            name="save_topology",
            description="Save the current topology to a file",
            inputSchema={
                "type": "object",
                "properties": {
                    "filename": {
                        "type": "string",
                        "description": "Output filename (ends with .py or .xml)"
                    },
                    "format": {
                        "type": "string",
                        "enum": ["python", "xml"],
                        "description": "Output format"
                    }
                },
                "required": ["filename"]
            }
        ),
        Tool(
            name="clear_topology",
            description="Clear the current topology and start fresh",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        Tool(
            name="get_topology_summary",
            description="Get a summary of the current topology",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: Any) -> list[TextContent]:
    """Handle tool calls from the LLM."""
    try:
        if name == "create_node":
            args = CreateNodeArgs(**arguments)
            node = NodeConfig(
                node_id=args.node_id,
                name=args.name,
                node_type=args.node_type,
                x=args.x,
                y=args.y,
                model=args.model,
                image=args.image,
                services=args.services
            )
            generator.add_node(node)
            return [TextContent(
                type="text",
                text=f"Created {args.node_type} node: {args.name} (ID: {args.node_id}) at position ({args.x}, {args.y})"
            )]

        elif name == "create_link":
            args = CreateLinkArgs(**arguments)
            link = LinkConfig(
                node1_id=args.node1_id,
                node2_id=args.node2_id,
                iface1_id=args.iface1_id,
                iface2_id=args.iface2_id,
                ip4_1=args.ip4_1,
                ip4_2=args.ip4_2,
                bandwidth=args.bandwidth,
                delay=args.delay,
                loss=args.loss,
                jitter=args.jitter
            )
            generator.add_link(link)
            node1_name = generator.get_node_name(args.node1_id)
            node2_name = generator.get_node_name(args.node2_id)
            return [TextContent(
                type="text",
                text=f"Created link between {node1_name} (ID: {args.node1_id}) and {node2_name} (ID: {args.node2_id})"
            )]

        elif name == "set_wlan_config":
            args = SetWLANConfigArgs(**arguments)
            generator.set_wlan_config(
                args.node_id,
                range_meters=args.range_meters,
                bandwidth=args.bandwidth,
                delay=args.delay,
                jitter=args.jitter,
                loss=args.loss
            )
            return [TextContent(
                type="text",
                text=f"Configured WLAN node {args.node_id} with range={args.range_meters}m, bandwidth={args.bandwidth}bps"
            )]

        elif name == "generate_topology":
            args = GenerateTopologyArgs(**arguments)
            result = generator.generate_from_description(args.description)
            output = generator.to_python_script() if args.output_format == "python" else generator.to_xml()

            return [TextContent(
                type="text",
                text=f"Generated topology from description:\n\n{result}\n\nTopology code:\n\n{output}"
            )]

        elif name == "save_topology":
            filename = arguments.get("filename", "topology.py")
            output_format = arguments.get("format", "python" if filename.endswith(".py") else "xml")

            if output_format == "python":
                content = generator.to_python_script()
            else:
                content = generator.to_xml()

            with open(filename, "w") as f:
                f.write(content)

            return [TextContent(
                type="text",
                text=f"Saved topology to {filename} ({output_format} format)"
            )]

        elif name == "clear_topology":
            generator.clear()
            return [TextContent(
                type="text",
                text="Cleared topology. Starting fresh."
            )]

        elif name == "get_topology_summary":
            summary = generator.get_summary()
            return [TextContent(
                type="text",
                text=f"Topology Summary:\n{summary}"
            )]

        else:
            return [TextContent(
                type="text",
                text=f"Unknown tool: {name}"
            )]

    except Exception as e:
        logger.error(f"Error executing tool {name}: {e}", exc_info=True)
        return [TextContent(
            type="text",
            text=f"Error: {str(e)}"
        )]


async def main():
    """Run the MCP server."""
    from mcp.server.stdio import stdio_server

    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )


if __name__ == "__main__":
    asyncio.run(main())
