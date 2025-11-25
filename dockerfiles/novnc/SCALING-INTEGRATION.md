# noVNC Local Scaling - Integration Guide

## What This Does

Enables **local scaling by default** in noVNC, so the remote desktop automatically scales to fit the browser window without manual configuration.

## Current Status

✅ **Applied to running container** - Refresh your browser to see the effect
✅ **Script created** for future Docker builds

## Benefits

- 🖥️ Desktop automatically fits your browser window
- 📱 Works on any screen size (desktop, laptop, tablet)
- 🔄 Scales dynamically when you resize the browser
- 👍 No manual configuration needed each session

## For Future Docker Builds

### Option 1: Direct sed command in Dockerfile

Add to `dockerfiles/Dockerfile.novnc` after noVNC installation:

```dockerfile
# Enable local scaling by default in noVNC
RUN sed -i 's/<option value="scale">Local scaling<\/option>/<option value="scale" selected>Local scaling<\/option>/' \
    /opt/noVNC/vnc.html
```

### Option 2: Use the provided script (Recommended)

Add to `dockerfiles/Dockerfile.novnc`:

```dockerfile
# Enable local scaling in noVNC
COPY dockerfiles/novnc/enable-scaling.sh /opt/
RUN chmod +x /opt/enable-scaling.sh && /opt/enable-scaling.sh && rm /opt/enable-scaling.sh
```

## Testing

1. Build/start container
2. Access noVNC: http://localhost:6080
3. Connect to VNC
4. Desktop should automatically scale to fit browser
5. Resize browser window - desktop scales accordingly

## Reverting (if needed)

To disable default scaling:

```bash
# In running container
docker exec core-novnc bash -c "cp /opt/noVNC/vnc.html.backup /opt/noVNC/vnc.html"
```

Or manually change in noVNC settings:
- Click settings icon (left sidebar)
- Scaling mode: Select "None"

## Technical Details

**File modified:** `/opt/noVNC/vnc.html`
**Change:** Added `selected` attribute to the "Local scaling" option
**Backup:** Original saved as `/opt/noVNC/vnc.html.backup`

## Scaling Options in noVNC

| Mode | Description | Use Case |
|------|-------------|----------|
| **Local scaling** (default) | Scales view in browser | Best for most users, any screen size |
| None | No scaling, 1:1 pixels | When exact pixel matching needed |
| Remote resizing | Changes resolution on server | Advanced use, changes VNC resolution |

---

**Status:** ✅ Implemented and ready to use
**Integration:** Ready for Dockerfile
**Tested:** Yes, in running container
