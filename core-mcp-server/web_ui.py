#!/usr/bin/env python3
"""
CORE MCP Topology Generator - Web UI
Provides a browser-based interface for generating network topologies using natural language
"""

from flask import Flask, render_template, request, jsonify, send_file
from flask_cors import CORS
import os
import sys
import tempfile
import base64
import json
from pathlib import Path
import openai

# Add the core_mcp module to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from core_mcp.topology_generator import TopologyGenerator

# OpenAI API key for vision and interpretation - set OPENAI_API_KEY environment variable
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
if not OPENAI_API_KEY:
    print("Warning: OPENAI_API_KEY environment variable not set - AI features will be disabled")
openai.api_key = OPENAI_API_KEY

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Store the current generator instance and interpretation state
current_generator = TopologyGenerator()
current_interpretation = None  # Stores the interpreted plan

@app.route('/')
def index():
    """Main page with topology generator interface"""
    return render_template('index.html')

@app.route('/api/generate', methods=['POST'])
def generate_topology():
    """Generate topology from natural language description"""
    try:
        data = request.get_json()
        description = data.get('description', '')

        if not description:
            return jsonify({'error': 'Description is required'}), 400

        # Create new generator for this topology
        global current_generator
        current_generator = TopologyGenerator()

        # Generate from description
        result = current_generator.generate_from_description(description)

        # Get summary
        summary = current_generator.get_summary()

        return jsonify({
            'success': True,
            'result': result,
            'summary': summary,
            'nodes': len(current_generator.nodes),
            'links': len(current_generator.links)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/download/xml', methods=['GET'])
def download_xml():
    """Download generated topology as XML file"""
    try:
        xml_content = current_generator.to_xml()

        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml', delete=False) as f:
            f.write(xml_content)
            temp_path = f.name

        return send_file(
            temp_path,
            as_attachment=True,
            download_name='topology.xml',
            mimetype='application/xml'
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/download/python', methods=['GET'])
def download_python():
    """Download generated topology as Python script"""
    try:
        python_content = current_generator.to_python_script()

        # Create temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
            f.write(python_content)
            temp_path = f.name

        return send_file(
            temp_path,
            as_attachment=True,
            download_name='topology.py',
            mimetype='text/x-python'
        )

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/save', methods=['POST'])
def save_topology():
    """Save topology files to specified location"""
    try:
        data = request.get_json()
        filename = data.get('filename', 'topology')
        save_path = data.get('path', '/tmp')

        # Ensure filename has no extension
        filename = filename.replace('.xml', '').replace('.py', '')

        # Create directory if it doesn't exist
        Path(save_path).mkdir(parents=True, exist_ok=True)

        # Save XML
        xml_path = os.path.join(save_path, f"{filename}.xml")
        with open(xml_path, 'w') as f:
            f.write(current_generator.to_xml())

        # Save Python script
        py_path = os.path.join(save_path, f"{filename}.py")
        with open(py_path, 'w') as f:
            f.write(current_generator.to_python_script())

        return jsonify({
            'success': True,
            'xml_path': xml_path,
            'py_path': py_path
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/examples', methods=['GET'])
def get_examples():
    """Get example topology descriptions"""
    examples = [
        {
            'name': 'Basic Ring',
            'description': 'Create a ring with 5 routers',
            'category': 'Basic'
        },
        {
            'name': 'Star Network',
            'description': 'Create a star with a switch and 8 hosts',
            'category': 'Basic'
        },
        {
            'name': 'Router Chain',
            'description': 'Build a line with 4 routers',
            'category': 'Basic'
        },
        {
            'name': 'Wireless Mesh',
            'description': 'Create a wireless mesh with 6 MDR nodes',
            'category': 'Wireless'
        },
        {
            'name': 'Large Wireless Network',
            'description': 'Build a wireless mesh with 12 MDR nodes',
            'category': 'Wireless'
        },
        {
            'name': 'Docker Tailscale Mesh',
            'description': 'Create a tailscale mesh with 5 docker nodes',
            'category': 'Advanced'
        },
        {
            'name': 'Enterprise Network',
            'description': 'Create a star with a switch and 20 hosts',
            'category': 'Advanced'
        },
        {
            'name': 'Backbone Ring',
            'description': 'Build a ring with 10 routers',
            'category': 'Advanced'
        },
        {
            'name': 'Caldera Red Team Lab',
            'description': 'Create a caldera red team topology with 3 target machines',
            'category': 'Security'
        },
        {
            'name': 'Adversary Emulation Lab',
            'description': 'Create an adversary emulation lab with caldera server and 5 victims',
            'category': 'Security'
        },
        {
            'name': 'Nginx Web Farm',
            'description': 'Create a web server farm with 4 nginx servers',
            'category': 'Docker'
        }
    ]

    return jsonify({'examples': examples})

@app.route('/api/clear', methods=['POST'])
def clear_topology():
    """Clear current topology"""
    global current_generator
    current_generator = TopologyGenerator()
    return jsonify({'success': True})


def cleanup_core_interfaces():
    """Clean up leftover network interfaces and session files in CORE container"""
    import subprocess
    try:
        # Remove leftover session socket files
        subprocess.run(
            "docker exec core-novnc rm -rf /tmp/pycore.* 2>/dev/null || true",
            shell=True, capture_output=True, timeout=10
        )
        # Delete leftover veth/beth interfaces
        subprocess.run(
            "docker exec core-novnc bash -c \"ip link show | grep -oP '(beth|veth)[^:@]+' | xargs -r -I{} ip link delete {} 2>/dev/null || true\"",
            shell=True, capture_output=True, timeout=15
        )
        return True
    except Exception:
        return False

@app.route('/api/copy-to-core', methods=['POST'])
def copy_to_core():
    """Copy generated topology to CORE container and auto-open"""
    try:
        # Clean up leftover interfaces first to prevent "File exists" errors
        # Don't let cleanup failure stop the copy operation
        try:
            cleanup_core_interfaces()
        except Exception as cleanup_error:
            print(f"Warning: Cleanup failed but continuing: {cleanup_error}")

        data = request.get_json()
        filename = data.get('filename', 'web_generated.xml')
        auto_open = data.get('auto_open', True)
        auto_start = data.get('auto_start', False)  # New option for full automation

        # Ensure filename ends with .xml
        if not filename.endswith('.xml'):
            filename += '.xml'

        # Save XML locally
        xml_content = current_generator.to_xml()
        local_path = f"/tmp/{filename}"

        with open(local_path, 'w') as f:
            f.write(xml_content)

        # Copy to container
        import subprocess
        container_path = f"/root/topologies/{filename}"

        copy_cmd = f"docker cp {local_path} core-novnc:{container_path}"
        result = subprocess.run(copy_cmd, shell=True, capture_output=True, text=True)

        if result.returncode != 0:
            return jsonify({
                'success': False,
                'error': f'Failed to copy to container: {result.stderr}'
            }), 500

        # Save startup scripts if any exist
        scripts_path = None
        has_startup_scripts = current_generator.has_startup_scripts()
        if has_startup_scripts:
            scripts_json = current_generator.get_startup_scripts_json()
            scripts_filename = filename.replace('.xml', '_startup.json')
            local_scripts_path = f"/tmp/{scripts_filename}"

            with open(local_scripts_path, 'w') as f:
                f.write(scripts_json)

            scripts_path = f"/root/topologies/{scripts_filename}"
            copy_scripts_cmd = f"docker cp {local_scripts_path} core-novnc:{scripts_path}"
            subprocess.run(copy_scripts_cmd, shell=True, capture_output=True, text=True)

            # Also copy the start_and_deploy script
            subprocess.run(
                "docker cp /workspaces/core/core-mcp-server/start_and_deploy.py core-novnc:/tmp/",
                shell=True,
                capture_output=True
            )

        # Auto-open in CORE GUI if requested
        session_id = None
        if auto_open:
            # Copy the load script to container if not exists
            subprocess.run(
                "docker cp /workspaces/core/core-mcp-server/load_topology.py core-novnc:/tmp/",
                shell=True,
                capture_output=True
            )

            # Load topology using CORE Python API
            load_cmd = f"""docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 /tmp/load_topology.py {container_path} > /tmp/load_topology.log 2>&1
            '"""
            result = subprocess.run(load_cmd, shell=True, capture_output=True, text=True)

            # Check for errors
            log_check = subprocess.run(
                "docker exec core-novnc cat /tmp/load_topology.log",
                shell=True,
                capture_output=True,
                text=True
            )

            if "Session ID:" in log_check.stdout:
                # Extract session ID
                import re
                match = re.search(r'Session ID: (\d+)', log_check.stdout)
                if match:
                    session_id = int(match.group(1))

            if "!" in log_check.stdout or result.returncode != 0:
                return jsonify({
                    'success': False,
                    'error': f'Failed to load in CORE GUI: {log_check.stdout}'
                }), 500

        # Auto-start and deploy if requested
        if auto_start and session_id and has_startup_scripts:
            deploy_cmd = f"""docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 /tmp/start_and_deploy.py {session_id} {scripts_path} > /tmp/deploy.log 2>&1 &
            '"""
            subprocess.run(deploy_cmd, shell=True, capture_output=True, text=True)

        return jsonify({
            'success': True,
            'message': f'Copied to {container_path}',
            'container_path': container_path,
            'scripts_path': scripts_path,
            'session_id': session_id,
            'auto_opened': auto_open,
            'auto_started': auto_start and session_id is not None,
            'has_startup_scripts': has_startup_scripts
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/start-and-deploy', methods=['POST'])
def start_and_deploy():
    """Start the CORE session and deploy startup scripts automatically."""
    try:
        import subprocess

        data = request.get_json()
        session_id = data.get('session_id')

        if not session_id:
            # Try to get the latest session
            get_session_cmd = """docker exec core-novnc bash -c '
                cd /opt/core &&
                ./venv/bin/python3 -c "
from core.api.grpc import client
core = client.CoreGrpcClient()
core.connect()
sessions = core.get_sessions()
if sessions:
    print(sessions[-1].id)
"
            '"""
            result = subprocess.run(get_session_cmd, shell=True, capture_output=True, text=True)
            if result.stdout.strip().isdigit():
                session_id = int(result.stdout.strip())
            else:
                return jsonify({
                    'success': False,
                    'error': 'No session found. Load a topology first.'
                }), 400

        # Check if we have startup scripts saved
        scripts_path = data.get('scripts_path')
        if not scripts_path and current_generator.has_startup_scripts():
            # Save scripts temporarily
            scripts_json = current_generator.get_startup_scripts_json()
            local_scripts_path = f"/tmp/startup_scripts_{session_id}.json"

            with open(local_scripts_path, 'w') as f:
                f.write(scripts_json)

            scripts_path = f"/tmp/startup_scripts_{session_id}.json"
            subprocess.run(
                f"docker cp {local_scripts_path} core-novnc:{scripts_path}",
                shell=True,
                capture_output=True
            )

        # Copy the deploy script
        subprocess.run(
            "docker cp /workspaces/core/core-mcp-server/start_and_deploy.py core-novnc:/tmp/",
            shell=True,
            capture_output=True
        )

        # Run the deployment
        scripts_arg = scripts_path if scripts_path else ""
        deploy_cmd = f"""docker exec core-novnc bash -c '
            cd /opt/core &&
            ./venv/bin/python3 /tmp/start_and_deploy.py {session_id} {scripts_arg}
        '"""
        result = subprocess.run(deploy_cmd, shell=True, capture_output=True, text=True, timeout=120)

        return jsonify({
            'success': True,
            'session_id': session_id,
            'output': result.stdout + result.stderr
        })

    except subprocess.TimeoutExpired:
        return jsonify({
            'success': False,
            'error': 'Deployment timed out. Check CORE GUI for status.'
        }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/interpret-text', methods=['POST'])
def interpret_text():
    """Interpret text description and return structured plan"""
    try:
        data = request.get_json()
        description = data.get('description', '')

        if not description:
            return jsonify({'error': 'Description is required'}), 400

        # Use GPT-4o (latest) to interpret the description
        response = openai.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": """You are a network engineer planning a CORE network emulation topology. Think like an engineer configuring a realistic network simulation.

CORE CAPABILITIES YOU CAN USE:
- Node types: routers (Quagga/FRR), switches, hosts, Docker containers
- Services: HTTP, SSH, FTP, DNS, DHCP servers on hosts
- Security: Firewall service (iptables), NAT service
- Firewalls: Built-in iptables OR Docker containers (pfSense, OPNsense, Palo Alto if available)
- Routing protocols: OSPF, BGP, RIP, static routes
- Network segments: VLANs, subnets, isolated networks, DMZ zones
- Docker containers: custom applications, web servers, databases, advanced firewalls
- Host placement: DMZ, internal network, management network

YOUR TASK:
Interpret the user's description and ask CONFIGURATION questions about:
- What services should run on hosts? (web server, SSH access, FTP?)
- Firewall needs? (iptables firewall, NAT, or Docker-based like pfSense?)
- What routing protocol? (OSPF for dynamic, static for simple?)
- Should hosts use Docker containers? (for specific apps or advanced firewalls?)
- Network segmentation? (DMZ, internal, management zones?)
- Security zones? (public-facing vs internal hosts?)

Return a JSON object with:
{
  "interpretation": "What I understood from your description",
  "nodes": {
    "routers": <count>,
    "switches": <count>,
    "hosts": <count>
  },
  "structure": "Topology type and design",
  "questions": ["Service questions", "Routing questions", "Placement questions"],
  "suggestions": [
    {"id": "ospf", "label": "Enable OSPF routing on routers", "description": "Dynamic routing protocol"},
    {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"},
    {"id": "ssh", "label": "Enable SSH access on all nodes", "description": "Remote management"}
  ]
}

SUGGESTIONS FORMAT:
- Each suggestion must be a JSON object with: id (unique), label (what to enable), description (brief)
- Make suggestions ACTIONABLE - things that can be toggled on/off
- Examples: "Enable OSPF routing", "Add HTTP servers", "Use Docker containers", "Create DMZ zone"

EXAMPLE GOOD QUESTIONS:
- "Should the hosts run HTTP servers for web services?"
- "Do you need firewalls? (iptables on routers or Docker-based like pfSense?)"
- "Which routing protocol: OSPF for dynamic routing or static routes?"
- "Should any hosts be Docker containers with custom services?"
- "Do you want a DMZ segment for public-facing servers?"
- "Should routers run SSH for management access?"
- "Enable NAT service for internet access?"

EXAMPLE ACTIONABLE SUGGESTIONS:
- {"id": "firewall_iptables", "label": "Enable iptables firewall on edge routers", "description": "Basic packet filtering"}
- {"id": "firewall_docker", "label": "Use pfSense Docker container as firewall", "description": "Advanced firewall features"}
- {"id": "ospf", "label": "Enable OSPF routing on routers", "description": "Dynamic routing protocol"}
- {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"}
- {"id": "dhcp", "label": "Add DHCP server on first host", "description": "Automatic IP configuration"}
- {"id": "ssh", "label": "Enable SSH access on all nodes", "description": "Remote management"}

DON'T ASK about physical hardware (ports, cables, racks)."""},
                {"role": "user", "content": description}
            ],
            temperature=0.7,
            max_tokens=1000
        )

        content = response.choices[0].message.content.strip()

        # Extract JSON from response
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        elif "```" in content:
            content = content.split("```")[1].split("```")[0].strip()

        interpretation = json.loads(content)

        # Store for later use
        global current_interpretation
        current_interpretation = interpretation

        return jsonify({
            'success': True,
            'interpretation': interpretation
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/interpret-image', methods=['POST'])
def interpret_image():
    """Interpret uploaded network diagram image"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image uploaded'}), 400

        image_file = request.files['image']

        # Read and encode image
        image_data = base64.b64encode(image_file.read()).decode('utf-8')

        # Use GPT-4o (with vision) to analyze the image
        response = openai.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": """You are a network engineer analyzing a diagram for CORE network emulation. Think about practical configuration.

CORE CAPABILITIES:
- Node types: routers (Quagga/FRR), switches, hosts, Docker containers
- Services: HTTP, SSH, FTP, DNS, DHCP servers
- Security: Firewall (iptables), NAT, Docker firewalls (pfSense, OPNsense, Palo Alto)
- Routing: OSPF, BGP, RIP, static routes
- Network zones: DMZ, internal, management

ANALYZE THE DIAGRAM:
1. Identify nodes and their roles
2. Understand connectivity
3. Ask CONFIGURATION questions:
   - What services on hosts? (HTTP servers, SSH?)
   - Which routing protocol for routers?
   - Should certain nodes be Docker containers?
   - Network segmentation needed? (DMZ zones?)
   - Where should specific services be located?

Return a JSON object with:
{
  "interpretation": "What I see in this network diagram",
  "nodes": {
    "routers": <count>,
    "switches": <count>,
    "hosts": <count>
  },
  "structure": "Topology type and design",
  "questions": ["Service configuration?", "Routing protocol?", "Host placement?"],
  "suggestions": [
    {"id": "ospf", "label": "Enable OSPF routing", "description": "Dynamic routing"},
    {"id": "http", "label": "Add HTTP servers on hosts", "description": "Web service"}
  ]
}

SUGGESTIONS FORMAT:
- Each suggestion must be JSON object: {"id": "unique_id", "label": "What to enable", "description": "Brief"}
- Make ACTIONABLE: things user can check a box to add

GOOD QUESTIONS EXAMPLES:
- "Should edge hosts run web servers (HTTP)?"
- "Do you need a firewall? (iptables or Docker-based like pfSense?)"
- "OSPF or static routing between routers?"
- "Do you need Docker containers for specific applications?"
- "Should some hosts be in a DMZ for public access?"

ACTIONABLE SUGGESTIONS EXAMPLES:
- {"id": "firewall", "label": "Enable iptables firewall on gateway", "description": "Packet filtering"}
- {"id": "ospf", "label": "Enable OSPF routing", "description": "Dynamic routing"}

DON'T ask about physical hardware."""
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{image_data}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=1000
        )

        content = response.choices[0].message.content.strip()

        # Extract JSON
        if "```json" in content:
            content = content.split("```json")[1].split("```")[0].strip()
        elif "```" in content:
            content = content.split("```")[1].split("```")[0].strip()

        interpretation = json.loads(content)

        # Store for later use
        global current_interpretation
        current_interpretation = interpretation

        return jsonify({
            'success': True,
            'interpretation': interpretation
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/generate-from-plan', methods=['POST'])
def generate_from_plan():
    """Generate topology from refined interpretation plan"""
    try:
        data = request.get_json()
        plan = data.get('plan', current_interpretation)

        if not plan:
            return jsonify({'error': 'No plan provided'}), 400

        # Build description from plan for existing generator
        nodes = plan.get('nodes', {})
        structure = plan.get('structure', '')

        # Construct description
        parts = []
        if 'ring' in structure.lower() and nodes.get('routers', 0) > 0:
            parts.append(f"ring with {nodes['routers']} routers")
        elif 'star' in structure.lower():
            if nodes.get('switches', 0) > 0:
                parts.append(f"star with a switch and {nodes.get('hosts', 0)} hosts")
            else:
                parts.append(f"star with {nodes.get('hosts', 0)} nodes")
        elif 'mesh' in structure.lower():
            parts.append(f"mesh with {nodes.get('routers', 0)} routers")

        description = "Create a " + " ".join(parts) if parts else plan.get('interpretation', '')

        # Generate using existing logic
        global current_generator
        current_generator = TopologyGenerator()
        result = current_generator.generate_from_description(description)

        # Apply selected features
        selected_features = plan.get('selected_features', [])
        caldera_config = plan.get('caldera_config', {})
        pfsense_config = plan.get('pfsense_config', {})

        apply_features_to_topology(current_generator, selected_features, caldera_config)

        # Apply security appliances (pfSense at router level)
        apply_security_appliances(current_generator, pfsense_config)

        summary = current_generator.get_summary()

        return jsonify({
            'success': True,
            'result': result,
            'summary': summary,
            'nodes': len(current_generator.nodes),
            'links': len(current_generator.links)
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


def apply_features_to_topology(generator, features, caldera_config=None):
    """Apply selected features to the generated topology"""
    for feature in features:
        feature_id = feature.get('id', '') if isinstance(feature, dict) else feature

        if feature_id == 'http':
            # Add HTTP service to all host nodes
            for node_id, node in generator.nodes.items():
                if node.node_type in ['host', 'pc']:
                    if 'HTTP' not in node.services:
                        node.services.append('HTTP')

        elif feature_id == 'dhcp':
            # Add DHCP service to first host
            for node_id, node in generator.nodes.items():
                if node.node_type in ['host', 'pc']:
                    if 'DHCP' not in node.services:
                        node.services.append('DHCP')
                    break  # Only first host

        elif feature_id == 'ssh':
            # Add SSH service to all nodes
            for node_id, node in generator.nodes.items():
                if 'SSH' not in node.services:
                    node.services.append('SSH')

        elif feature_id == 'ospf':
            # Add OSPFv2 service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'OSPFv2' not in node.services:
                        node.services.append('OSPFv2')

        elif feature_id == 'firewall_iptables':
            # Add Firewall service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'Firewall' not in node.services:
                        node.services.append('Firewall')

        elif feature_id == 'nat':
            # Add NAT service to routers
            for node_id, node in generator.nodes.items():
                if node.node_type == 'router':
                    if 'NAT' not in node.services:
                        node.services.append('NAT')

    # Handle Caldera Docker container (Adversary Simulation on Hosts)
    if caldera_config and caldera_config.get('enabled'):
        host_index = caldera_config.get('host_index', 0)

        # Find the specified host and convert it to Docker container
        host_count = 0
        for node_id, node in generator.nodes.items():
            if node.node_type in ['host', 'pc']:
                if host_count == host_index:
                    # Convert to Docker container with Caldera
                    # Use unique name with node ID to prevent Docker name conflicts
                    # Use caldera-mcp-core:latest - Latest Caldera with MCP plugin, CORE-compatible
                    node.node_type = 'docker'
                    node.name = f'caldera-n{node_id}'  # Unique name per node
                    node.image = 'caldera-mcp-core:latest'
                    node.services = ['DefaultRoute']
                    break
                host_count += 1

def apply_security_appliances(generator, pfsense_config=None):
    """
    Apply security appliances with proper topology architecture.

    Security Architecture Rules:
    - Firewalls (pfSense) should be at ROUTER positions (network boundaries)
    - Not at host positions - that defeats the purpose of perimeter security
    - pfSense acts as both router and firewall at the edge
    """

    # Handle pfSense Firewall (Router-level placement for proper security architecture)
    if pfsense_config and pfsense_config.get('enabled'):
        router_index = pfsense_config.get('router_index', 0)

        # Find the specified router and convert it to pfSense Docker container
        router_count = 0
        for node_id, node in generator.nodes.items():
            if node.node_type == 'router':
                if router_count == router_index:
                    # Convert router to pfSense firewall appliance
                    # This maintains the routing position while adding firewall capabilities
                    # Use unique name with node ID to prevent Docker name conflicts
                    node.node_type = 'docker'
                    node.name = f'pfsense-fw-n{node_id}'  # Unique name per node
                    node.image = 'pfsense/pfsense:latest'
                    node.services = ['DefaultRoute', 'IPForward']
                    break
                router_count += 1

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'service': 'CORE MCP Topology Generator'})

if __name__ == '__main__':
    # Run on all interfaces so it's accessible from outside
    app.run(host='0.0.0.0', port=8080, debug=False)
