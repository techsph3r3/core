#!/usr/bin/env python3
"""
LLM-Powered Topology Generator with Validation Loop

Uses OpenAI API to understand complex topology requests, validates the result,
and automatically deploys to CORE container.
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

SYSTEM_PROMPT = """You are a network topology design expert. Your job is to convert natural language descriptions into detailed network topology specifications that follow proper network engineering rules.

CRITICAL NETWORK ENGINEERING RULES:
1. Layer 2 Devices (Switch/Hub): All connected devices MUST be on the SAME subnet
2. Layer 3 Devices (Router): Each router interface is on a DIFFERENT subnet
3. Router-to-Router links: Each link uses a separate /24 subnet
4. Router-to-Switch-to-Hosts: Router interface and all hosts use SAME subnet
5. Wireless Networks: All nodes on WLAN use SAME subnet

SUBNET ALLOCATION STRATEGY:
- Router-to-Router links: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24, etc.
- Router-to-LAN segments: 10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24, etc.
- Wireless networks: 10.0.0.0/24

You must respond with a JSON object with this EXACT structure:

{
  "description": "brief description of what was created",
  "nodes": [
    {
      "id": 1,
      "name": "router1",
      "type": "router|switch|hub|host|mdr|wireless|docker",
      "x": 100.0,
      "y": 100.0,
      "services": ["zebra", "OSPFv2", "IPForward"]
    }
  ],
  "links": [
    {
      "node1_id": 1,
      "node2_id": 2,
      "ip4_1": "10.0.1.1",
      "ip4_2": "10.0.1.2",
      "bandwidth": 100000000,
      "delay": 0
    }
  ]
}

IMPORTANT:
- For Layer 2 devices (switches), omit ip4_1 and only set ip4_2 for the connected device
- For router-to-switch links, the router gets an IP and the switch doesn't
- All hosts behind a switch must be on the same subnet as the router interface
- Use proper services: routers need ["zebra", "OSPFv2", "OSPFv3", "IPForward"], hosts need ["DefaultRoute"]
- Position nodes logically (use geometry for rings, stars, etc.)

Return ONLY the JSON, no other text."""


class LLMTopologyGenerator:
    def __init__(self, api_key: str):
        self.api_key = api_key
        openai.api_key = api_key
        self.max_retries = 3

    def generate_topology(self, user_request: str) -> Tuple[bool, str, Optional[TopologyGenerator]]:
        """
        Generate topology from natural language using LLM with validation loop.

        Returns: (success, message, generator)
        """
        print(f"\n{'='*70}")
        print(f"🤖 LLM Topology Generator")
        print(f"{'='*70}")
        print(f"\n📝 User Request: {user_request}\n")

        for attempt in range(1, self.max_retries + 1):
            print(f"🔄 Attempt {attempt}/{self.max_retries}")

            try:
                # Call LLM
                spec = self._call_llm(user_request, attempt)

                if not spec:
                    return False, "Failed to get valid JSON from LLM", None

                # Build topology
                generator = self._build_topology(spec)

                # Validate
                is_valid, errors = self._validate_topology(generator)

                if is_valid:
                    print(f"✅ Topology validated successfully!")
                    return True, spec.get('description', 'Topology created'), generator
                else:
                    print(f"❌ Validation failed: {', '.join(errors)}")
                    if attempt < self.max_retries:
                        print(f"   Sending feedback to LLM for correction...")
                        user_request += f"\n\nPREVIOUS ATTEMPT HAD ERRORS: {'. '.join(errors)}. Please fix these issues."
                    else:
                        return False, f"Validation failed after {self.max_retries} attempts: {', '.join(errors)}", None

            except Exception as e:
                print(f"❌ Error on attempt {attempt}: {str(e)}")
                if attempt == self.max_retries:
                    return False, f"Failed after {self.max_retries} attempts: {str(e)}", None

        return False, "Failed to generate valid topology", None

    def _call_llm(self, user_request: str, attempt: int) -> Optional[Dict]:
        """Call OpenAI API to get topology specification."""
        print(f"   📡 Calling OpenAI API...")

        try:
            response = openai.chat.completions.create(
                model="gpt-4",  # or "gpt-3.5-turbo" for faster/cheaper
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_request}
                ],
                temperature=0.7,
                max_tokens=2000
            )

            content = response.choices[0].message.content.strip()
            print(f"   ✅ Received response from LLM")

            # Try to extract JSON from response
            if content.startswith("```json"):
                content = content.split("```json")[1].split("```")[0].strip()
            elif content.startswith("```"):
                content = content.split("```")[1].split("```")[0].strip()

            spec = json.loads(content)
            print(f"   ✅ Parsed JSON specification")
            print(f"      Nodes: {len(spec.get('nodes', []))}, Links: {len(spec.get('links', []))}")

            return spec

        except json.JSONDecodeError as e:
            print(f"   ❌ Failed to parse JSON: {e}")
            print(f"   Response was: {content[:200]}...")
            return None
        except Exception as e:
            print(f"   ❌ API call failed: {e}")
            return None

    def _build_topology(self, spec: Dict) -> TopologyGenerator:
        """Build topology from LLM specification."""
        print(f"   🏗️  Building topology...")

        gen = TopologyGenerator()
        gen.session_name = spec.get('description', 'LLM Generated Topology')

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
                ip4_1=link_spec.get('ip4_1'),
                ip4_2=link_spec.get('ip4_2'),
                bandwidth=link_spec.get('bandwidth', 100000000),
                delay=link_spec.get('delay', 0),
                loss=link_spec.get('loss', 0.0)
            )
            gen.add_link(link)

        print(f"   ✅ Built topology: {len(gen.nodes)} nodes, {len(gen.links)} links")
        return gen

    def _validate_topology(self, gen: TopologyGenerator) -> Tuple[bool, List[str]]:
        """Validate topology follows network engineering rules."""
        print(f"   🔍 Validating topology...")
        errors = []

        # Check 1: All nodes referenced in links must exist
        for link in gen.links:
            if link.node1_id not in gen.nodes:
                errors.append(f"Link references non-existent node {link.node1_id}")
            if link.node2_id not in gen.nodes:
                errors.append(f"Link references non-existent node {link.node2_id}")

        # Check 2: Switch/hub links - all devices must be on same subnet
        for switch_id, switch_node in gen.nodes.items():
            if switch_node.node_type in ['switch', 'hub']:
                # Find all links to this switch
                connected_ips = []
                for link in gen.links:
                    if link.node1_id == switch_id and link.ip4_2:
                        connected_ips.append(link.ip4_2)
                    elif link.node2_id == switch_id and link.ip4_1:
                        connected_ips.append(link.ip4_1)

                # Check if all IPs are on same subnet
                if connected_ips:
                    subnets = set(['.'.join(ip.split('.')[:3]) for ip in connected_ips])
                    if len(subnets) > 1:
                        errors.append(f"Switch/hub {switch_node.name} has devices on different subnets: {subnets}")

        # Check 3: Routers should have proper routing services
        for node_id, node in gen.nodes.items():
            if node.node_type == 'router':
                if 'IPForward' not in node.services:
                    errors.append(f"Router {node.name} missing IPForward service")

        # Check 4: Basic sanity checks
        if len(gen.nodes) == 0:
            errors.append("Topology has no nodes")
        if len(gen.links) == 0 and len(gen.nodes) > 1:
            errors.append("Topology has multiple nodes but no links")

        if errors:
            for error in errors:
                print(f"      ❌ {error}")
            return False, errors
        else:
            print(f"   ✅ Validation passed")
            return True, []

    def deploy_to_core(self, gen: TopologyGenerator, filename: str = "llm_topology.xml") -> Tuple[bool, str]:
        """Deploy topology to CORE container and auto-open."""
        print(f"\n{'='*70}")
        print(f"🚀 Deploying to CORE Container")
        print(f"{'='*70}\n")

        try:
            # Save XML locally
            local_path = f"/tmp/{filename}"
            with open(local_path, 'w') as f:
                f.write(gen.to_xml())
            print(f"✅ Saved XML to {local_path}")

            # Copy to container
            container_path = f"/root/topologies/{filename}"
            cmd = f"docker cp {local_path} core-novnc:{container_path}"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                return False, f"Failed to copy to container: {result.stderr}"

            print(f"✅ Copied to container: {container_path}")

            # Auto-open in CORE GUI
            print(f"🎯 Auto-opening in CORE GUI...")

            # Close any existing CORE session
            close_cmd = """docker exec core-novnc bash -c '
                pkill -f core-gui || true
            '"""
            subprocess.run(close_cmd, shell=True, capture_output=True)

            # Open new topology
            open_cmd = f"""docker exec core-novnc bash -c '
                export DISPLAY=:1
                nohup core-gui {container_path} > /tmp/core-gui.log 2>&1 &
                sleep 2
            '"""
            result = subprocess.run(open_cmd, shell=True, capture_output=True, text=True)

            if result.returncode != 0:
                print(f"⚠️  Warning: Could not auto-open GUI: {result.stderr}")
                print(f"   You can manually open: File → Open → {container_path}")
            else:
                print(f"✅ Opened in CORE GUI!")

            return True, f"Deployed successfully to {container_path}"

        except Exception as e:
            return False, f"Deployment failed: {str(e)}"


def main():
    """Main entry point for LLM topology generator."""
    import argparse

    parser = argparse.ArgumentParser(description='LLM-Powered Network Topology Generator')
    parser.add_argument('request', nargs='?', help='Natural language topology description')
    parser.add_argument('--api-key', help='OpenAI API key (or set OPENAI_API_KEY env var)')
    parser.add_argument('--no-deploy', action='store_true', help='Generate but don\'t deploy to CORE')
    parser.add_argument('--output', default='llm_topology.xml', help='Output filename')

    args = parser.parse_args()

    # Get API key
    api_key = args.api_key or os.environ.get('OPENAI_API_KEY') or OPENAI_API_KEY
    if not api_key:
        print("❌ Error: No API key provided")
        print("   Set OPENAI_API_KEY environment variable or use --api-key")
        sys.exit(1)

    # Get user request
    if args.request:
        request = args.request
    else:
        print("Enter your topology description (or 'quit' to exit):")
        request = input("> ").strip()
        if request.lower() in ['quit', 'exit', 'q']:
            sys.exit(0)

    if not request:
        print("❌ Error: No topology description provided")
        sys.exit(1)

    # Generate topology
    generator = LLMTopologyGenerator(api_key)
    success, message, topology = generator.generate_topology(request)

    if not success:
        print(f"\n❌ Failed to generate topology: {message}")
        sys.exit(1)

    print(f"\n✅ {message}")
    print(f"\n{topology.get_summary()}")

    # Deploy to CORE
    if not args.no_deploy:
        success, deploy_msg = generator.deploy_to_core(topology, args.output)
        if success:
            print(f"\n🎉 SUCCESS! {deploy_msg}")
            print(f"\n📺 Check your noVNC browser tab - CORE GUI should have opened the topology!")
        else:
            print(f"\n⚠️  {deploy_msg}")
    else:
        # Just save locally
        with open(f"/tmp/{args.output}", 'w') as f:
            f.write(topology.to_xml())
        print(f"\n💾 Saved to /tmp/{args.output}")

    print(f"\n{'='*70}\n")


if __name__ == '__main__':
    main()
