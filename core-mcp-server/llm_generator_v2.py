#!/usr/bin/env python3
"""
LLM-Powered Topology Generator V2 with Enhanced XML Knowledge

Includes detailed CORE XML specification and examples for the LLM.
"""

import json
import os
import sys
import subprocess
from typing import Dict, List, Optional, Tuple

import openai

sys.path.insert(0, '/workspaces/core/core-mcp-server')
from core_mcp.topology_generator import TopologyGenerator, NodeConfig, LinkConfig

# Configure OpenAI - set OPENAI_API_KEY environment variable
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
if not OPENAI_API_KEY:
    print("Warning: OPENAI_API_KEY environment variable not set")
openai.api_key = OPENAI_API_KEY

SYSTEM_PROMPT = """You are a network topology design expert. Create detailed network topology specifications for CORE Network Emulator.

# CRITICAL NETWORK ENGINEERING RULES

## Layer 2 vs Layer 3
1. **Switch/Hub (Layer 2)**: All connected devices on SAME subnet
   - Example: switch1 connects to host1 (10.0.1.2), host2 (10.0.1.3), host3 (10.0.1.4)

2. **Router (Layer 3)**: Each interface on DIFFERENT subnet
   - Example: R1-R2 link uses 10.0.1.0/24, R2-R3 link uses 10.0.2.0/24

## Router-to-Switch Topology
When a router connects to a switch with hosts:
- Router interface: 10.0.X.1/24
- All hosts behind switch: 10.0.X.2, 10.0.X.3, 10.0.X.4, etc. (same subnet!)

# CORE XML FORMAT SPECIFICATION

## Complete Example: Router + Switch + 2 Hosts

```xml
<?xml version="1.0" ?>
<scenario name="Example Network">
  <networks>
    <network id="2" name="switch1" type="SWITCH">
      <position x="300.0" y="300.0" lat="0.0" lon="0.0" alt="0.0"/>
    </network>
  </networks>
  <devices>
    <device id="1" name="router1" type="router">
      <position x="300.0" y="150.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="zebra"/>
        <service name="OSPFv2"/>
        <service name="OSPFv3"/>
        <service name="IPForward"/>
      </services>
    </device>
    <device id="3" name="host1" type="host">
      <position x="200.0" y="350.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="DefaultRoute"/>
      </services>
    </device>
    <device id="4" name="host2" type="host">
      <position x="400.0" y="350.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="DefaultRoute"/>
      </services>
    </device>
  </devices>
  <links>
    <!-- Router to Switch: Router gets IP, switch doesn't -->
    <link node1="1" node2="2">
      <iface1 id="0" name="eth0" ip4="10.0.10.1" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <!-- Switch to Host: Only host gets IP (SAME subnet as router!) -->
    <link node1="2" node2="3">
      <iface2 id="0" name="eth0" ip4="10.0.10.2" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <link node1="2" node2="4">
      <iface2 id="0" name="eth0" ip4="10.0.10.3" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
  </links>
</scenario>
```

## Key XML Rules

1. **Switches/Hubs go in `<networks>` section** with type="SWITCH" or type="HUB"
2. **Routers/Hosts go in `<devices>` section**
3. **Links**:
   - Router-to-Router: Both interfaces get IPs (different subnets)
   - Router-to-Switch: Router interface gets IP (iface1), switch has no IP
   - Switch-to-Host: Only host gets IP (iface2), on SAME subnet as router
   - Host-to-Host (direct): Both get IPs on same subnet

4. **Interface IDs**: For each node, interfaces are numbered 0, 1, 2, etc.
   - If router1 has 3 links, they use id="0", id="1", id="2"

5. **Services**:
   - Routers: ["zebra", "OSPFv2", "OSPFv3", "IPForward"]
   - Hosts: ["DefaultRoute"]
   - Switches/Hubs: no services (in networks section)

# YOUR TASK

Generate a JSON specification that I will convert to CORE XML. Use this format:

```json
{
  "description": "Brief description",
  "nodes": [
    {
      "id": 1,
      "name": "router1",
      "type": "router|switch|hub|host",
      "x": 300.0,
      "y": 150.0,
      "services": ["zebra", "OSPFv2", "OSPFv3", "IPForward"]
    }
  ],
  "links": [
    {
      "node1_id": 1,
      "node2_id": 2,
      "iface1_id": 0,
      "iface2_id": 0,
      "ip4_1": "10.0.1.1",
      "ip4_2": "10.0.1.2"
    }
  ]
}
```

## Link IP Address Rules:

1. **Router-to-Router**: Set BOTH ip4_1 and ip4_2 (different subnet per link)
2. **Router-to-Switch**: Set ip4_1 for router, leave ip4_2 empty
3. **Switch-to-Host**: Leave ip4_1 empty, set ip4_2 for host (SAME subnet as router interface!)
4. **Switch-to-Switch**: No IPs needed

## Interface ID Rules:

For each node, number interfaces sequentially starting from 0.
Example: If router1 has 4 links, use iface1_id: 0, 1, 2, 3

RESPOND WITH ONLY THE JSON, NO OTHER TEXT."""


class LLMTopologyGeneratorV2:
    def __init__(self, api_key: str):
        self.api_key = api_key
        openai.api_key = api_key
        self.max_retries = 3

    def generate_topology(self, user_request: str) -> Tuple[bool, str, Optional[TopologyGenerator]]:
        """Generate topology with validation loop."""
        print(f"\n{'='*70}")
        print(f"🤖 LLM Topology Generator V2 (Enhanced)")
        print(f"{'='*70}")
        print(f"\n📝 User Request: {user_request}\n")

        for attempt in range(1, self.max_retries + 1):
            print(f"🔄 Attempt {attempt}/{self.max_retries}")

            try:
                # Call LLM
                spec = self._call_llm(user_request, attempt)
                if not spec:
                    return False, "Failed to get valid JSON from LLM", None

                # Auto-fix common issues
                spec = self._auto_fix_spec(spec)

                # Build topology
                generator = self._build_topology(spec)

                # Validate
                is_valid, errors = self._validate_topology(generator, spec)

                if is_valid:
                    print(f"✅ Topology validated successfully!")
                    return True, spec.get('description', 'Topology created'), generator
                else:
                    print(f"❌ Validation failed:")
                    for error in errors:
                        print(f"   - {error}")

                    if attempt < self.max_retries:
                        print(f"   🔧 Sending feedback to LLM...")
                        user_request += f"\n\nPREVIOUS ERRORS: {'. '.join(errors)}. FIX THESE!"
                    else:
                        return False, f"Failed after {self.max_retries} attempts: {errors[0]}", None

            except Exception as e:
                print(f"❌ Error: {str(e)}")
                if attempt == self.max_retries:
                    return False, f"Failed: {str(e)}", None

        return False, "Failed to generate valid topology", None

    def _call_llm(self, user_request: str, attempt: int) -> Optional[Dict]:
        """Call OpenAI API."""
        print(f"   📡 Calling OpenAI API...")

        try:
            response = openai.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_request}
                ],
                temperature=0.7,
                max_tokens=3000
            )

            content = response.choices[0].message.content.strip()
            print(f"   ✅ Received response")

            # Extract JSON
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            spec = json.loads(content)
            print(f"   ✅ Parsed: {len(spec.get('nodes', []))} nodes, {len(spec.get('links', []))} links")

            return spec

        except Exception as e:
            print(f"   ❌ Failed: {e}")
            return None

    def _auto_fix_spec(self, spec: Dict) -> Dict:
        """Auto-fix common issues in specification."""
        print(f"   🔧 Auto-fixing common issues...")

        # Fix: Ensure interface IDs are assigned properly
        interface_counters = {}
        for link in spec.get('links', []):
            node1_id = link['node1_id']
            node2_id = link['node2_id']

            # Assign interface IDs if missing
            if 'iface1_id' not in link or link['iface1_id'] is None:
                link['iface1_id'] = interface_counters.get(node1_id, 0)
                interface_counters[node1_id] = interface_counters.get(node1_id, 0) + 1

            if 'iface2_id' not in link or link['iface2_id'] is None:
                link['iface2_id'] = interface_counters.get(node2_id, 0)
                interface_counters[node2_id] = interface_counters.get(node2_id, 0) + 1

        print(f"   ✅ Applied auto-fixes")
        return spec

    def _build_topology(self, spec: Dict) -> TopologyGenerator:
        """Build topology from specification."""
        print(f"   🏗️  Building topology...")

        gen = TopologyGenerator()
        gen.session_name = spec.get('description', 'LLM Generated')

        # Add nodes
        for node_spec in spec.get('nodes', []):
            node = NodeConfig(
                node_id=node_spec['id'],
                name=node_spec['name'],
                node_type=node_spec['type'],
                x=node_spec.get('x', 100.0),
                y=node_spec.get('y', 100.0),
                services=node_spec.get('services', []),
                model=node_spec.get('model'),
                image=node_spec.get('image')
            )
            gen.add_node(node)

        # Add links
        for link_spec in spec.get('links', []):
            link = LinkConfig(
                node1_id=link_spec['node1_id'],
                node2_id=link_spec['node2_id'],
                iface1_id=link_spec.get('iface1_id', 0),
                iface2_id=link_spec.get('iface2_id', 0),
                ip4_1=link_spec.get('ip4_1'),
                ip4_2=link_spec.get('ip4_2'),
                bandwidth=link_spec.get('bandwidth', 100000000),
                delay=link_spec.get('delay', 0),
                loss=link_spec.get('loss', 0.0)
            )
            gen.add_link(link)

        print(f"   ✅ Built: {len(gen.nodes)} nodes, {len(gen.links)} links")
        return gen

    def _validate_topology(self, gen: TopologyGenerator, spec: Dict) -> Tuple[bool, List[str]]:
        """Validate topology with detailed checks."""
        print(f"   🔍 Validating...")
        errors = []

        # Check 1: Nodes exist
        for link in gen.links:
            if link.node1_id not in gen.nodes:
                errors.append(f"Link references missing node {link.node1_id}")
            if link.node2_id not in gen.nodes:
                errors.append(f"Link references missing node {link.node2_id}")

        # Check 2: Switch subnetting
        for switch_id, switch in gen.nodes.items():
            if switch.node_type in ['switch', 'hub']:
                connected_ips = []
                for link in gen.links:
                    if link.node1_id == switch_id and link.ip4_2:
                        connected_ips.append(link.ip4_2)
                    elif link.node2_id == switch_id and link.ip4_1:
                        connected_ips.append(link.ip4_1)

                if connected_ips:
                    subnets = set(['.'.join(ip.split('.')[:3]) for ip in connected_ips])
                    if len(subnets) > 1:
                        errors.append(f"Switch {switch.name} has hosts on different subnets: {subnets}")

        # Check 3: Router-to-switch links must have router IP
        for link in gen.links:
            node1 = gen.nodes.get(link.node1_id)
            node2 = gen.nodes.get(link.node2_id)

            if node1 and node2:
                # Router -> Switch
                if node1.node_type == 'router' and node2.node_type in ['switch', 'hub']:
                    if not link.ip4_1:
                        errors.append(f"Router {node1.name} -> Switch {node2.name} missing router IP (ip4_1)")

                # Switch -> Router
                if node1.node_type in ['switch', 'hub'] and node2.node_type == 'router':
                    if not link.ip4_2:
                        errors.append(f"Switch {node1.name} -> Router {node2.name} missing router IP (ip4_2)")

        # Check 4: Routers need IPForward
        for node_id, node in gen.nodes.items():
            if node.node_type == 'router' and 'IPForward' not in node.services:
                errors.append(f"Router {node.name} missing IPForward service")

        # Check 5: Basic sanity
        if len(gen.nodes) == 0:
            errors.append("No nodes in topology")
        if len(gen.links) == 0 and len(gen.nodes) > 1:
            errors.append("Multiple nodes but no links")

        return (len(errors) == 0, errors)

    def deploy_to_core(self, gen: TopologyGenerator, filename: str = "llm_topology.xml") -> Tuple[bool, str]:
        """Deploy to CORE container and auto-open."""
        print(f"\n{'='*70}")
        print(f"🚀 Deploying to CORE")
        print(f"{'='*70}\n")

        try:
            # Save XML
            local_path = f"/tmp/{filename}"
            with open(local_path, 'w') as f:
                f.write(gen.to_xml())
            print(f"✅ Saved: {local_path}")

            # Test XML validity
            try:
                import xml.etree.ElementTree as ET
                ET.parse(local_path)
                print(f"✅ XML is valid")
            except Exception as e:
                return False, f"Invalid XML: {e}"

            # Copy to container
            container_path = f"/root/topologies/{filename}"
            cmd = f"docker cp {local_path} core-novnc:{container_path}"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                return False, f"Copy failed: {result.stderr}"

            print(f"✅ Copied to container: {container_path}")

            # Close existing CORE session
            print(f"🔄 Closing existing CORE session...")
            subprocess.run("docker exec core-novnc pkill -f core-gui || true", shell=True, capture_output=True)

            # Open new topology
            print(f"🎯 Opening in CORE GUI...")
            open_cmd = f"""docker exec core-novnc bash -c '
                export DISPLAY=:1
                nohup core-gui {container_path} > /tmp/core-gui.log 2>&1 &
                sleep 3
            '"""
            subprocess.run(open_cmd, shell=True, capture_output=True)

            print(f"✅ Opened in CORE GUI!")
            return True, f"Success! Open noVNC to see: {container_path}"

        except Exception as e:
            return False, f"Deployment failed: {e}"


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description='LLM Topology Generator V2')
    parser.add_argument('request', nargs='?', help='Topology description')
    parser.add_argument('--no-deploy', action='store_true', help="Don't deploy to CORE")
    parser.add_argument('--output', default='llm_topology.xml', help='Output filename')
    args = parser.parse_args()

    # Get request
    if args.request:
        request = args.request
    else:
        print("Enter topology description:")
        request = input("> ").strip()

    if not request:
        print("❌ No description provided")
        sys.exit(1)

    # Generate
    generator = LLMTopologyGeneratorV2(OPENAI_API_KEY)
    success, message, topology = generator.generate_topology(request)

    if not success:
        print(f"\n❌ Failed: {message}")
        sys.exit(1)

    print(f"\n✅ {message}")
    print(f"\n{topology.get_summary()}")

    # Deploy
    if not args.no_deploy:
        success, deploy_msg = generator.deploy_to_core(topology, args.output)
        print(f"\n{'✅' if success else '⚠️ '} {deploy_msg}")
        if success:
            print(f"\n📺 Check noVNC browser tab!")
    else:
        with open(f"/tmp/{args.output}", 'w') as f:
            f.write(topology.to_xml())
        print(f"\n💾 Saved to /tmp/{args.output}")

    print(f"\n{'='*70}\n")


if __name__ == '__main__':
    main()
