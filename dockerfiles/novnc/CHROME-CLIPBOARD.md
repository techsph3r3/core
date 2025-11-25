# Copy-Paste from Chrome to noVNC - Step by Step

## Quick Steps

### Copy FROM Chrome TO CORE (noVNC)

**On your computer (Chrome):**
1. Select and copy any text (Ctrl+C or Cmd+C)
   ```
   Example: 192.168.1.1
   ```

**In Chrome browser at http://localhost:6080:**

2. **Find the sidebar** - Look at the LEFT edge of the noVNC window
   - You'll see a small **triangle/arrow** pointing right `▶`
   - It's a thin bar on the very left edge

3. **Click the arrow** to open the sidebar
   - The sidebar slides out showing icons

4. **Click the clipboard icon** 📋
   - It's the icon that looks like a clipboard/notepad
   - Usually the 3rd or 4th icon from the top

5. **A text box appears** - This is the clipboard panel

6. **Click inside the text box** and paste (Ctrl+V or Cmd+V)
   - Your copied text appears in the box

**Inside CORE/noVNC:**

7. **Click anywhere in the CORE window** to focus it

8. **Paste** using one of these:
   - **Ctrl+V** (in GUI applications)
   - **Shift+Insert** (in terminals)
   - **Right-click → Paste** (in some applications)

### Copy FROM CORE TO Chrome

**Inside CORE:**

1. Select any text and copy it (Ctrl+C)

**In noVNC:**

2. Open the sidebar (click arrow on left)

3. Click clipboard icon 📋

4. **The text you copied should automatically appear** in the clipboard panel

5. **Click in the text box**, select all (Ctrl+A) and copy (Ctrl+C)

**On your computer:**

6. Paste anywhere (Ctrl+V) - the text is now on your clipboard!

## Visual Guide

```
┌─────────────────────────────────────────────┐
│ ▶ <- Click this arrow                      │
│                                             │
│   [noVNC Session Running Here]             │
│                                             │
│                                             │
└─────────────────────────────────────────────┘

After clicking arrow:
┌────┬────────────────────────────────────────┐
│ ◀  │ [noVNC Session]                       │
│ 📋 │                                        │
│ ⚙️ │                                        │
│ ⛶  │                                        │
└────┴────────────────────────────────────────┘
     ↑
     Click the clipboard icon (📋)

Then:
┌────┬────────────────────────────────────────┐
│ ◀  │ ┌─ Clipboard ─────────────┐           │
│ 📋 │ │                          │           │
│ ⚙️ │ │  [Paste text here]      │           │
│ ⛶  │ │                          │           │
│    │ └──────────────────────────┘           │
└────┴────────────────────────────────────────┘
```

## Detailed Chrome Instructions

### First Time Setup

1. **Open Chrome**
2. **Go to:** `http://localhost:6080`
3. **Connect:**
   - Click "Connect" button
   - Enter password: `core123`
   - Click "Send Password"

4. **You should see:** CORE GUI running in the browser

5. **Look for the sidebar:**
   - On the very **left edge** of the browser window
   - A small arrow or tab
   - If you don't see it, **move your mouse to the left edge**
   - It should appear when you hover

### Every Time You Copy-Paste

**To paste INTO noVNC:**
```
Your Computer: Copy text (Ctrl+C)
      ↓
noVNC: Sidebar → Clipboard → Paste in box
      ↓
CORE: Click in window, press Ctrl+V or Shift+Insert
```

**To copy FROM noVNC:**
```
CORE: Select text, Ctrl+C
      ↓
noVNC: Sidebar → Clipboard → Text appears
      ↓
noVNC: Select and copy from clipboard box
      ↓
Your Computer: Paste (Ctrl+V)
```

## Common Issues

### Issue: "I don't see the sidebar arrow"

**Solution:**
1. Move your mouse to the **very left edge** of the browser window
2. The arrow should appear when you hover
3. If still not visible:
   - Press **F11** to exit fullscreen, then try again
   - Zoom out (Ctrl+-) to see more of the interface
   - Refresh the page (F5)

### Issue: "I clicked the arrow but nothing happens"

**Solution:**
1. Make sure you clicked the **triangle/arrow** on the left edge
2. Try clicking it again - it might toggle
3. Refresh the page (F5) and try again
4. Check browser console (F12) for errors

### Issue: "The clipboard icon doesn't work"

**Solution:**
1. Make sure the sidebar is open (arrow clicked)
2. Look for the icon that looks like a notepad/clipboard
3. It might be the 3rd or 4th icon
4. Try each icon until you find the clipboard panel

### Issue: "Text doesn't paste in CORE"

**Solutions:**
- **In terminals:** Use **Shift+Insert** instead of Ctrl+V
- **In terminals:** Use **Ctrl+Shift+V**
- **Try middle-click** (if you have a 3-button mouse)
- **Make sure you clicked** in the CORE window after using clipboard panel

### Issue: "Paste is blank or wrong text"

**Solution:**
1. Copy the text again on your computer
2. Make sure you pasted in the noVNC clipboard panel
3. Wait 1-2 seconds after pasting in the clipboard panel
4. Then paste in CORE

## Testing Copy-Paste

### Test 1: Simple Text

1. On your computer, copy this: `TEST123`
2. In noVNC sidebar → clipboard → paste
3. In CORE, open any text editor
4. Press Ctrl+V
5. Should see: `TEST123`

### Test 2: IP Address

1. Copy this on your computer: `10.0.0.1`
2. NoVNC clipboard panel → paste
3. In CORE, right-click a node → "Configure"
4. Click in IP address field
5. Paste (Ctrl+V)
6. Should see: `10.0.0.1`

### Test 3: Terminal

1. Copy this: `ip addr show`
2. NoVNC clipboard → paste
3. In CORE, open terminal on a node
4. Paste with **Shift+Insert**
5. Should see: `ip addr show`
6. Press Enter to run command

## Browser Permissions

Chrome may ask for clipboard permissions:

1. **Allow clipboard access** when prompted
2. If not prompted, check:
   - Chrome settings (chrome://settings/content/clipboard)
   - Make sure localhost is allowed
3. Grant permission and refresh the page

## Alternative: Type Instead

If clipboard still doesn't work:

1. **Type manually** (for short text)
2. **Use a text file in Docker:**
   ```bash
   # On your computer
   echo "your text" > /tmp/mytext.txt
   docker cp /tmp/mytext.txt core-novnc:/tmp/

   # In CORE
   cat /tmp/mytext.txt
   ```

## Success Checklist

✓ Can access http://localhost:6080
✓ Can see CORE GUI in browser
✓ Can find sidebar arrow on left edge
✓ Can open sidebar by clicking arrow
✓ Can see clipboard icon in sidebar
✓ Can open clipboard panel
✓ Can paste text in clipboard panel
✓ Can paste in CORE with Ctrl+V or Shift+Insert

## Still Not Working?

If none of this works:

1. **Check autocutsel is running:**
   ```bash
   docker exec core-novnc ps aux | grep autocutsel
   ```
   Should show 2 processes

2. **Restart the container:**
   ```bash
   docker restart core-novnc
   ```
   Wait 30 seconds, then try again

3. **Check noVNC console:**
   - In Chrome, press F12
   - Go to Console tab
   - Look for errors
   - Screenshot and share if needed

4. **Try Firefox** as alternative browser
