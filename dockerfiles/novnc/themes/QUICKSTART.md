# CORE Theming System - Quick Start Guide

## ✨ What You Have Now

A complete, flexible theming system that allows you to customize:
- **Colors** - Every color in the UI
- **Fonts** - Size, family, weight
- **Layout** - Window borders, spacing, sizes
- **Shortcuts** - Desktop icons and keyboard shortcuts
- **Branding** - Application name, welcome screen

## 🎯 5-Minute Start

### 1. Test the Theme System (Right Now)

```bash
cd /workspaces/core/dockerfiles/novnc/themes

# Apply the default dark theme
./apply-theme.sh

# Or try a different preset
./apply-theme.sh preset-light.yaml
./apply-theme.sh preset-nord.yaml
./apply-theme.sh preset-highcontrast.yaml
```

**Expected output:**
```
╔═══════════════════════════════════════════════════════════════════╗
║         CORE Network Laboratory - Theme Applicator                ║
╚═══════════════════════════════════════════════════════════════════╝

📦 Applying theme: CORE Dark

📖 Loading configuration from theme-config.yaml
✅ Configuration loaded: CORE Dark

📁 Creating directory structure...
  ✓ /root/.fluxbox
  ✓ /root/.fluxbox/styles/CORE-Theme
  ...

✅ Theme applied successfully!
```

### 2. Customize Your Colors

```bash
# Edit the main configuration
nano theme-config.yaml

# Find the colors section (around line 20)
# Change the accent color:
#   accent: "#00d9ff"    # Change to your brand color
# Example: accent: "#ff6b35"  (orange)
#         accent: "#7c3aed"  (purple)
#         accent: "#10b981"  (green)

# Save and apply
./apply-theme.sh

# Reload Fluxbox to see changes
fluxbox-remote restart
```

### 3. View Generated Files

```bash
# View the generated Fluxbox theme
cat ~/.fluxbox/styles/CORE-Theme/theme.cfg

# View the enhanced menu
cat ~/.fluxbox/menu

# View desktop shortcuts
ls -la ~/Desktop/

# View keyboard shortcuts
cat ~/.fluxbox/keys
```

## 🎨 Quick Customization Examples

### Change to Your Brand Colors

Edit `theme-config.yaml`:

```yaml
colors:
  primary:
    background: "#0a0e27"     # Your dark background
    accent: "#ff6b35"         # Your brand color (orange example)
```

Apply:
```bash
./apply-theme.sh && fluxbox-remote restart
```

### Make Text Larger (Accessibility)

```yaml
fonts:
  size:
    normal: 12                # Increase from 10
    heading: 14               # Increase from 12
```

### Disable Desktop Shortcuts

```yaml
features:
  shortcuts:
    enabled: false            # Change to false
```

### Add a Custom Shortcut

```yaml
features:
  shortcuts:
    items:
      - name: "My Tool"
        command: "/path/to/my/tool"
        icon: "application-icon"
        enabled: true
```

## 📋 Available Preset Themes

| Theme | Description | Best For |
|-------|-------------|----------|
| `theme-config.yaml` | Dark theme (default) | General use, long sessions |
| `preset-light.yaml` | Light theme | Well-lit rooms, presentations |
| `preset-highcontrast.yaml` | High contrast | Accessibility, projectors |
| `preset-nord.yaml` | Nord color scheme | Cool, arctic aesthetic |

Try them all:
```bash
for theme in theme-config.yaml preset-*.yaml; do
    echo "Trying: $theme"
    ./apply-theme.sh $theme
    read -p "Press Enter for next theme..."
done
```

## 🚀 Integration into Docker

### Quick Integration

Add to `dockerfiles/Dockerfile.novnc` (around line 250):

```dockerfile
# Install theming system
RUN /opt/core/venv/bin/pip install pyyaml
COPY dockerfiles/novnc/themes /opt/themes
RUN chmod +x /opt/themes/*.sh /opt/themes/*.py && \
    cd /opt/themes && \
    python3 apply-theme.py theme-config.yaml
```

### Build and Test

```bash
# From repository root
docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest .

# Run
docker run -d \
  --name core-novnc \
  --privileged \
  -p 6080:6080 \
  core-novnc:latest

# Access
# Browser: http://localhost:6080
# Password: core123
```

## 💡 Pro Tips

### Tip 1: Keep a Backup

```bash
# Save your custom theme
cp theme-config.yaml my-backup-theme.yaml
```

### Tip 2: Quick Color Testing

Use color picker websites:
- https://coolors.co/ - Generate palettes
- https://colorhunt.co/ - Browse popular palettes
- https://color.adobe.com/ - Adobe Color Wheel

### Tip 3: Theme Per Use Case

Create specialized themes:

```bash
# Networking course
cp theme-config.yaml theme-networking.yaml
# Edit: Use blue accent (#3b82f6)

# Security course
cp theme-config.yaml theme-security.yaml
# Edit: Use red accent (#ef4444)

# Performance testing
cp theme-config.yaml theme-performance.yaml
# Edit: Use green accent (#10b981)
```

Apply the right theme for your task:
```bash
./apply-theme.sh theme-networking.yaml
```

### Tip 4: Keyboard Shortcuts Cheat Sheet

Default shortcuts (customizable in config):

| Shortcut | Action |
|----------|--------|
| `Super+C` | Launch CORE GUI |
| `Super+W` | Launch Wireshark |
| `Super+T` | Open Terminal |
| `Super+F` | File Manager |
| `Super+Q` | Close Window |
| `Alt+Tab` | Switch Windows |
| `Print` | Screenshot |

## 🎓 Learning Path

1. **Start with presets** - Try each one to see what you like
2. **Small changes** - Change one color, apply, see result
3. **Fonts next** - Adjust sizes for comfort
4. **Shortcuts** - Add tools you use frequently
5. **Advanced** - Custom branding, wallpapers, layouts

## 📖 Full Documentation

- `README.md` - Complete customization guide
- `INTEGRATION.md` - Docker integration instructions
- `theme-config.yaml` - Fully commented configuration

## 🆘 Quick Troubleshooting

**Theme not applying?**
```bash
# Check Python and PyYAML
python3 -c "import yaml; print('OK')"

# If error, install PyYAML
pip3 install pyyaml
```

**Scripts not executable?**
```bash
chmod +x apply-theme.sh apply-theme.py
```

**Want to reset to default?**
```bash
./apply-theme.sh theme-config.yaml
```

**Fluxbox not reloading?**
```bash
# Try each in order:
fluxbox-remote reconfigure
fluxbox-remote restart
killall fluxbox  # (will auto-restart if using supervisor)
```

## 🎉 Next Steps

Now that you have the theming system:

1. **Integrate into Docker** (see INTEGRATION.md)
2. **Customize for your needs** (see README.md)
3. **Share your themes** with others
4. **Build welcome screen** (optional, see plans)
5. **Add topology templates** (optional, see plans)

## 📊 What Was Created

```
themes/
├── theme-config.yaml              # Main dark theme (customizable)
├── preset-light.yaml              # Light theme
├── preset-highcontrast.yaml       # High contrast
├── preset-nord.yaml               # Nord color scheme
├── apply-theme.py                 # Theme generator (Python)
├── apply-theme.sh                 # Convenient wrapper (Bash)
├── README.md                      # Full documentation
├── INTEGRATION.md                 # Docker integration guide
└── QUICKSTART.md                  # This file
```

**Generated files** (when applied):
- `~/.fluxbox/styles/CORE-Theme/theme.cfg`
- `~/.fluxbox/init`
- `~/.fluxbox/menu`
- `~/.fluxbox/keys`
- `~/Desktop/*.desktop`
- `~/.vnc/xstartup`

## 🌟 Features

✅ Flexible color customization
✅ 4 preset themes included
✅ Desktop shortcuts
✅ Enhanced menu structure
✅ Keyboard shortcuts
✅ YAML configuration
✅ Live application (no rebuild needed)
✅ Full documentation
✅ Docker integration ready

---

**You're ready to go!** Start customizing and make CORE Laboratory your own.

Questions? Check README.md for complete documentation.
