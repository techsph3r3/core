# Integrating Themes into CORE noVNC Docker Container

This guide shows how to integrate the theming system into your CORE noVNC Dockerfile.

## 🔧 Integration Steps

### 1. Add to Dockerfile

Add these lines to `dockerfiles/Dockerfile.novnc`:

```dockerfile
# ============================================================================
# INSTALL THEMING SYSTEM
# ============================================================================

# Install PyYAML for theme configuration
RUN /opt/core/venv/bin/pip install pyyaml

# Copy theme files
COPY dockerfiles/novnc/themes /opt/themes
RUN chmod +x /opt/themes/apply-theme.sh /opt/themes/apply-theme.py

# Apply default theme during build
RUN cd /opt/themes && python3 apply-theme.py theme-config.yaml

# Make themes accessible
RUN ln -s /opt/themes /root/themes
```

**Where to add**: After the noVNC installation section, before the final `ENTRYPOINT`.

### 2. Update supervisord.conf (Optional)

To apply theme on every container start (useful for development):

```ini
[program:apply-theme]
command=/bin/bash -c "cd /opt/themes && python3 apply-theme.py theme-config.yaml"
autostart=true
autorestart=false
priority=5
stdout_logfile=/var/log/supervisor/apply-theme.log
stderr_logfile=/var/log/supervisor/apply-theme-error.log
```

**Where to add**: In `dockerfiles/novnc/supervisord.conf`, before the `core-daemon` program section.

### 3. Update xstartup Script

Replace `dockerfiles/novnc/xstartup` with the generated version, or add theme application:

```bash
#!/bin/bash
# Apply theme on VNC session start
if [ -f /opt/themes/apply-theme.py ]; then
    cd /opt/themes && python3 apply-theme.py theme-config.yaml
fi

# ... rest of xstartup ...
```

## 📦 Complete Dockerfile Snippet

Add this section to `dockerfiles/Dockerfile.novnc` around line 250 (after noVNC setup):

```dockerfile
# ============================================================================
# THEMING SYSTEM - Flexible UI Customization
# ============================================================================

# Install dependencies
RUN /opt/core/venv/bin/pip install pyyaml && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        # For themes
        python3-yaml \
        # For enhanced menu
        thunar \
        # For screenshots
        xfce4-screenshooter \
    && rm -rf /var/lib/apt/lists/*

# Copy theming system
COPY dockerfiles/novnc/themes /opt/themes
RUN chmod +x /opt/themes/*.sh /opt/themes/*.py

# Create necessary directories
RUN mkdir -p \
    /root/.fluxbox/styles \
    /root/.fluxbox/backgrounds \
    /root/Desktop \
    /root/.config/tint2 \
    /root/.vnc

# Apply default theme
RUN cd /opt/themes && \
    python3 apply-theme.py theme-config.yaml && \
    echo "Theme applied successfully"

# Create symlink for easy access
RUN ln -s /opt/themes /root/themes

# Set default VNC password
RUN mkdir -p /root/.vnc && \
    echo "core123" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Copy enhanced xstartup (if using the generated one)
# COPY dockerfiles/novnc/xstartup /root/.vnc/xstartup
# RUN chmod +x /root/.vnc/xstartup
```

## 🎨 Allowing Runtime Theme Changes

To let users change themes without rebuilding:

### Option 1: Volume Mount (Development)

```bash
docker run -d \
  --name core-novnc \
  -v $(pwd)/dockerfiles/novnc/themes:/opt/themes \
  ... other options ...
  core-novnc:latest
```

Users can edit themes on host and apply inside container:
```bash
docker exec -it core-novnc bash
cd /opt/themes
./apply-theme.sh my-custom-theme.yaml
```

### Option 2: ENV Variable

Allow theme selection via environment variable:

```dockerfile
# In Dockerfile
ENV CORE_THEME=theme-config.yaml

# In xstartup or supervisord
cd /opt/themes && python3 apply-theme.py $CORE_THEME
```

Then users can specify theme:
```bash
docker run -d \
  -e CORE_THEME=preset-light.yaml \
  ... other options ...
  core-novnc:latest
```

### Option 3: Web UI (Advanced)

Create a simple web interface for theme selection:

```python
# /opt/themes/theme-selector.py
from flask import Flask, render_template, request
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    themes = ['theme-config.yaml', 'preset-light.yaml', 'preset-highcontrast.yaml', 'preset-nord.yaml']
    return render_template('theme_selector.html', themes=themes)

@app.route('/apply', methods=['POST'])
def apply_theme():
    theme = request.form['theme']
    subprocess.run(['python3', 'apply-theme.py', theme], cwd='/opt/themes')
    subprocess.run(['fluxbox-remote', 'restart'])
    return 'Theme applied!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

## 🧪 Testing Integration

### Build and Test

```bash
# Build the image
cd /workspaces/core
docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest .

# Run the container
docker run -d \
  --name core-novnc-test \
  --privileged \
  -p 6080:6080 \
  -p 5901:5901 \
  core-novnc:latest

# Wait for services to start
sleep 10

# Check theme was applied
docker exec core-novnc-test cat /root/.fluxbox/styles/CORE-Theme/theme.cfg

# Access via browser
# Open: http://localhost:6080
```

### Verify Theme Features

1. **Desktop shortcuts**: Check if icons appear on desktop
2. **Menu**: Right-click → Verify enhanced menu structure
3. **Keyboard shortcuts**: Try Mod4+C (Super+C) to launch CORE
4. **Colors**: Verify colors match your configuration
5. **Window borders**: Check focused vs unfocused windows

## 🔄 Updating Themes

### Method 1: Rebuild Container

```bash
# Edit theme files
nano dockerfiles/novnc/themes/theme-config.yaml

# Rebuild
docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest .

# Recreate container
docker stop core-novnc && docker rm core-novnc
docker run -d ... core-novnc:latest
```

### Method 2: Live Update (Development)

```bash
# Copy new theme into running container
docker cp dockerfiles/novnc/themes/my-theme.yaml core-novnc:/opt/themes/

# Apply inside container
docker exec core-novnc bash -c "cd /opt/themes && ./apply-theme.sh my-theme.yaml"

# Restart Fluxbox
docker exec core-novnc fluxbox-remote restart
```

## 📋 Validation Checklist

After integration, verify:

- [ ] Theme files copied to `/opt/themes`
- [ ] Scripts are executable (`apply-theme.sh`, `apply-theme.py`)
- [ ] PyYAML installed and working
- [ ] Default theme applied during build
- [ ] Fluxbox starts with correct theme
- [ ] Desktop shortcuts appear
- [ ] Enhanced menu works
- [ ] Keyboard shortcuts functional
- [ ] Theme can be changed at runtime (if enabled)

## 🐛 Debugging

### Theme not applied at build

Check build logs:
```bash
docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest . 2>&1 | grep -A 10 "THEMING"
```

### Theme not applied at runtime

Check inside container:
```bash
docker exec -it core-novnc bash

# Check if theme files exist
ls -la /opt/themes/

# Try applying manually
cd /opt/themes
python3 apply-theme.py theme-config.yaml

# Check for errors
cat /var/log/supervisor/apply-theme-error.log
```

### Fluxbox not reloading

```bash
# Inside container
docker exec core-novnc bash

# Kill and restart Fluxbox
killall fluxbox
# (supervisor will restart it automatically)

# Or reload configuration
fluxbox-remote reconfigure
```

## 🎯 Best Practices

1. **Apply theme during build** for faster startup
2. **Mount themes volume** during development
3. **Use environment variables** for deployment flexibility
4. **Include preset themes** so users have options
5. **Document customization** in your README
6. **Version theme configs** with Docker image versions

## 📚 Examples

### Multi-Stage Theme Application

```dockerfile
# Stage 1: Generate themes
FROM python:3.9-slim AS theme-builder
COPY dockerfiles/novnc/themes /themes
RUN pip install pyyaml && \
    cd /themes && \
    python3 apply-theme.py theme-config.yaml

# Stage 2: Main image
FROM ubuntu:22.04
# ... CORE installation ...
COPY --from=theme-builder /root/.fluxbox /root/.fluxbox
COPY --from=theme-builder /root/Desktop /root/Desktop
```

### Theme Per Environment

```bash
# Development - light theme
docker run -d -e CORE_THEME=preset-light.yaml ...

# Production - dark theme
docker run -d -e CORE_THEME=theme-config.yaml ...

# Presentation - high contrast
docker run -d -e CORE_THEME=preset-highcontrast.yaml ...
```

## 🆘 Common Issues

**Issue**: PyYAML import error
**Solution**: Ensure PyYAML installed in correct Python environment
```dockerfile
RUN /opt/core/venv/bin/pip install pyyaml
```

**Issue**: Permission denied on scripts
**Solution**: Make scripts executable
```dockerfile
RUN chmod +x /opt/themes/*.sh /opt/themes/*.py
```

**Issue**: Desktop shortcuts not clickable
**Solution**: Ensure .desktop files are executable
```bash
chmod +x ~/Desktop/*.desktop
```

**Issue**: Menu shows "exec:///opt/core..." errors
**Solution**: Verify paths exist before adding to menu
```bash
if [ -f /opt/core/venv/bin/core-gui ]; then
    echo "[exec] (CORE GUI) {/opt/core/venv/bin/core-gui}"
fi
```

## 📖 Additional Resources

- [Fluxbox Wiki](http://fluxbox-wiki.org/)
- [YAML Syntax](https://yaml.org/)
- [Color Picker](https://coolors.co/)
- [Desktop Entry Spec](https://specifications.freedesktop.org/desktop-entry-spec/latest/)

---

**Integration complete!** Your CORE noVNC container now has a flexible, customizable theming system.
