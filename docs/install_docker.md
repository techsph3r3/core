# Install Docker

## Overview

CORE can be installed into and ran from a Docker container. This section will cover how you can build and run
CORE from a Docker based image.

## Build Image

You can leverage one of the provided Dockerfiles to build a CORE based image. Since CORE nodes will leverage software
available within the system for a given use case, make sure to update and build the Dockerfile with desired software.

The example Dockerfiles are not meant to be an end all solution, but a solid starting point for running CORE.

Provided Dockerfiles:

* Dockerfile.emane-python - Build EMANE python bindings for use in files below
* Dockerfile.rocky - Rocky Linux 8, CORE from latest package, OSPF MDR, and EMANE
* Dockerfile.ubuntu - Ubuntu 22.04, CORE from latest package, OSPF MDR, and EMANE

```shell
# clone core
git clone https://github.com/coreemu/core.git
cd core
# first you must build EMANE python bindings
sudo docker build -t emane-python -f dockerfiles/Dockerfile.emane-python .
# build desired CORE image, OSPF is a build stage dependency within the file
sudo docker build -t core -f dockerfiles/<Dockerfile> .
```

## Run Container

There are some required parameters when starting a CORE based Docker container for CORE to function properly. These
are shown below in the run command.

```shell
# start container into the background and run the core-daemon by default
sudo docker run -itd --name core -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --privileged --init --entrypoint /opt/core/venv/bin/core-daemon core
# enable xhost access to the root user, this will allow you to run the core-gui from the container
xhost +local:root
# launch core-gui from the running container launched previously
sudo docker exec -it core core-gui
```

## Web-Based GUI with noVNC

For remote access or environments where X11 forwarding is not available, you can use the noVNC setup to access the CORE GUI through a web browser.

### Build noVNC Image

```shell
# clone core
git clone https://github.com/coreemu/core.git
cd core
# build the noVNC-enabled CORE image
sudo docker build -t core-novnc -f dockerfiles/Dockerfile.novnc .
```

### Run with Docker Compose (Recommended)

```shell
cd dockerfiles
docker-compose -f docker-compose.novnc.yml up -d
```

### Run with Docker

```shell
sudo docker run -d \
  --name core-novnc \
  --privileged \
  --init \
  -p 6080:6080 \
  -p 5901:5901 \
  -p 50051:50051 \
  -e VNC_RESOLUTION=1920x1080 \
  -e VNC_DEPTH=24 \
  --cap-add NET_ADMIN \
  --cap-add SYS_ADMIN \
  core-novnc:latest
```

### Access the GUI

1. Open your web browser to: `http://localhost:6080`
2. Click "Connect"
3. Enter the default password: `core123`
4. The CORE GUI will be running in the browser

### Quick Start Script

A convenience script is provided for easy management:

```shell
cd dockerfiles/novnc

# Build the image
./build-and-run.sh build

# Start the container
./build-and-run.sh start

# View logs
./build-and-run.sh logs

# Stop the container
./build-and-run.sh stop
```

### Features

- **Web-based access**: Access CORE GUI from any modern web browser
- **No X11 required**: Works without X11 forwarding or display configuration
- **Remote access**: Easy access from remote machines
- **VNC compatibility**: Also supports native VNC clients on port 5901
- **Auto-start**: CORE daemon and GUI start automatically
- **Persistent data**: Configuration and topologies can be persisted with volumes

### Ports

- **6080**: noVNC web interface (HTTP)
- **5901**: VNC server (for native VNC clients)
- **50051**: CORE gRPC API

### Configuration

Default VNC password is `core123`. To change it, modify the Dockerfile before building:

```dockerfile
RUN echo "your_password" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd
```

For detailed documentation, see [dockerfiles/novnc/README.md](../dockerfiles/novnc/README.md).
