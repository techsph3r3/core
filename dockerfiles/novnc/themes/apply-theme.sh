#!/bin/bash
# CORE Network Laboratory - Theme Application Wrapper
# Easy-to-use script for applying themes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/apply-theme.py"
DEFAULT_CONFIG="$SCRIPT_DIR/theme-config.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║         CORE Network Laboratory - Theme Applicator                ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Error: python3 not found${NC}"
    echo "Please install Python 3"
    exit 1
fi

# Check for PyYAML
if ! python3 -c "import yaml" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  PyYAML not installed${NC}"
    echo "Installing PyYAML..."
    pip3 install pyyaml || {
        echo -e "${RED}❌ Failed to install PyYAML${NC}"
        echo "Please run: pip3 install pyyaml"
        exit 1
    }
fi

# Determine which config to use
CONFIG_FILE="${1:-$DEFAULT_CONFIG}"

if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Error: Configuration file not found: $CONFIG_FILE${NC}"
    echo ""
    echo "Available preset themes:"
    for preset in "$SCRIPT_DIR"/preset-*.yaml; do
        if [ -f "$preset" ]; then
            echo "  - $(basename "$preset")"
        fi
    done
    echo ""
    echo "Usage: $0 [config-file.yaml]"
    echo "  Example: $0 preset-light.yaml"
    exit 1
fi

# Show which theme we're applying
THEME_NAME=$(grep "name:" "$CONFIG_FILE" | head -1 | cut -d'"' -f2)
echo -e "${GREEN}📦 Applying theme: $THEME_NAME${NC}"
echo ""

# Run the Python script
python3 "$PYTHON_SCRIPT" "$CONFIG_FILE"

# Success
echo -e "${GREEN}✨ Theme application complete!${NC}"
echo ""
echo "Quick actions:"
echo "  • Restart Fluxbox: fluxbox-remote restart"
echo "  • Edit theme: nano $CONFIG_FILE"
echo "  • Apply again: $0"
echo ""
