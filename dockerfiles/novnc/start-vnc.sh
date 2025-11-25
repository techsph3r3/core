#!/bin/bash
# Start VNC server script for CORE

# Remove any existing VNC lock files
rm -f /tmp/.X*-lock /tmp/.X11-unix/X*

# Start VNC server
vncserver :1 \
    -geometry ${VNC_RESOLUTION:-1920x1080} \
    -depth ${VNC_DEPTH:-24} \
    -localhost no \
    -SecurityTypes VncAuth \
    -AlwaysShared \
    -rfbport 5901

# Follow VNC log
tail -f /root/.vnc/*.log
