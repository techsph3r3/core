# Importing This Project into makau_dt

## Overview

This guide provides step-by-step instructions for importing the CORE MCP Server and Caldera integration into your `makau_dt` repository.

---

## Step 1: Initialize makau_dt Repository

```bash
# Create or navigate to your makau_dt repo
mkdir -p makau_dt && cd makau_dt
git init  # if new repo

# Create directory structure
mkdir -p extensions docs
```

---

## Step 2: Add Upstream Repositories as Submodules

This keeps CORE and Caldera updatable from their official sources:

```bash
# Add CORE as submodule (official upstream)
git submodule add https://github.com/coreemu/core.git core

# Add Caldera as submodule (official MITRE repo)
git submodule add https://github.com/mitre/caldera.git caldera

# Initialize submodules
git submodule update --init --recursive
```

---

## Step 3: Copy Custom Extensions

From this repository, copy the following to `makau_dt/extensions/`:

```bash
# Assuming you're in makau_dt/ and this repo is at ../core/

# Copy MCP server
cp -r ../core/core-mcp-server extensions/

# Copy custom Dockerfiles
cp -r ../core/dockerfiles extensions/

# Copy documentation
cp ../core/PROJECT_SUMMARY.md docs/
cp ../core/CORE_MCP_SOLUTION.md docs/
```

### Alternative: Use rsync for selective copy

```bash
rsync -av --exclude='__pycache__' --exclude='*.egg-info' \
    ../core/core-mcp-server extensions/

rsync -av ../core/dockerfiles extensions/
```

---

## Step 4: Update Dockerfile Paths

The Dockerfiles reference paths like `dockerfiles/novnc/`. Update these for your new structure:

**In `extensions/dockerfiles/Dockerfile.novnc`:**

Change:
```dockerfile
COPY dockerfiles/novnc/xstartup /root/.vnc/xstartup
COPY dockerfiles/novnc/start-vnc.sh /opt/start-vnc.sh
COPY dockerfiles/novnc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
```

To:
```dockerfile
COPY extensions/dockerfiles/novnc/xstartup /root/.vnc/xstartup
COPY extensions/dockerfiles/novnc/start-vnc.sh /opt/start-vnc.sh
COPY extensions/dockerfiles/novnc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
```

Or build from within the extensions directory.

---

## Step 5: Create docker-compose.yml

Create `makau_dt/docker-compose.yml`:

```yaml
version: '3.8'

services:
  core-novnc:
    build:
      context: .
      dockerfile: extensions/dockerfiles/Dockerfile.novnc
    container_name: core-novnc
    privileged: true
    ports:
      - "6080:6080"   # noVNC web access
      - "5901:5901"   # VNC direct access
      - "5000:5000"   # Web UI (topology generator)
      - "8888:8888"   # Caldera (if running)
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock  # Docker-in-Docker
      - ./extensions/core-mcp-server:/opt/core-mcp-server
    environment:
      - DISPLAY=:1
      - VNC_RESOLUTION=1920x1080
      - OPENAI_API_KEY=${OPENAI_API_KEY:-}  # Optional: for AI features
    networks:
      - core-network

networks:
  core-network:
    driver: bridge
```

---

## Step 6: Create Main README

Create `makau_dt/README.md`:

```markdown
# makau_dt - Digital Twin Platform

## Quick Start

```bash
# Clone with submodules
git clone --recursive https://github.com/YOUR_USER/makau_dt.git
cd makau_dt

# Build and run
docker-compose up -d

# Access
# - noVNC Desktop: http://localhost:6080 (password: core123)
# - Topology Web UI: http://localhost:5000
# - Caldera: http://localhost:8888 (red/admin)
```

## Updating Dependencies

```bash
# Update CORE to latest
git submodule update --remote core

# Update Caldera to latest
git submodule update --remote caldera
```

## Project Structure

```
makau_dt/
├── core/                    # Git submodule: coreemu/core
├── caldera/                 # Git submodule: mitre/caldera
├── extensions/
│   ├── core-mcp-server/     # Natural language topology generator
│   └── dockerfiles/         # Custom Docker images
├── docs/                    # Documentation
└── docker-compose.yml       # Orchestration
```
```

---

## Step 7: Final Directory Structure

Your `makau_dt` should look like:

```
makau_dt/
├── .git/
├── .gitmodules              # Submodule references
├── README.md
├── docker-compose.yml
│
├── core/                    # Submodule → github.com/coreemu/core
│   ├── daemon/
│   ├── docs/
│   └── ...
│
├── caldera/                 # Submodule → github.com/mitre/caldera
│   ├── app/
│   ├── plugins/
│   └── ...
│
├── extensions/
│   ├── core-mcp-server/
│   │   ├── core_mcp/
│   │   │   ├── __init__.py
│   │   │   ├── server.py
│   │   │   └── topology_generator.py
│   │   ├── web_ui.py
│   │   ├── caldera_session_watcher.py
│   │   ├── templates/
│   │   ├── scripts/
│   │   └── *.md
│   │
│   └── dockerfiles/
│       ├── Dockerfile.novnc
│       ├── Dockerfile.caldera-core
│       ├── Dockerfile.core-node
│       ├── docker-compose.novnc.yml
│       └── novnc/
│           ├── xstartup
│           ├── start-vnc.sh
│           ├── supervisord.conf
│           ├── themes/
│           └── *.md
│
└── docs/
    ├── PROJECT_SUMMARY.md
    └── CORE_MCP_SOLUTION.md
```

---

## Step 8: Commit and Push

```bash
cd makau_dt

# Stage everything
git add .

# Commit
git commit -m "Initial setup with CORE, Caldera, and MCP extensions

- Add CORE as submodule for network emulation
- Add Caldera as submodule for adversary emulation
- Add custom MCP server for natural language topology generation
- Add noVNC Docker infrastructure for remote access
- Add Caldera auto-deployment system"

# Push
git push origin main
```

---

## Updating Workflow

### Pull upstream CORE updates:
```bash
cd makau_dt
git submodule update --remote core
git add core
git commit -m "Update CORE to latest upstream"
```

### Pull upstream Caldera updates:
```bash
cd makau_dt
git submodule update --remote caldera
git add caldera
git commit -m "Update Caldera to latest upstream"
```

### Modify your extensions:
Just edit files in `extensions/` - they're fully yours.

---

## Verification Checklist

After setup, verify:

- [ ] `git submodule status` shows both core and caldera
- [ ] `docker-compose build` succeeds
- [ ] `docker-compose up -d` starts the container
- [ ] http://localhost:6080 shows noVNC login
- [ ] CORE GUI launches inside noVNC
- [ ] Web UI accessible at http://localhost:5000 (if started)

---

## Troubleshooting

### Submodule not initialized
```bash
git submodule update --init --recursive
```

### Docker build fails on COPY
Ensure paths in Dockerfile match your directory structure. Build context matters.

### Permission denied on scripts
```bash
chmod +x extensions/dockerfiles/novnc/*.sh
chmod +x extensions/core-mcp-server/*.sh
```

### CORE daemon not starting
Check logs:
```bash
docker-compose logs core-novnc
docker exec core-novnc cat /var/log/core-daemon.log
```

---

## Next Steps

1. **Customize** the topology generator for your specific use cases
2. **Add** your own Docker images to the registry in `topology_generator.py`
3. **Extend** Caldera with custom plugins
4. **Integrate** with your CI/CD pipeline
5. **Document** your specific workflows in `docs/`
