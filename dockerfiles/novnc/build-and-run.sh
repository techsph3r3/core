#!/bin/bash
# Build and run CORE with noVNC
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "=================================="
echo "CORE with noVNC - Build and Run"
echo "=================================="
echo ""

# Function to check if container exists
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -q "^core-novnc$"
}

# Function to check if container is running
container_running() {
    docker ps --format '{{.Names}}' | grep -q "^core-novnc$"
}

# Parse command line arguments
ACTION="${1:-start}"

case "$ACTION" in
    build)
        echo "Building CORE noVNC image..."
        cd "$CORE_ROOT"
        docker build -f dockerfiles/Dockerfile.novnc -t core-novnc:latest .
        echo ""
        echo "Building CORE node base image..."
        docker build -f dockerfiles/Dockerfile.core-node -t core-node:latest .
        echo ""
        echo "Build complete!"
        echo "Images built:"
        echo "  - core-novnc:latest (main container)"
        echo "  - core-node:latest (for Docker nodes in CORE)"
        echo ""
        echo "Run './build-and-run.sh start' to start the container"
        ;;

    start)
        echo "Starting CORE with noVNC..."

        # Check if container exists
        if container_exists; then
            if container_running; then
                echo "Container is already running!"
            else
                echo "Starting existing container..."
                docker start core-novnc
            fi
        else
            echo "Creating and starting new container..."
            docker run -d \
                --name core-novnc \
                --privileged \
                --init \
                --pid=host \
                -p 6080:6080 \
                -p 5901:5901 \
                -p 50051:50051 \
                -e VNC_RESOLUTION=1920x1080 \
                -e VNC_DEPTH=24 \
                -v /var/run/docker.sock:/var/run/docker.sock \
                --cap-add NET_ADMIN \
                --cap-add SYS_ADMIN \
                core-novnc:latest
        fi

        echo ""
        echo "Waiting for services to start..."
        sleep 5

        echo ""
        echo "=================================="
        echo "CORE is ready!"
        echo "=================================="
        echo ""
        echo "Access CORE GUI via web browser:"
        echo "  URL: http://localhost:6080"
        echo "  Password: core123"
        echo ""
        echo "Or use a native VNC client:"
        echo "  Server: localhost:5901 (or localhost:1)"
        echo "  Password: core123"
        echo ""
        echo "CORE gRPC API:"
        echo "  Endpoint: localhost:50051"
        echo ""
        echo "To view logs: docker logs -f core-novnc"
        echo "To stop: ./build-and-run.sh stop"
        ;;

    stop)
        echo "Stopping CORE..."
        if container_running; then
            docker stop core-novnc
            echo "Container stopped"
        else
            echo "Container is not running"
        fi
        ;;

    restart)
        echo "Restarting CORE..."
        $0 stop
        sleep 2
        $0 start
        ;;

    logs)
        echo "Showing logs (Ctrl+C to exit)..."
        docker logs -f core-novnc
        ;;

    shell)
        echo "Opening shell in container..."
        docker exec -it core-novnc /bin/bash
        ;;

    remove)
        echo "Removing CORE container..."
        if container_exists; then
            if container_running; then
                docker stop core-novnc
            fi
            docker rm core-novnc
            echo "Container removed"
        else
            echo "Container does not exist"
        fi
        ;;

    compose-up)
        echo "Starting CORE with Docker Compose..."
        cd "$SCRIPT_DIR/.."
        docker-compose -f docker-compose.novnc.yml up -d
        echo ""
        echo "CORE is starting..."
        echo "Access at: http://localhost:6080"
        echo "Password: core123"
        ;;

    compose-down)
        echo "Stopping CORE Docker Compose..."
        cd "$SCRIPT_DIR/.."
        docker-compose -f docker-compose.novnc.yml down
        echo "Stopped"
        ;;

    *)
        echo "Usage: $0 {build|start|stop|restart|logs|shell|remove|compose-up|compose-down}"
        echo ""
        echo "Commands:"
        echo "  build        - Build the Docker image"
        echo "  start        - Start CORE container (default)"
        echo "  stop         - Stop CORE container"
        echo "  restart      - Restart CORE container"
        echo "  logs         - Show container logs"
        echo "  shell        - Open bash shell in container"
        echo "  remove       - Remove CORE container"
        echo "  compose-up   - Start using Docker Compose"
        echo "  compose-down - Stop Docker Compose"
        exit 1
        ;;
esac
