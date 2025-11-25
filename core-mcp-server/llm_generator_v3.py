#!/usr/bin/env python3
"""
LLM Topology Generator V3 - Example-Driven with Working XML Templates

This version provides the LLM with complete working XML examples
to ensure it generates valid CORE topologies.
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

SYSTEM_PROMPT_WITH_EXAMPLES = """You are a network topology expert. Generate CORE XML topologies following EXACT format rules.

# STRICT XML FORMAT RULES FOR NRL CORE

## Structure
```xml
<?xml version="1.0" ?>
<scenario name="Topology Name">
  <networks>
    <!-- Switches and Hubs go here -->
  </networks>
  <devices>
    <!-- Routers and Hosts go here -->
  </devices>
  <links>
    <!-- All connections go here -->
  </links>
</scenario>
```

## WORKING EXAMPLE 1: Router + Switch + 2 Hosts

```xml
<?xml version="1.0" ?>
<scenario name="Simple Network">
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
      <position x="200.0" y="400.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="DefaultRoute"/>
      </services>
    </device>
    <device id="4" name="host2" type="host">
      <position x="400.0" y="400.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="DefaultRoute"/>
      </services>
    </device>
  </devices>
  <links>
    <!-- Router to Switch: NO IP addresses on this link -->
    <link node1="1" node2="2">
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <!-- Switch to Host1: Host gets IP 10.0.10.2 -->
    <link node1="2" node2="3">
      <iface2 id="0" name="eth0" ip4="10.0.10.2" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <!-- Switch to Host2: Host gets IP 10.0.10.3 (SAME SUBNET!) -->
    <link node1="2" node2="4">
      <iface2 id="0" name="eth0" ip4="10.0.10.3" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
  </links>
</scenario>
```

## WORKING EXAMPLE 2: 3-Router Ring

```xml
<?xml version="1.0" ?>
<scenario name="Router Ring">
  <networks/>
  <devices>
    <device id="1" name="router1" type="router">
      <position x="300.0" y="100.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="zebra"/>
        <service name="OSPFv2"/>
        <service name="OSPFv3"/>
        <service name="IPForward"/>
      </services>
    </device>
    <device id="2" name="router2" type="router">
      <position x="450.0" y="250.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="zebra"/>
        <service name="OSPFv2"/>
        <service name="OSPFv3"/>
        <service name="IPForward"/>
      </services>
    </device>
    <device id="3" name="router3" type="router">
      <position x="150.0" y="250.0" lat="0.0" lon="0.0" alt="0.0"/>
      <services>
        <service name="zebra"/>
        <service name="OSPFv2"/>
        <service name="OSPFv3"/>
        <service name="IPForward"/>
      </services>
    </device>
  </devices>
  <links>
    <!-- Router1 to Router2: Different subnet (10.0.1.0/24) -->
    <link node1="1" node2="2">
      <iface2 id="0" name="eth0" ip4="10.0.1.2" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <!-- Router2 to Router3: Different subnet (10.0.2.0/24) -->
    <link node1="2" node2="3">
      <iface2 id="0" name="eth0" ip4="10.0.2.2" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
    <!-- Router3 to Router1: Different subnet (10.0.3.0/24) - closes ring -->
    <link node1="3" node2="1">
      <iface2 id="0" name="eth0" ip4="10.0.3.2" ip4_mask="24"/>
      <options bandwidth="100000000" delay="0" loss="0.0"/>
    </link>
  </links>
</scenario>
```

# CRITICAL RULES

1. **Switches/Hubs**: Go in `<networks>` section with type="SWITCH" or "HUB"
2. **Routers/Hosts**: Go in `<devices>` section with type="router" or "host"
3. **Router-to-Router links**: Only iface2 gets IP, each link uses different subnet
4. **Router-to-Switch links**: NO IP addresses (just <options>)
5. **Switch-to-Host links**: Only iface2 (host) gets IP, ALL hosts on SAME subnet
6. **All hosts behind ONE switch**: MUST use same subnet (e.g., all 10.0.10.x)

# YOUR TASK

Parse the user's request and create a JSON plan. I will generate the XML.

JSON Format:
```json
{
  "description": "Brief description",
  "node_count_required": {"routers": 3, "switches": 3, "hosts": 15},
  "nodes": [
    {"id": 1, "name": "router1", "type": "router", "x": 300.0, "y": 200.0,
     "services": ["zebra", "OSPFv2", "OSPFv3", "IPForward"]},
    {"id": 2, "name": "switch1", "type": "switch", "x": 300.0, "y": 350.0, "services": []},
    {"id": 3, "name": "host1", "type": "host", "x": 250.0, "y": 450.0,
     "services": ["DefaultRoute"]}
  ],
  "links": [
    {"node1_id": 1, "node2_id": 2, "type": "router-switch"},
    {"node1_id": 2, "node2_id": 3, "type": "switch-host", "subnet": "10.0.10", "host_ip": 2}
  ]
}
```

Link types:
- "router-router": iface2 gets IP, different subnet per link
- "router-switch": no IPs
- "switch-host": iface2 gets IP, same subnet for all hosts on this switch

IMPORTANT: Create ALL requested nodes! If user asks for "5 hosts per switch", generate ALL 5 hosts explicitly.

Return ONLY valid JSON, NO explanations."""

class LLMTopologyGeneratorV3:
    def __init__(self, api_key: str):
        self.api_key = api_key
        openai.api_key = api_key

    def generate_topology(self, user_request: str) -> Tuple[bool, str, Optional[TopologyGenerator]]:
        """Generate topology from user request."""
        print(f"\n{'='*70}")
        print(f"🤖 LLM Topology Generator V3 (Example-Driven)")
        print(f"{'='*70}")
        print(f"\n📝 User Request: {user_request}\n")

        for attempt in range(1, 4):
            print(f"🔄 Attempt {attempt}/3")

            try:
                # Get plan from LLM
                plan = self._call_llm(user_request)
                if not plan:
                    continue

                # Validate plan completeness
                if not self._validate_plan(plan, user_request):
                    user_request += "\n\nERROR: You didn't create ALL the nodes! Create EVERY SINGLE node requested."
                    continue

                # Build topology
                generator = self._build_from_plan(plan)

                # Final validation
                is_valid, errors = self._validate_final(generator)
                if not is_valid:
                    print(f"❌ Errors: {', '.join(errors)}")
                    user_request += f"\n\nERRORS: {'. '.join(errors)}"
                    continue

                print(f"✅ Success!")
                return True, plan.get('description', 'Generated'), generator

            except Exception as e:
                print(f"❌ Error: {e}")

        return False, "Failed after 3 attempts", None

    def _call_llm(self, request: str) -> Optional[Dict]:
        """Call LLM with examples."""
        print(f"   📡 Calling OpenAI...")

        try:
            response = openai.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT_WITH_EXAMPLES},
                    {"role": "user", "content": request}
                ],
                temperature=0.5,
                max_tokens=4000
            )

            content = response.choices[0].message.content.strip()

            # Extract JSON
            if "```json" in content:
                content = content.split("```json")[1].split("```")[0].strip()
            elif "```" in content:
                content = content.split("```")[1].split("```")[0].strip()

            plan = json.loads(content)
            print(f"   ✅ Got plan: {len(plan.get('nodes', []))} nodes, {len(plan.get('links', []))} links")

            return plan

        except Exception as e:
            print(f"   ❌ Failed: {e}")
            return None

    def _validate_plan(self, plan: Dict, original_request: str) -> bool:
        """Validate plan has all requested nodes."""
        print(f"   🔍 Validating completeness...")

        required = plan.get('node_count_required', {})
        actual = {'routers': 0, 'switches': 0, 'hosts': 0}

        for node in plan.get('nodes', []):
            node_type = node.get('type', '')
            if node_type == 'router':
                actual['routers'] += 1
            elif node_type == 'switch':
                actual['switches'] += 1
            elif node_type == 'host':
                actual['hosts'] += 1

        for key in required:
            if actual.get(key, 0) < required[key]:
                print(f"   ❌ Missing {key}: need {required[key]}, got {actual.get(key, 0)}")
                return False

        print(f"   ✅ All nodes present")
        return True

    def _build_from_plan(self, plan: Dict) -> TopologyGenerator:
        """Build topology from validated plan."""
        print(f"   🏗️  Building topology...")

        gen = TopologyGenerator()
        gen.session_name = plan.get('description', 'Generated')

        # Track subnets for proper IP assignment
        router_link_subnet = 1  # For router-to-router links
        lan_subnet = 10  # For LAN segments

        # Add all nodes
        for node_spec in plan.get('nodes', []):
            gen.add_node(NodeConfig(
                node_id=node_spec['id'],
                name=node_spec['name'],
                node_type=node_spec['type'],
                x=node_spec.get('x', 100.0),
                y=node_spec.get('y', 100.0),
                services=node_spec.get('services', [])
            ))

        # Add all links with proper IP addressing
        for link_spec in plan.get('links', []):
            link_type = link_spec.get('type', 'router-router')
            node1_id = link_spec['node1_id']
            node2_id = link_spec['node2_id']

            if link_type == 'router-router':
                # Different subnet per link
                gen.add_link(LinkConfig(
                    node1_id=node1_id,
                    node2_id=node2_id,
                    ip4_2=f"10.0.{router_link_subnet}.2"
                ))
                router_link_subnet += 1

            elif link_type == 'router-switch':
                # No IPs
                gen.add_link(LinkConfig(
                    node1_id=node1_id,
                    node2_id=node2_id
                ))

            elif link_type == 'switch-host':
                # Host gets IP on subnet specified
                subnet = link_spec.get('subnet', f"10.0.{lan_subnet}")
                host_ip = link_spec.get('host_ip', 2)
                gen.add_link(LinkConfig(
                    node1_id=node1_id,
                    node2_id=node2_id,
                    ip4_2=f"{subnet}.{host_ip}"
                ))

        print(f"   ✅ Built {len(gen.nodes)} nodes, {len(gen.links)} links")
        return gen

    def _validate_final(self, gen: TopologyGenerator) -> Tuple[bool, List[str]]:
        """Final validation."""
        errors = []

        # Check nodes exist
        for link in gen.links:
            if link.node1_id not in gen.nodes:
                errors.append(f"Missing node {link.node1_id}")
            if link.node2_id not in gen.nodes:
                errors.append(f"Missing node {link.node2_id}")

        # Check subnet consistency
        for switch_id, switch in gen.nodes.items():
            if switch.node_type == 'switch':
                ips = []
                for link in gen.links:
                    if link.node1_id == switch_id and link.ip4_2:
                        ips.append(link.ip4_2)

                if ips:
                    subnets = set(['.'.join(ip.split('.')[:3]) for ip in ips])
                    if len(subnets) > 1:
                        errors.append(f"Switch {switch.name} has mixed subnets: {subnets}")

        return (len(errors) == 0, errors)

    def deploy_to_core(self, gen: TopologyGenerator, filename: str = "llm_topo_v3.xml") -> Tuple[bool, str]:
        """Deploy to CORE."""
        print(f"\n{'='*70}")
        print(f"🚀 Deploying to CORE")
        print(f"{'='*70}\n")

        try:
            local_path = f"/tmp/{filename}"
            with open(local_path, 'w') as f:
                f.write(gen.to_xml())

            # Copy to container
            subprocess.run(f"docker cp {local_path} core-novnc:/root/topologies/{filename}",
                         shell=True, check=True)

            # Copy load script
            subprocess.run("docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
                         shell=True, capture_output=True)

            # Load in CORE using Python API
            load_cmd = f"""docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 /tmp/load_topology.py /root/topologies/{filename}
            '"""
            result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                print(f"⚠️  Warning: {result.stderr}")

            print(f"✅ Deployed: /root/topologies/{filename}")
            return True, "Success"

        except Exception as e:
            return False, str(e)

def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('request', nargs='?', help='Topology description')
    parser.add_argument('--no-deploy', action='store_true')
    args = parser.parse_args()

    request = args.request or input("Topology description: ").strip()
    if not request:
        sys.exit(1)

    gen = LLMTopologyGeneratorV3(OPENAI_API_KEY)
    success, msg, topo = gen.generate_topology(request)

    if not success:
        print(f"\n❌ {msg}")
        sys.exit(1)

    print(f"\n✅ {msg}")
    print(f"\n{topo.get_summary()}")

    if not args.no_deploy:
        success, deploy_msg = gen.deploy_to_core(topo)
        print(f"\n{deploy_msg}")

if __name__ == '__main__':
    main()
