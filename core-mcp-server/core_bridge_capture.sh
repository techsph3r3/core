#!/bin/bash
# CORE Bridge Capture Utility
# Discovers network bridges in CORE and provides easy capture commands

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

DOCKER_HOST="${DOCKER_HOST:-core-novnc}"

show_help() {
    echo -e "${CYAN}CORE Bridge Capture Utility${NC}"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  list              List all CORE network bridges"
    echo "  capture <bridge>  Start capture on a bridge (e.g., b.1.1)"
    echo "  stop <bridge>     Stop capture on a bridge"
    echo "  stop-all          Stop all running captures"
    echo "  status            Show status of running captures"
    echo "  download <file>   Download a capture file from CORE container"
    echo ""
    echo "Options:"
    echo "  -f, --filter      BPF filter (e.g., 'port 1883', 'host 10.0.1.10')"
    echo "  -o, --output      Output file name (default: auto-generated)"
    echo "  -h, --help        Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 capture b.1.1"
    echo "  $0 capture b.1.1 -f 'port 1883'"
    echo "  $0 capture b.1.1 -f 'host 10.0.1.10 and port 80'"
    echo "  $0 stop b.1.1"
    echo "  $0 download /tmp/capture_b_1_1.pcap"
}

list_bridges() {
    echo -e "${CYAN}=== CORE Network Bridges ===${NC}"
    echo ""

    # Get bridges from CORE container
    bridges=$(docker exec "$DOCKER_HOST" ip link show type bridge 2>/dev/null | grep -oE 'b\.[0-9]+\.[0-9]+' | sort -u)

    if [ -z "$bridges" ]; then
        echo -e "${YELLOW}No CORE bridges found. Is a CORE session running?${NC}"
        echo ""
        echo "To start a topology, use the Web UI or run:"
        echo "  docker exec $DOCKER_HOST /opt/core/venv/bin/python3 /tmp/load_topology.py /tmp/topology.xml"
        return 1
    fi

    echo -e "${GREEN}Found bridges:${NC}"
    echo ""

    # Try to get network names from CORE gRPC
    script_content='
import json
from core.api.grpc import client
try:
    core = client.CoreGrpcClient()
    core.connect()
    sessions = core.get_sessions()
    networks = {}
    for s in sessions:
        state = s.state.value if hasattr(s.state, "value") else s.state
        if state == 4:
            session = core.get_session(s.id)
            for nid, node in session.nodes.items():
                nt = node.type.value if hasattr(node.type, "value") else node.type
                if nt in [4, 5, 6]:
                    networks[f"b.{nid}.{s.id}"] = {"name": node.name, "type": "switch" if nt==4 else ("hub" if nt==5 else "wlan")}
    print(json.dumps(networks))
    core.close()
except:
    print("{}")
'

    network_info=$(docker exec "$DOCKER_HOST" /opt/core/venv/bin/python3 -c "$script_content" 2>/dev/null || echo "{}")

    for bridge in $bridges; do
        # Check if capture is running on this bridge
        if docker exec "$DOCKER_HOST" pgrep -f "tcpdump -i $bridge" >/dev/null 2>&1; then
            status="${RED}[CAPTURING]${NC}"
        else
            status="${GREEN}[available]${NC}"
        fi

        # Try to get network name
        name=$(echo "$network_info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$bridge',{}).get('name',''))" 2>/dev/null || echo "")
        ntype=$(echo "$network_info" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$bridge',{}).get('type',''))" 2>/dev/null || echo "")

        if [ -n "$name" ]; then
            echo -e "  ${BLUE}$bridge${NC} - $name ($ntype) $status"
        else
            echo -e "  ${BLUE}$bridge${NC} $status"
        fi
    done

    echo ""
    echo -e "${YELLOW}Quick capture commands:${NC}"
    first_bridge=$(echo "$bridges" | head -1)
    echo "  $0 capture $first_bridge"
    echo "  $0 capture $first_bridge -f 'port 1883'"
}

start_capture() {
    bridge="$1"
    filter="$2"
    output="$3"

    if [ -z "$bridge" ]; then
        echo -e "${RED}Error: Bridge name required${NC}"
        echo "Usage: $0 capture <bridge> [-f filter] [-o output]"
        return 1
    fi

    # Check if already capturing
    if docker exec "$DOCKER_HOST" pgrep -f "tcpdump -i $bridge" >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: Already capturing on $bridge${NC}"
        echo "Stop it first with: $0 stop $bridge"
        return 1
    fi

    # Generate output filename if not provided
    if [ -z "$output" ]; then
        timestamp=$(date +%Y%m%d_%H%M%S)
        output="/tmp/capture_${bridge//./_}_${timestamp}.pcap"
    fi

    echo -e "${CYAN}Starting capture on $bridge...${NC}"

    # Build tcpdump command
    cmd="tcpdump -i $bridge -w $output -s 0"
    if [ -n "$filter" ]; then
        cmd="$cmd $filter"
    fi

    # Start capture in background
    docker exec -d "$DOCKER_HOST" $cmd

    sleep 1

    # Verify it started
    if docker exec "$DOCKER_HOST" pgrep -f "tcpdump -i $bridge" >/dev/null 2>&1; then
        echo -e "${GREEN}Capture started!${NC}"
        echo ""
        echo "  Bridge:  $bridge"
        echo "  File:    $output"
        [ -n "$filter" ] && echo "  Filter:  $filter"
        echo ""
        echo "To stop: $0 stop $bridge"
        echo "To download: $0 download $output"
    else
        echo -e "${RED}Failed to start capture${NC}"
        return 1
    fi
}

stop_capture() {
    bridge="$1"

    if [ -z "$bridge" ]; then
        echo -e "${RED}Error: Bridge name required${NC}"
        return 1
    fi

    echo -e "${CYAN}Stopping capture on $bridge...${NC}"

    docker exec "$DOCKER_HOST" pkill -f "tcpdump -i $bridge" 2>/dev/null || true

    sleep 1

    if docker exec "$DOCKER_HOST" pgrep -f "tcpdump -i $bridge" >/dev/null 2>&1; then
        echo -e "${RED}Failed to stop capture${NC}"
        return 1
    else
        echo -e "${GREEN}Capture stopped${NC}"

        # List capture files
        echo ""
        echo "Capture files:"
        docker exec "$DOCKER_HOST" ls -lh /tmp/capture_${bridge//./_}*.pcap 2>/dev/null || echo "  (none found)"
    fi
}

stop_all() {
    echo -e "${CYAN}Stopping all captures...${NC}"

    docker exec "$DOCKER_HOST" pkill -f "tcpdump -i b\." 2>/dev/null || true

    echo -e "${GREEN}All captures stopped${NC}"
}

show_status() {
    echo -e "${CYAN}=== Active Captures ===${NC}"
    echo ""

    captures=$(docker exec "$DOCKER_HOST" pgrep -af "tcpdump -i b\." 2>/dev/null || echo "")

    if [ -z "$captures" ]; then
        echo -e "${GREEN}No active captures${NC}"
    else
        echo "$captures" | while read -r line; do
            echo -e "  ${RED}$line${NC}"
        done
    fi

    echo ""
    echo -e "${CYAN}=== Capture Files ===${NC}"
    echo ""
    docker exec "$DOCKER_HOST" ls -lh /tmp/capture_*.pcap 2>/dev/null || echo "  No capture files found"
}

download_file() {
    file="$1"

    if [ -z "$file" ]; then
        echo -e "${RED}Error: File path required${NC}"
        return 1
    fi

    local_file="./$(basename "$file")"

    echo -e "${CYAN}Downloading $file...${NC}"

    docker cp "$DOCKER_HOST:$file" "$local_file"

    if [ -f "$local_file" ]; then
        echo -e "${GREEN}Downloaded to: $local_file${NC}"
        ls -lh "$local_file"
    else
        echo -e "${RED}Download failed${NC}"
        return 1
    fi
}

# Parse arguments
COMMAND="${1:-help}"
shift || true

BRIDGE=""
FILTER=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--filter)
            FILTER="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$BRIDGE" ]; then
                BRIDGE="$1"
            fi
            shift
            ;;
    esac
done

case $COMMAND in
    list)
        list_bridges
        ;;
    capture)
        start_capture "$BRIDGE" "$FILTER" "$OUTPUT"
        ;;
    stop)
        stop_capture "$BRIDGE"
        ;;
    stop-all)
        stop_all
        ;;
    status)
        show_status
        ;;
    download)
        download_file "$BRIDGE"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        show_help
        exit 1
        ;;
esac
