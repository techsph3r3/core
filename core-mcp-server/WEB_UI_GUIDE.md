# CORE Topology Generator - Web UI Guide

## Overview

The Web UI provides a browser-based interface for generating CORE network topologies using natural language. It runs **alongside noVNC** in a separate browser tab.

## Architecture

```
┌─────────────────────┐         ┌─────────────────────┐
│  Browser Tab 1      │         │  Browser Tab 2      │
│  ───────────────    │         │  ───────────────    │
│  noVNC Desktop      │         │  Topology Generator │
│  (Port 6080)        │         │  (Port 8080)        │
│                     │         │                     │
│  ┌───────────────┐  │         │  ┌───────────────┐  │
│  │ CORE GUI      │  │         │  │ Natural Lang  │  │
│  │ Wireshark     │  │         │  │ Input         │  │
│  │ Terminal      │  │         │  │ Examples      │  │
│  └───────────────┘  │         │  │ Download      │  │
└─────────────────────┘         │  └───────────────┘  │
                                └─────────────────────┘
```

## Quick Start

### 1. Install Dependencies

```bash
cd /workspaces/core/core-mcp-server
pip install -r requirements_webui.txt
```

### 2. Start the Web UI

```bash
python3 web_ui.py
```

The server will start on `http://0.0.0.0:8080`

### 3. Access in Browser

- **Local:** http://localhost:8080
- **GitHub Codespaces:** Use the forwarded port URL
- **Remote:** http://your-server-ip:8080

### 4. Use Alongside noVNC

1. **Tab 1:** Open noVNC (CORE desktop)
   - URL: http://localhost:6080
   - Use CORE GUI to load generated topologies

2. **Tab 2:** Open Topology Generator
   - URL: http://localhost:8080
   - Generate topologies using natural language

3. **Workflow:**
   - Generate topology in Tab 2
   - Download XML file
   - Load in CORE GUI in Tab 1

---

## Features

### 1. Natural Language Input

Simply type what you want:

```
"Create a ring with 6 routers"
"Build a star with a switch and 8 hosts"
"Make a wireless mesh with 5 MDR nodes"
```

### 2. Example Buttons

Click any example to auto-fill the input:
- Basic topologies (star, ring, line)
- Wireless networks
- Advanced configurations

### 3. Real-time Generation

- Click "Generate Topology" or press `Ctrl+Enter`
- See summary and statistics immediately
- Network engineering rules enforced automatically

### 4. Download Options

- **XML Format:** For loading in CORE GUI
- **Python Script:** For programmatic execution
- Both formats generated instantly

### 5. Network Engineering Rules

The UI enforces proper networking:
- ✓ Layer 2 devices → same subnet
- ✓ Layer 3 devices → different subnets per link
- ✓ Wireless networks → same subnet
- ✓ Router links → separate subnets

---

## Usage Examples

### Example 1: Enterprise Network

**Input:**
```
Create a star with a switch and 10 hosts
```

**Result:**
- 1 switch (Layer 2)
- 10 hosts with DefaultRoute service
- All hosts on 10.0.1.0/24 subnet (✓ Correct!)

**Download XML → Load in CORE GUI → Run simulation**

### Example 2: Router Network

**Input:**
```
Build a ring with 8 routers running OSPF
```

**Result:**
- 8 routers with OSPF services
- Each link on separate subnet (✓ Correct!)
- Links: 10.0.1.0/24, 10.0.2.0/24, etc.

### Example 3: Wireless Network

**Input:**
```
Create a wireless mesh with 6 MDR nodes
```

**Result:**
- 1 WLAN node (500m range)
- 6 MDR nodes with OSPFv3MDR
- All on 10.0.0.0/24 subnet (✓ Correct!)

### Example 4: Docker Network

**Input:**
```
Make a tailscale mesh with 4 docker containers
```

**Result:**
- 4 Docker nodes (ubuntu:22.04)
- Ready for Tailscale configuration
- Grid layout

---

## Integration with noVNC

### Method 1: Manual Copy

1. Generate topology in Web UI (Tab 2)
2. Download XML file
3. In noVNC (Tab 1):
   ```bash
   # Upload via file manager or
   # Copy from host to container
   ```
4. Open in CORE GUI: File → Open → topology.xml

### Method 2: Direct Copy (If on same host)

```bash
# After generating topology in web UI
docker cp topology.xml core-novnc:/root/topologies/
```

Then in CORE GUI: File → Open → /root/topologies/topology.xml

### Method 3: Shared Volume (Recommended for Production)

Edit `docker-compose.yml`:

```yaml
services:
  core-novnc:
    volumes:
      - ./topologies:/root/topologies:rw
```

Generated files automatically appear in CORE container.

---

## Advanced Features

### API Endpoints

The Web UI exposes a REST API for programmatic access:

#### Generate Topology
```bash
curl -X POST http://localhost:8080/api/generate \
  -H "Content-Type: application/json" \
  -d '{"description": "Create a star with 5 hosts"}'
```

#### Download XML
```bash
curl http://localhost:8080/api/download/xml -o topology.xml
```

#### Download Python
```bash
curl http://localhost:8080/api/download/python -o topology.py
```

#### Get Examples
```bash
curl http://localhost:8080/api/examples
```

#### Health Check
```bash
curl http://localhost:8080/health
```

---

## Running in Production

### With systemd (Linux)

Create `/etc/systemd/system/core-topology-webui.service`:

```ini
[Unit]
Description=CORE Topology Generator Web UI
After=network.target

[Service]
Type=simple
User=core
WorkingDirectory=/opt/core-mcp-server
Environment="PYTHONPATH=/opt/core-mcp-server"
ExecStart=/usr/bin/python3 /opt/core-mcp-server/web_ui.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable core-topology-webui
sudo systemctl start core-topology-webui
```

### With Docker

Create `Dockerfile.webui`:

```dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements_webui.txt .
RUN pip install -r requirements_webui.txt

COPY . .

EXPOSE 8080

CMD ["python3", "web_ui.py"]
```

Build and run:
```bash
docker build -f Dockerfile.webui -t core-topology-webui .
docker run -d -p 8080:8080 core-topology-webui
```

### With docker-compose

Add to existing `docker-compose.yml`:

```yaml
services:
  topology-webui:
    build:
      context: ./core-mcp-server
      dockerfile: Dockerfile.webui
    ports:
      - "8080:8080"
    volumes:
      - ./topologies:/app/topologies:rw
    restart: unless-stopped
```

---

## Student Lab Workflow

### Scenario: Network Design Lab

1. **Lab Instructions (Tab 3 - Documentation)**
   - Student reads lab requirements
   - "Design a corporate network with 3 departments"

2. **Topology Generator (Tab 2 - Web UI)**
   - Student describes network in natural language
   - Generates multiple design iterations
   - Downloads final topology

3. **CORE Simulator (Tab 1 - noVNC)**
   - Loads topology in CORE GUI
   - Starts simulation
   - Tests connectivity
   - Captures packets with Wireshark

4. **Individual Host Console (Tab 4+)**
   - Direct terminal access to specific nodes
   - Run ping, traceroute, tcpdump
   - Configure services

---

## Troubleshooting

### Web UI Won't Start

**Issue:** Port 8080 already in use

**Solution:**
```bash
# Find process using port 8080
lsof -i :8080

# Kill it or change port in web_ui.py:
app.run(host='0.0.0.0', port=8081)
```

### Can't Access from Browser

**Issue:** Firewall blocking port

**Solution:**
```bash
# On Linux
sudo ufw allow 8080

# Or use SSH tunnel
ssh -L 8080:localhost:8080 user@server
```

### CORS Errors

**Issue:** Web UI accessed from different origin

**Solution:**
- Already handled by Flask-CORS
- If still issues, check browser console
- Ensure `CORS(app)` is in web_ui.py

### Generation Fails

**Issue:** Module import errors

**Solution:**
```bash
cd /workspaces/core/core-mcp-server
export PYTHONPATH=$PWD
python3 web_ui.py
```

---

## Customization

### Change Colors/Theme

Edit `templates/index.html` - CSS section:

```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
/* Change to your preferred colors */
```

### Add Custom Examples

Edit `web_ui.py` - `get_examples()` function:

```python
{
    'name': 'My Custom Example',
    'description': 'Create a specific topology',
    'category': 'Custom'
}
```

### Change Default Port

Edit `web_ui.py` - bottom of file:

```python
app.run(host='0.0.0.0', port=8080)  # Change 8080 to desired port
```

---

## Comparison: MCP vs Web UI

| Feature | MCP with LLM | Web UI |
|---------|--------------|--------|
| **Interface** | Conversational | Form-based |
| **Complexity** | Handles complex requests | Simple descriptions |
| **Iteration** | Natural dialogue | Manual refinement |
| **Setup** | Requires Claude Desktop | Just browser |
| **Best For** | Advanced users, complex topologies | Students, quick generation |
| **Learning Curve** | Low (natural language) | Very low (examples provided) |

**Recommendation:** Use both!
- Web UI for quick, simple topologies
- MCP for complex, iterative design

---

## Future Enhancements

### Planned Features

- [ ] Visual topology preview (canvas rendering)
- [ ] Drag-and-drop node placement
- [ ] Real-time collaboration
- [ ] Save/load topology templates
- [ ] Export to multiple formats (GNS3, Netkit)
- [ ] Integration with CORE API for live deployment
- [ ] User authentication and saved designs

---

## Security Considerations

### Production Deployment

1. **Enable Authentication:**
   ```python
   from flask_httpauth import HTTPBasicAuth
   auth = HTTPBasicAuth()
   ```

2. **Use HTTPS:**
   ```python
   app.run(ssl_context='adhoc')  # Or proper certificates
   ```

3. **Rate Limiting:**
   ```python
   from flask_limiter import Limiter
   limiter = Limiter(app)
   ```

4. **Input Validation:**
   - Already implemented via Pydantic models
   - Additional checks in web_ui.py

---

## Support & Feedback

- **Documentation:** See README.md, NATURAL_LANGUAGE_GUIDE.md
- **Issues:** GitHub issues tracker
- **Examples:** See `examples/` directory

---

**Last Updated:** 2025-11-24
**Version:** 1.0.0
**Status:** ✅ Production Ready
