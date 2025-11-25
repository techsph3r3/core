# CORE Network Laboratory - Theming System

A flexible, configuration-driven theming system for the CORE Network Laboratory noVNC desktop environment.

## 🎨 Features

- **Easy Customization**: Edit colors, fonts, and UI elements in YAML
- **Preset Themes**: Dark (default), Light, High Contrast, Nord
- **Keyboard Shortcuts**: Customizable key bindings
- **Desktop Shortcuts**: One-click access to tools
- **Enhanced Menu**: Organized, learner-friendly menu structure
- **Live Application**: Apply themes without rebuilding containers

## 📁 File Structure

```
themes/
├── theme-config.yaml          # Main theme configuration (Dark theme)
├── preset-light.yaml          # Light theme preset
├── preset-highcontrast.yaml   # High contrast theme
├── preset-nord.yaml           # Nord color scheme
├── apply-theme.py             # Theme generation script
├── apply-theme.sh             # Convenient wrapper script
└── README.md                  # This file
```

## 🚀 Quick Start

### Apply Default Theme (Dark)

```bash
cd /opt/themes  # Or wherever you placed the themes directory
./apply-theme.sh
```

### Apply a Preset Theme

```bash
# Light theme
./apply-theme.sh preset-light.yaml

# High contrast
./apply-theme.sh preset-highcontrast.yaml

# Nord theme
./apply-theme.sh preset-nord.yaml
```

### Reload Fluxbox

After applying a theme, reload Fluxbox to see changes:

```bash
fluxbox-remote restart
```

Or right-click desktop → System → Restart Fluxbox

## 🎨 Customizing Your Theme

### Option 1: Edit Existing Theme

1. Open the configuration file:
   ```bash
   nano theme-config.yaml
   # or
   mousepad theme-config.yaml
   ```

2. Change colors in the `colors:` section:
   ```yaml
   colors:
     primary:
       background: "#1a1d29"   # Change this to any hex color
       accent: "#00d9ff"       # Your brand color
   ```

3. Apply the changes:
   ```bash
   ./apply-theme.sh
   ```

4. Reload Fluxbox:
   ```bash
   fluxbox-remote restart
   ```

### Option 2: Create Your Own Theme

1. Copy an existing preset:
   ```bash
   cp theme-config.yaml my-custom-theme.yaml
   ```

2. Edit your custom theme:
   ```bash
   nano my-custom-theme.yaml
   ```

3. Update theme metadata:
   ```yaml
   theme:
     name: "My Custom Theme"
     version: "1.0"
     author: "Your Name"
     description: "My personalized CORE theme"
   ```

4. Customize colors, fonts, and features

5. Apply your theme:
   ```bash
   ./apply-theme.sh my-custom-theme.yaml
   ```

## 🎯 Configuration Guide

### Color Palette

All colors use hex format (`#RRGGBB`):

```yaml
colors:
  primary:
    background: "#1a1d29"      # Main background color
    foreground: "#e2e8f0"      # Main text color
    accent: "#00d9ff"          # Accent/highlight color
    secondary: "#2d3748"       # Secondary background

  semantic:
    success: "#10b981"         # Green - success states
    warning: "#ff9500"         # Orange - warnings
    error: "#ef4444"           # Red - errors
    info: "#3b82f6"            # Blue - information
```

**Pro tip**: Use [coolors.co](https://coolors.co) to generate color palettes.

### Typography

```yaml
fonts:
  family:
    sans: "DejaVu Sans"        # UI font
    mono: "DejaVu Sans Mono"   # Terminal/code font
    heading: "DejaVu Sans"     # Heading font

  size:
    small: 9                   # Small text
    normal: 10                 # Normal text
    large: 11                  # Large text
    heading: 12                # Headings
    title: 14                  # Window titles
```

### UI Elements

```yaml
ui_elements:
  window:
    border_width: 2            # Window border thickness (1-5)
    title_height: 24           # Title bar height (20-32)
    shadow: true               # Enable shadows (true/false)

  panel:
    enabled: true              # Show bottom panel (true/false)
    height: 40                 # Panel height (30-60)
    transparency: 90           # Transparency (0-100)
```

### Desktop Shortcuts

Enable/disable shortcuts and add your own:

```yaml
features:
  shortcuts:
    enabled: true
    items:
      - name: "My Tool"
        command: "/path/to/tool"
        icon: "application-icon"
        enabled: true
```

**Common icon names**:
- `network-workgroup` - Network/connectivity
- `utilities-terminal` - Terminal/console
- `system-file-manager` - File browser
- `help-browser` - Documentation/help
- `applications-science` - Scientific tools
- `preferences-desktop` - Settings

### Keyboard Shortcuts

Customize shortcuts (Mod4 = Super/Windows key, Mod1 = Alt):

```yaml
features:
  keyboard_shortcuts:
    enabled: true
    shortcuts:
      launch_core: "Mod4 c"           # Super+C
      launch_wireshark: "Mod4 w"      # Super+W
      launch_terminal: "Mod4 t"       # Super+T
      close_window: "Mod4 q"          # Super+Q
```

### Branding

Customize the application name and welcome message:

```yaml
branding:
  app_name: "Your Lab Name"
  tagline: "Your Custom Tagline"

  welcome:
    enabled: true              # Show welcome screen
    show_on_startup: false     # Show every time (true) or once (false)
```

## 🎨 Color Scheme Examples

### Professional Blue
```yaml
colors:
  primary:
    background: "#0f172a"
    accent: "#3b82f6"
```

### Green/Nature
```yaml
colors:
  primary:
    background: "#064e3b"
    accent: "#10b981"
```

### Purple/Tech
```yaml
colors:
  primary:
    background: "#1e1b4b"
    accent: "#8b5cf6"
```

### Orange/Energy
```yaml
colors:
  primary:
    background: "#1c1917"
    accent: "#f97316"
```

## 📋 Generated Files

When you apply a theme, these files are created/updated:

- `~/.fluxbox/styles/CORE-Theme/theme.cfg` - Fluxbox theme
- `~/.fluxbox/init` - Fluxbox configuration
- `~/.fluxbox/menu` - Application menu
- `~/.fluxbox/keys` - Keyboard shortcuts
- `~/Desktop/*.desktop` - Desktop shortcuts
- `~/.vnc/xstartup` - VNC session startup

## 🔧 Troubleshooting

### Theme not applying

1. Check for YAML syntax errors:
   ```bash
   python3 -c "import yaml; yaml.safe_load(open('theme-config.yaml'))"
   ```

2. Ensure PyYAML is installed:
   ```bash
   pip3 install pyyaml
   ```

3. Make scripts executable:
   ```bash
   chmod +x apply-theme.sh apply-theme.py
   ```

### Colors look wrong

- Verify hex colors are in format `#RRGGBB`
- Use lowercase for hex values
- Test colors at [htmlcolorcodes.com](https://htmlcolorcodes.com/)

### Desktop shortcuts not appearing

1. Check Desktop directory exists:
   ```bash
   mkdir -p ~/Desktop
   ```

2. Verify shortcuts are enabled in config:
   ```yaml
   features:
     shortcuts:
       enabled: true
   ```

3. Check file permissions:
   ```bash
   chmod +x ~/Desktop/*.desktop
   ```

### Menu not updating

1. Reload Fluxbox configuration:
   ```bash
   fluxbox-remote reconfigure
   ```

2. Or restart Fluxbox completely:
   ```bash
   fluxbox-remote restart
   ```

## 🎓 Tips for Learners

### Create Theme for Different Courses

Create specialized themes for different learning contexts:

```bash
# Networking fundamentals course
cp theme-config.yaml theme-networking101.yaml
# Edit to use blue/connectivity colors

# Security course
cp theme-config.yaml theme-security.yaml
# Edit to use red/security colors

# Apply the appropriate theme
./apply-theme.sh theme-networking101.yaml
```

### Organization-Specific Branding

```yaml
branding:
  app_name: "University Network Lab"
  tagline: "CS 455 - Network Simulation"
```

### Accessibility

Use preset-highcontrast.yaml as a starting point for:
- Visual impairments
- Bright environments
- Projector displays

## 📚 Advanced Customization

### Adding New Wallpaper

1. Place image in `~/.fluxbox/backgrounds/`

2. Update config:
   ```yaml
   wallpaper:
     type: "image"
     image_path: "/root/.fluxbox/backgrounds/my-wallpaper.png"
     image_mode: "scaled"  # or: centered, tiled, stretched
   ```

### Creating a Theme Pack

1. Create a directory with multiple theme files
2. Add a README explaining each theme
3. Users can easily switch between them

### Version Control

Track your custom themes with git:

```bash
cd /opt/themes
git init
git add my-custom-theme.yaml
git commit -m "My custom CORE theme"
```

## 🤝 Sharing Themes

### Export Your Theme

Share your theme with others:

```bash
# Create a theme package
tar czf my-core-theme.tar.gz my-custom-theme.yaml

# Or just share the YAML file
cp my-custom-theme.yaml /path/to/share/
```

### Import a Theme

```bash
# Copy to themes directory
cp downloaded-theme.yaml /opt/themes/

# Apply it
cd /opt/themes
./apply-theme.sh downloaded-theme.yaml
```

## 📖 Reference

### Complete Configuration Schema

See `theme-config.yaml` for the complete, documented schema with all available options.

### Color Naming Convention

- `primary.*` - Main visual identity colors
- `semantic.*` - Functional state colors (success, error, etc.)
- `ui.*` - UI element colors (borders, shadows)
- `text.*` - Text in different contexts
- `window.*` - Window-specific colors
- `menu.*` - Menu-specific colors
- `toolbar.*` - Toolbar/panel colors

### Keyboard Modifier Keys

- `Mod4` - Super/Windows key
- `Mod1` - Alt key
- `Control` - Ctrl key
- `Shift` - Shift key

Combine them: `Control Mod4 Left` = Ctrl+Super+Left Arrow

## 🆘 Getting Help

1. **Check the examples** in this README
2. **Examine preset themes** for reference
3. **Read the comments** in theme-config.yaml
4. **Test incrementally** - change one thing, apply, test
5. **Keep backups** of working configurations

## 📝 License

This theming system is part of the CORE Network Laboratory project.

---

**Created for the CORE Network Laboratory project**
*Making network simulation beautiful and accessible*
