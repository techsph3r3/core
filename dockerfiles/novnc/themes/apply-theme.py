#!/usr/bin/env python3
"""
CORE Network Laboratory - Theme Application Script
Reads theme-config.yaml and generates all theme files
"""

import os
import sys
import yaml
import shutil
from pathlib import Path
from datetime import datetime


class ThemeApplicator:
    """Applies theme configuration to generate all necessary files"""

    def __init__(self, config_path):
        """Initialize with configuration file path"""
        self.config_path = Path(config_path)
        self.config = self.load_config()
        self.home = Path.home()
        self.fluxbox_dir = self.home / ".fluxbox"
        self.desktop_dir = self.home / "Desktop"

    def load_config(self):
        """Load and parse YAML configuration"""
        print(f"📖 Loading configuration from {self.config_path}")
        try:
            with open(self.config_path, 'r') as f:
                config = yaml.safe_load(f)
            print(f"✅ Configuration loaded: {config['theme']['name']}")
            return config
        except Exception as e:
            print(f"❌ Error loading configuration: {e}")
            sys.exit(1)

    def create_directories(self):
        """Create necessary directories"""
        print("\n📁 Creating directory structure...")
        dirs = [
            self.fluxbox_dir,
            self.fluxbox_dir / "styles" / "CORE-Theme",
            self.fluxbox_dir / "backgrounds",
            self.desktop_dir,
            self.home / ".config" / "tint2",
            self.home / ".config" / "autostart",
        ]
        for directory in dirs:
            directory.mkdir(parents=True, exist_ok=True)
            print(f"  ✓ {directory}")

    def generate_fluxbox_theme(self):
        """Generate Fluxbox style file from configuration"""
        print("\n🎨 Generating Fluxbox theme...")

        c = self.config['colors']
        fonts = self.config['fonts']
        ui = self.config['ui_elements']['window']

        theme_content = f"""# {self.config['theme']['name']} - Fluxbox Theme
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
# Description: {self.config['theme']['description']}

# ============================================================================
# BACKGROUND
# ============================================================================
background: flat solid
background.color: {c['primary']['background']}
background.textColor: {c['text']['primary']}

# ============================================================================
# WINDOW TITLE - FOCUSED
# ============================================================================
window.title.focus: flat gradient vertical
window.title.focus.color: {c['window']['title_focus']}
window.title.focus.colorTo: {c['primary']['background']}
window.title.focus.textColor: {c['primary']['accent']}

window.label.focus: flat
window.label.focus.color: {c['window']['title_focus']}
window.label.focus.textColor: {c['primary']['accent']}
window.label.focus.font: {fonts['family']['sans']}:size={fonts['size']['normal']}:weight={fonts['weight']['bold']}

window.button.focus: flat
window.button.focus.color: {c['window']['title_focus']}
window.button.focus.picColor: {c['primary']['accent']}

# ============================================================================
# WINDOW TITLE - UNFOCUSED
# ============================================================================
window.title.unfocus: flat solid
window.title.unfocus.color: {c['window']['title_unfocus']}
window.title.unfocus.textColor: {c['text']['secondary']}

window.label.unfocus: flat
window.label.unfocus.color: {c['window']['title_unfocus']}
window.label.unfocus.textColor: {c['text']['secondary']}
window.label.unfocus.font: {fonts['family']['sans']}:size={fonts['size']['normal']}

window.button.unfocus: flat
window.button.unfocus.color: {c['window']['title_unfocus']}
window.button.unfocus.picColor: {c['text']['secondary']}

# ============================================================================
# WINDOW BUTTONS - PRESSED
# ============================================================================
window.button.pressed: flat
window.button.pressed.color: {c['primary']['accent']}
window.button.pressed.picColor: {c['primary']['background']}

# ============================================================================
# WINDOW FRAME
# ============================================================================
window.frame.focusColor: {c['window']['border_focus']}
window.frame.unfocusColor: {c['window']['border_unfocus']}
window.handleWidth: 0
window.bevelWidth: 0
window.borderWidth: {ui['border_width']}
window.borderColor: {c['ui']['border']}

# ============================================================================
# TOOLBAR
# ============================================================================
toolbar: flat gradient vertical
toolbar.color: {c['toolbar']['background']}
toolbar.colorTo: {c['primary']['background']}
toolbar.textColor: {c['toolbar']['text']}
toolbar.font: {fonts['family']['sans']}:size={fonts['size']['normal']}

toolbar.label: flat
toolbar.label.color: {c['toolbar']['background']}
toolbar.label.textColor: {c['toolbar']['text']}

toolbar.windowLabel: flat
toolbar.windowLabel.color: {c['toolbar']['background']}
toolbar.windowLabel.textColor: {c['primary']['accent']}

toolbar.clock: flat
toolbar.clock.color: {c['toolbar']['background']}
toolbar.clock.textColor: {c['toolbar']['accent']}
toolbar.clock.font: {fonts['family']['sans']}:size={fonts['size']['normal']}:weight={fonts['weight']['bold']}

toolbar.workspace: flat
toolbar.workspace.color: {c['toolbar']['background']}
toolbar.workspace.textColor: {c['toolbar']['accent']}

toolbar.button: flat
toolbar.button.color: {c['toolbar']['background']}
toolbar.button.picColor: {c['toolbar']['text']}

toolbar.button.pressed: flat
toolbar.button.pressed.color: {c['primary']['accent']}
toolbar.button.pressed.picColor: {c['primary']['background']}

toolbar.iconbar.focused: flat
toolbar.iconbar.focused.color: {c['ui']['highlight']}
toolbar.iconbar.focused.textColor: {c['primary']['accent']}

toolbar.iconbar.unfocused: flat
toolbar.iconbar.unfocused.color: {c['toolbar']['background']}
toolbar.iconbar.unfocused.textColor: {c['text']['secondary']}

# ============================================================================
# MENU - TITLE
# ============================================================================
menu.title: flat gradient vertical
menu.title.color: {c['menu']['title_bg']}
menu.title.colorTo: {c['primary']['accent']}
menu.title.textColor: {c['menu']['title_text']}
menu.title.font: {fonts['family']['heading']}:size={fonts['size']['heading']}:weight={fonts['weight']['bold']}

# ============================================================================
# MENU - FRAME
# ============================================================================
menu.frame: flat
menu.frame.color: {c['menu']['background']}
menu.frame.textColor: {c['menu']['text']}
menu.frame.font: {fonts['family']['sans']}:size={fonts['size']['normal']}
menu.frame.disableColor: {c['text']['disabled']}

# ============================================================================
# MENU - HILITE (SELECTED ITEM)
# ============================================================================
menu.hilite: flat
menu.hilite.color: {c['menu']['highlight_bg']}
menu.hilite.textColor: {c['menu']['highlight_text']}

# ============================================================================
# MENU - BULLET
# ============================================================================
menu.bullet: triangle
menu.bullet.position: right

# ============================================================================
# BORDERS AND BEVELS
# ============================================================================
borderWidth: {ui['border_width']}
borderColor: {c['ui']['border']}
bevelWidth: 0

# ============================================================================
# MISC
# ============================================================================
handleWidth: 4
"""

        theme_file = self.fluxbox_dir / "styles" / "CORE-Theme" / "theme.cfg"
        theme_file.parent.mkdir(parents=True, exist_ok=True)

        with open(theme_file, 'w') as f:
            f.write(theme_content)

        print(f"  ✓ Fluxbox theme: {theme_file}")
        return theme_file

    def generate_fluxbox_init(self):
        """Generate Fluxbox init file to use the theme"""
        print("\n⚙️  Configuring Fluxbox...")

        init_file = self.fluxbox_dir / "init"

        # Read existing init if it exists, otherwise start fresh
        if init_file.exists():
            with open(init_file, 'r') as f:
                lines = f.readlines()
            # Remove old style line
            lines = [l for l in lines if not l.startswith('session.styleFile:')]
        else:
            lines = []

        # Add our style
        lines.append(f"session.styleFile: {self.fluxbox_dir}/styles/CORE-Theme/theme.cfg\n")

        # Add other useful settings
        if not any('session.screen0.workspaces:' in l for l in lines):
            lines.append('session.screen0.workspaces: 4\n')
        if not any('session.screen0.workspaceNames:' in l for l in lines):
            lines.append('session.screen0.workspaceNames: Design,Analysis,Testing,Docs\n')
        if not any('session.screen0.toolbar.visible:' in l for l in lines):
            lines.append('session.screen0.toolbar.visible: true\n')

        with open(init_file, 'w') as f:
            f.writelines(lines)

        print(f"  ✓ Fluxbox init: {init_file}")

    def generate_desktop_shortcuts(self):
        """Generate desktop shortcuts from configuration"""
        if not self.config['features']['shortcuts']['enabled']:
            print("\n⏭️  Desktop shortcuts disabled in config")
            return

        print("\n🔗 Generating desktop shortcuts...")

        shortcuts = self.config['features']['shortcuts']['items']

        for item in shortcuts:
            if not item.get('enabled', True):
                print(f"  ⏭️  Skipping disabled: {item['name']}")
                continue

            filename = item['name'].replace(' ', '_') + '.desktop'
            filepath = self.desktop_dir / filename

            content = f"""[Desktop Entry]
Type=Application
Version=1.0
Name={item['name']}
Comment=Launch {item['name']}
Exec={item['command']}
Icon={item['icon']}
Terminal=false
Categories=Network;Education;
StartupNotify=true
"""

            with open(filepath, 'w') as f:
                f.write(content)

            # Make executable
            filepath.chmod(0o755)

            print(f"  ✓ {item['name']}: {filepath}")

    def generate_fluxbox_menu(self):
        """Generate enhanced Fluxbox menu"""
        print("\n📋 Generating Fluxbox menu...")

        branding = self.config['branding']

        menu_content = f"""# {branding['app_name']} - Fluxbox Menu
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

[begin] ({branding['app_name']})

  [submenu] (🌐 Network Simulation)
    [exec] (CORE GUI) {{/opt/core/venv/bin/core-gui}}
    [exec] (CORE Daemon Status) {{xterm -hold -e "systemctl status core-daemon || echo 'Run: supervisorctl status core-daemon'"}}
    [separator]
    [submenu] (📁 Topology Templates)
      [exec] (Browse Examples) {{thunar /opt/examples}}
      [separator]
      [exec] (Wireless Mesh) {{xterm -hold -e "cd /opt/examples && python3 wireless_mesh.py || echo 'Template not yet created'"}}
      [exec] (Enterprise Network) {{xterm -hold -e "cd /opt/examples && python3 enterprise.py || echo 'Template not yet created'"}}
      [exec] (Data Center) {{xterm -hold -e "cd /opt/examples && python3 datacenter.py || echo 'Template not yet created'"}}
      [exec] (WAN Simulation) {{xterm -hold -e "cd /opt/examples && python3 wan.py || echo 'Template not yet created'"}}
    [end]
    [separator]
    [submenu] (🤖 MCP Topology Generator)
      [exec] (Test Generator) {{xterm -hold -e "cd /opt/core-mcp-server && python3 test_topology_gen.py"}}
      [exec] (View Generated Files) {{thunar /tmp}}
      [exec] (MCP Documentation) {{xterm -hold -e "cd /opt/core-mcp-server && cat README.md | less"}}
    [end]
  [end]

  [submenu] (🔬 Network Analysis)
    [exec] (Wireshark) {{wireshark}}
    [exec] (tcpdump Helper) {{xterm -e "echo 'Usage: tcpdump -i <interface> -w capture.pcap'; echo 'Press Ctrl+C to stop'; echo ''; read -p 'Interface: ' iface; sudo tcpdump -i $iface -w ~/capture-$(date +%Y%m%d-%H%M%S).pcap"}}
    [separator]
    [exec] (iperf3 Server) {{xterm -hold -e "iperf3 -s"}}
    [exec] (iperf3 Client) {{xterm -e "read -p 'Server IP: ' ip; iperf3 -c $ip"}}
    [separator]
    [exec] (Network Monitor) {{xterm -hold -e "watch -n 1 'ip addr; echo; ip route'"}}
    [exec] (Docker Containers) {{xterm -hold -e "watch -n 2 docker ps"}}
    [exec] (Process Monitor) {{htop}}
  [end]

  [submenu] (📚 Learning Resources)
    [exec] (CORE Documentation) {{firefox /opt/core/docs/index.html || xdg-open /opt/core/docs/index.html}}
    [exec] (MCP Server Guide) {{xterm -hold -e "less /opt/core-mcp-server/README.md"}}
    [exec] (Example Topologies) {{thunar /opt/examples}}
    [separator]
    [submenu] (🎓 Quick References)
      [exec] (OSPF Cheat Sheet) {{xterm -hold -e "echo 'OSPF Quick Reference'; echo '=================='; echo 'Coming soon...'; read"}}
      [exec] (BGP Cheat Sheet) {{xterm -hold -e "echo 'BGP Quick Reference'; echo '=================='; echo 'Coming soon...'; read"}}
      [exec] (Wireshark Filters) {{xterm -hold -e "echo 'Wireshark Common Filters'; echo '======================='; echo 'tcp.port == 80  # HTTP traffic'; echo 'ip.addr == 192.168.1.1  # Specific IP'; echo 'icmp  # Ping packets'; echo 'tcp.flags.syn == 1  # TCP SYN packets'; read"}}
    [end]
    [separator]
    [exec] (🌍 Online Tutorials) {{firefox https://coreemu.github.io/core/tutorials/ || xdg-open https://coreemu.github.io/core/tutorials/}}
  [end]

  [submenu] (🛠️ Tools)
    [exec] (Terminal) {{xterm}}
    [exec] (Root Terminal) {{xterm -e "sudo -i"}}
    [exec] (File Manager) {{thunar}}
    [exec] (Text Editor) {{mousepad || nano || vi}}
    [separator]
    [exec] (Calculator) {{galculator || xcalc}}
    [exec] (Screenshot) {{xfce4-screenshooter || scrot}}
    [separator]
    [submenu] (🐳 Docker)
      [exec] (Container List) {{xterm -hold -e "docker ps -a"}}
      [exec] (Image List) {{xterm -hold -e "docker images"}}
      [exec] (Docker Stats) {{xterm -hold -e "docker stats"}}
      [exec] (Prune Unused) {{xterm -hold -e "docker system prune -f"}}
    [end]
  [end]

  [submenu] (⚙️ System)
    [exec] (Task Manager) {{htop}}
    [exec] (System Info) {{xterm -hold -e "uname -a; echo; cat /etc/os-release; echo; df -h; echo; free -h"}}
    [separator]
    [submenu] (🔧 Services)
      [exec] (CORE Daemon Status) {{xterm -hold -e "supervisorctl status core-daemon"}}
      [exec] (VNC Status) {{xterm -hold -e "supervisorctl status vnc"}}
      [exec] (noVNC Status) {{xterm -hold -e "supervisorctl status novnc"}}
      [exec] (Tailscale Status) {{xterm -hold -e "tailscale status || echo 'Tailscale not running'"}}
      [separator]
      [exec] (Restart All Services) {{xterm -hold -e "sudo supervisorctl restart all"}}
    [end]
    [separator]
    [submenu] (🎨 Theme)
      [exec] (Apply Theme) {{xterm -hold -e "cd /opt/themes && python3 apply-theme.py theme-config.yaml"}}
      [exec] (Edit Theme Config) {{mousepad /opt/themes/theme-config.yaml || nano /opt/themes/theme-config.yaml}}
      [exec] (Reload Fluxbox) {{fluxbox-remote restart}}
    [end]
    [separator]
    [restart] (♻️ Restart Fluxbox)
    [reconfigure] (🔄 Reload Configuration)
    [reconfig] (🔄 Reconfigure)
  [end]

  [separator]
  [workspaces] (📁 Workspaces)
  [separator]

  [submenu] (ℹ️ About)
    [exec] (CORE Version) {{xterm -hold -e "echo 'CORE Network Emulator'; echo; core-daemon --version; echo; echo 'Theme: {self.config['theme']['name']}'; echo 'Version: {self.config['theme']['version']}'; read"}}
    [exec] (Theme Info) {{xterm -hold -e "echo 'Theme: {self.config['theme']['name']}'; echo 'Version: {self.config['theme']['version']}'; echo 'Author: {self.config['theme']['author']}'; echo; echo 'Description:'; echo '{self.config['theme']['description']}'; read"}}
  [end]

  [separator]
  [exit] (❌ Exit)

[end]
"""

        menu_file = self.fluxbox_dir / "menu"
        with open(menu_file, 'w') as f:
            f.write(menu_content)

        print(f"  ✓ Fluxbox menu: {menu_file}")

    def generate_keyboard_shortcuts(self):
        """Generate keyboard shortcuts configuration"""
        if not self.config['features']['keyboard_shortcuts']['enabled']:
            print("\n⏭️  Keyboard shortcuts disabled in config")
            return

        print("\n⌨️  Generating keyboard shortcuts...")

        shortcuts = self.config['features']['keyboard_shortcuts']['shortcuts']

        keys_content = f"""# {self.config['branding']['app_name']} - Keyboard Shortcuts
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

# ============================================================================
# APPLICATION LAUNCHERS
# ============================================================================
{shortcuts['launch_core']} :Exec /opt/core/venv/bin/core-gui
{shortcuts['launch_wireshark']} :Exec wireshark
{shortcuts['launch_terminal']} :Exec xterm
{shortcuts['launch_filemanager']} :Exec thunar
Mod4 Return :Exec xterm

# ============================================================================
# WINDOW MANAGEMENT
# ============================================================================
{shortcuts['close_window']} :Close
Mod4 F4 :Close
{shortcuts['next_window']} :NextWindow
{shortcuts['prev_window']} :PrevWindow

# Maximize/Minimize
Mod4 Up :Maximize
Mod4 Down :Minimize
Mod4 Left :MaximizeHorizontal
Mod4 Right :MaximizeVertical

# Move window
Control Mod4 Left :MoveLeft
Control Mod4 Right :MoveRight
Control Mod4 Up :MoveUp
Control Mod4 Down :MoveDown

# Resize window
Shift Mod4 Left :ResizeHorizontal -5
Shift Mod4 Right :ResizeHorizontal +5
Shift Mod4 Up :ResizeVertical -5
Shift Mod4 Down :ResizeVertical +5

# ============================================================================
# WORKSPACES (VIRTUAL DESKTOPS)
# ============================================================================
Mod4 1 :Workspace 1
Mod4 2 :Workspace 2
Mod4 3 :Workspace 3
Mod4 4 :Workspace 4

# Move window to workspace
Mod4 Shift 1 :SendToWorkspace 1
Mod4 Shift 2 :SendToWorkspace 2
Mod4 Shift 3 :SendToWorkspace 3
Mod4 Shift 4 :SendToWorkspace 4

# Next/Previous workspace
Mod4 Right :NextWorkspace
Mod4 Left :PrevWorkspace

# ============================================================================
# DESKTOP
# ============================================================================
# Right-click menu
OnDesktop Mouse3 :RootMenu

# Middle-click workspace menu
OnDesktop Mouse2 :WorkspaceMenu

# Scroll to change workspace
OnDesktop Mouse4 :PrevWorkspace
OnDesktop Mouse5 :NextWorkspace

# ============================================================================
# SCREENSHOTS
# ============================================================================
{shortcuts['screenshot']} :Exec xfce4-screenshooter || scrot ~/screenshot-%Y%m%d-%H%M%S.png
Control {shortcuts['screenshot']} :Exec xfce4-screenshooter -w || scrot -u ~/window-%Y%m%d-%H%M%S.png
Shift {shortcuts['screenshot']} :Exec xfce4-screenshooter -r || scrot -s ~/selection-%Y%m%d-%H%M%S.png

# ============================================================================
# FLUXBOX CONTROL
# ============================================================================
Mod4 r :Reconfigure
Mod4 Escape :RootMenu
"""

        keys_file = self.fluxbox_dir / "keys"
        with open(keys_file, 'w') as f:
            f.write(keys_content)

        print(f"  ✓ Keyboard shortcuts: {keys_file}")

    def generate_xstartup(self):
        """Generate enhanced xstartup with theme loading"""
        print("\n🚀 Generating xstartup script...")

        xstartup_content = f"""#!/bin/bash
# {self.config['branding']['app_name']} - VNC Session Startup
# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

# Start D-Bus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi
export DBUS_SESSION_BUS_ADDRESS

# Set background color (before Fluxbox starts)
xsetroot -solid "{self.config['colors']['primary']['background']}" &

# Start clipboard synchronization
autocutsel -selection CLIPBOARD -fork
autocutsel -selection PRIMARY -fork

# Start Fluxbox window manager
fluxbox &

# Wait for Fluxbox to start
sleep 2

# Start Tailscale daemon if available
if command -v tailscaled >/dev/null 2>&1; then
    mkdir -p /var/lib/tailscale /run/tailscale
    tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock &
fi

# Launch CORE GUI
/opt/core/venv/bin/core-gui &

# Show welcome screen on first launch (if enabled)
WELCOME_FLAG="$HOME/.config/core-welcome-shown"
if [ "{self.config['branding']['welcome']['enabled']}" = "True" ] && [ ! -f "$WELCOME_FLAG" ]; then
    sleep 3
    if command -v firefox >/dev/null 2>&1; then
        firefox /opt/themes/welcome.html &
        touch "$WELCOME_FLAG"
    fi
fi

# Keep script running
wait
"""

        xstartup_file = self.home / ".vnc" / "xstartup"
        xstartup_file.parent.mkdir(parents=True, exist_ok=True)

        with open(xstartup_file, 'w') as f:
            f.write(xstartup_content)

        xstartup_file.chmod(0o755)

        print(f"  ✓ xstartup: {xstartup_file}")

    def apply_all(self):
        """Apply all theme configurations"""
        print(f"\n{'='*70}")
        print(f"🎨 Applying {self.config['theme']['name']} Theme")
        print(f"{'='*70}")

        self.create_directories()
        self.generate_fluxbox_theme()
        self.generate_fluxbox_init()
        self.generate_fluxbox_menu()
        self.generate_keyboard_shortcuts()
        self.generate_desktop_shortcuts()
        self.generate_xstartup()

        print(f"\n{'='*70}")
        print(f"✅ Theme applied successfully!")
        print(f"{'='*70}")
        print(f"\nTo activate the theme:")
        print(f"  1. If Fluxbox is running: Right-click → System → Restart Fluxbox")
        print(f"  2. Or restart your VNC session")
        print(f"\nTo customize colors:")
        print(f"  1. Edit: {self.config_path}")
        print(f"  2. Run: python3 {__file__} {self.config_path}")
        print(f"\nDesktop shortcuts created in: {self.desktop_dir}")
        print(f"Keyboard shortcuts enabled (try: Mod4+c for CORE GUI)")
        print()


def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        config_file = Path(__file__).parent / "theme-config.yaml"
    else:
        config_file = sys.argv[1]

    applicator = ThemeApplicator(config_file)
    applicator.apply_all()


if __name__ == "__main__":
    main()
