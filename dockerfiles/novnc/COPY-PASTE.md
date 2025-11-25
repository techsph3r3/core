# Copy-Paste Guide for noVNC

This guide explains how to copy and paste text between your local computer (running the browser) and the CORE noVNC session.

## How It Works

The noVNC session includes clipboard synchronization that allows you to:
- Copy text from your computer → Paste into CORE/VNC
- Copy text from CORE/VNC → Paste on your computer

**Technical Details:**
- `autocutsel` synchronizes X11 clipboards with VNC
- noVNC provides clipboard integration in the browser
- Supports both CLIPBOARD (Ctrl+C/V) and PRIMARY (middle-click) selections

## Using Copy-Paste

### Method 1: noVNC Clipboard Panel (Recommended)

**Copy FROM your computer TO noVNC:**

1. **Copy text on your computer** (Ctrl+C or Cmd+C)
2. **In the browser**, click the **sidebar arrow** on the left side of noVNC
3. Click the **clipboard icon** 📋
4. **Paste into the text box** (Ctrl+V or Cmd+V)
5. The text is now in the noVNC clipboard
6. **Inside CORE**, paste normally:
   - **Ctrl+V** in most applications
   - **Shift+Insert** in terminals
   - **Middle-click** to paste PRIMARY selection

**Copy FROM noVNC TO your computer:**

1. **Inside CORE**, select and copy text:
   - **Ctrl+C** to copy
   - Or just select text (for PRIMARY selection)
2. **In the browser**, click the **sidebar arrow**
3. Click the **clipboard icon** 📋
4. The copied text should appear in the text box
5. **Select and copy** the text from the box (Ctrl+A, Ctrl+C)
6. **Paste on your computer** (Ctrl+V or Cmd+V)

### Method 2: Using Ctrl+Alt+Shift (Alternative)

Some browsers support direct clipboard access:

1. **Copy on your computer** (Ctrl+C)
2. **In noVNC**, press **Ctrl+Alt+Shift**
3. A clipboard dialog may appear
4. **Paste** (Ctrl+V)
5. Click OK
6. Now paste in CORE with Ctrl+V

### Method 3: Terminal Copy-Paste (Linux-style)

In Linux terminals and many X11 applications:

**Copy:**
- Select text with mouse → automatically copied to PRIMARY selection

**Paste:**
- **Middle-click** (or Shift+Insert) → pastes PRIMARY selection
- **Ctrl+Shift+V** → pastes CLIPBOARD in most terminals

## Step-by-Step Example

### Example: Copy IP Address from Computer to CORE

**On your computer:**
```
10.0.0.1
```

1. Select and copy "10.0.0.1" (Ctrl+C)
2. Open noVNC in browser (http://localhost:6080)
3. Click sidebar arrow (left edge)
4. Click clipboard icon 📋
5. Paste in the clipboard text box (Ctrl+V)
6. In CORE, open a terminal on a node
7. Paste the IP address (Ctrl+V or Shift+Insert)
8. The IP address appears: `10.0.0.1`

### Example: Copy Command Output from CORE to Computer

**In CORE:**

1. Open terminal on a node
2. Run: `ip addr show eth0`
3. Select the output with mouse
4. Press Ctrl+C to copy
5. In noVNC sidebar → clipboard icon 📋
6. Text appears in clipboard box
7. Select all (Ctrl+A) and copy (Ctrl+C)
8. On your computer, paste (Ctrl+V)

## Tips and Best Practices

### For Best Results

1. **Use the noVNC clipboard panel** - Most reliable method
2. **Keep clipboard panel open** - Easier to monitor clipboard content
3. **Copy small amounts** - Large text may have delays
4. **Use plain text** - No formatting, images, or rich text
5. **Wait for sync** - Give it a second after pasting

### Terminal Copy-Paste

**In xterm/terminal windows inside CORE:**

**Copy:**
- Select text with mouse
- Then: Ctrl+Shift+C (or just middle-click elsewhere to paste)

**Paste:**
- Ctrl+Shift+V (CLIPBOARD)
- Shift+Insert (CLIPBOARD)
- Middle-click (PRIMARY selection)

### Application-Specific

**CORE GUI:**
- Standard Ctrl+C / Ctrl+V works in text fields
- Right-click → Copy/Paste in some dialogs

**Text Editors (vim, nano):**
- **vim**: Use `"+p` to paste from system clipboard
- **nano**: Ctrl+Shift+V or Shift+Insert

**Web browsers in CORE:**
- Standard Ctrl+C / Ctrl+V

## Troubleshooting

### Clipboard Not Working

**Problem:** Can't paste from computer to CORE

**Solutions:**

1. **Use the noVNC clipboard panel** (sidebar → clipboard icon)
2. **Check autocutsel is running:**
   ```bash
   docker exec core-novnc ps aux | grep autocutsel
   ```
   Should show two autocutsel processes

3. **Restart VNC session:**
   ```bash
   docker restart core-novnc
   ```

### Text Not Appearing in Clipboard Panel

**Problem:** Copied text in CORE doesn't show in noVNC clipboard panel

**Solutions:**

1. **Make sure you pressed Ctrl+C** after selecting text
2. **Try selecting text again** and copy explicitly
3. **Use middle-click paste** as alternative (works with selection)
4. **Check browser console** for JavaScript errors

### Paste Not Working in Terminal

**Problem:** Ctrl+V doesn't paste in terminal

**Solutions:**

1. **Use Ctrl+Shift+V** instead (terminal standard)
2. **Or use Shift+Insert**
3. **Or use middle-click** (mouse button 2)
4. **For vim:** Use `"+p` to paste from clipboard

### Large Text Issues

**Problem:** Copying large amounts of text is slow or fails

**Solutions:**

1. **Copy smaller chunks** - Break into multiple pastes
2. **Use file transfer** instead - See alternatives below
3. **Paste incrementally** - Wait between pastes

## Alternative Methods for Large Data

For larger amounts of data, consider:

### Using File Upload (if available)

Some applications support drag-and-drop or file upload.

### Using Network Transfer

1. **Start a simple HTTP server on your computer:**
   ```bash
   python3 -m http.server 8000
   ```

2. **In CORE, download file:**
   ```bash
   wget http://<your-ip>:8000/file.txt
   ```

### Using Docker Volume

1. **Copy file into Docker volume:**
   ```bash
   docker cp myfile.txt core-novnc:/tmp/
   ```

2. **Access in CORE:**
   ```bash
   cat /tmp/myfile.txt
   ```

## Security Considerations

- Clipboard is shared between browser and VNC session
- Don't paste sensitive data (passwords) if others can see your screen
- Browser may ask permission to access clipboard
- VNC traffic is not encrypted by default (use SSH tunnel for production)

## Browser Compatibility

**Fully Supported:**
- Chrome/Chromium
- Firefox
- Edge
- Safari (macOS/iOS)

**Clipboard API Support:**
- Modern browsers support HTML5 Clipboard API
- Older browsers may require user interaction

## Keyboard Shortcuts Summary

### On Your Computer
- **Copy:** Ctrl+C (Windows/Linux) or Cmd+C (Mac)
- **Paste:** Ctrl+V (Windows/Linux) or Cmd+V (Mac)

### In noVNC
- **Open clipboard panel:** Click sidebar arrow → clipboard icon
- **Send clipboard to VNC:** Paste in clipboard panel
- **Get clipboard from VNC:** Copy from clipboard panel

### Inside CORE (VNC Session)
- **Copy:** Ctrl+C (GUI apps) or Ctrl+Shift+C (terminal)
- **Paste:** Ctrl+V (GUI apps) or Ctrl+Shift+V (terminal)
- **Alternative paste:** Shift+Insert or middle-click

## Additional Resources

- [noVNC Documentation](https://github.com/novnc/noVNC/blob/master/docs/EMBEDDING.md)
- [X11 Clipboard Explained](https://specifications.freedesktop.org/clipboards-spec/clipboards-latest.txt)
- [TigerVNC Documentation](https://tigervnc.org/)
