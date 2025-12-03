# Micro:bit Web Serial Guide

This guide provides instructions on how to read sensor data from a BBC Micro:bit directly in a web browser using the [Web Serial API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Serial_API). This approach allows for direct communication without needing a middleware server or Python bridge.

## 1. Prerequisites

### Browser Support
*   **Chrome**, **Edge**, or **Opera** (Chromium-based browsers).
*   **Firefox** and **Safari** do **NOT** currently support Web Serial.
*   The page must be served over **HTTPS** or be on **localhost**.

### Micro:bit Firmware
*   The Micro:bit acts as a serial device over USB.
*   Ensure the Micro:bit is connected via a data-capable USB cable.

## 2. Micro:bit Code (Sender)

The Micro:bit needs to send data over the serial connection. You can use MakeCode or MicroPython.

### Option A: MakeCode (Blocks/JavaScript)
1.  Go to [makecode.microbit.org](https://makecode.microbit.org/).
2.  Use the `Serial` category.
3.  Use `serial write line` to send data.
4.  **Important**: Send data as a JSON string or a comma-separated value for easier parsing.

**Example (JavaScript):**
```javascript
basic.forever(function () {
    // Send accelerometer data as JSON
    let data = "{\"x\":" + input.acceleration(Dimension.X) + 
               ", \"y\":" + input.acceleration(Dimension.Y) + 
               ", \"z\":" + input.acceleration(Dimension.Z) + "}"
    serial.writeLine(data)
    basic.pause(100)
})
```

### Option B: MicroPython
```python
from microbit import *
import json

while True:
    x = accelerometer.get_x()
    y = accelerometer.get_y()
    z = accelerometer.get_z()
    
    # Create JSON object
    data = {"x": x, "y": y, "z": z}
    
    # Print sends a line to serial
    print(json.dumps(data))
    sleep(100)
```

## 3. Web Application (Receiver)

To read this data in a web app (e.g., React), you need to:
1.  Request access to the port (`navigator.serial.requestPort`).
2.  Open the port (`port.open`).
3.  Set up a read loop with a `TextDecoder` and a stream transformer (to handle line breaks).

### React Implementation Example

Here is a complete React component pattern for reading Micro:bit data.

```jsx
import React, { useState, useRef, useEffect } from 'react';

const MicrobitReader = () => {
  const [data, setData] = useState(null);
  const [isConnected, setIsConnected] = useState(false);
  const portRef = useRef(null);
  const readerRef = useRef(null);
  const keepReadingRef = useRef(false);

  const connect = async () => {
    if (!("serial" in navigator)) {
      alert("Web Serial API not supported in this browser.");
      return;
    }

    try {
      // 1. Request a port (User must select the Micro:bit)
      const port = await navigator.serial.requestPort({
        filters: [{ usbVendorId: 0x0d28 }] // Micro:bit Vendor ID
      });
      
      // 2. Open the port
      await port.open({ baudRate: 115200 }); // Standard Micro:bit baud rate
      
      portRef.current = port;
      setIsConnected(true);
      keepReadingRef.current = true;

      // 3. Start reading
      readLoop(port);
    } catch (err) {
      console.error("Error connecting:", err);
    }
  };

  const readLoop = async (port) => {
    const textDecoder = new TextDecoderStream();
    const readableStreamClosed = port.readable.pipeTo(textDecoder.writable);
    const reader = textDecoder.readable.getReader();
    readerRef.current = reader;

    let buffer = "";

    try {
      while (keepReadingRef.current) {
        const { value, done } = await reader.read();
        if (done) {
          break; // Stream closed
        }
        if (value) {
          buffer += value;
          // Process complete lines
          const lines = buffer.split('\n');
          // The last part is incomplete, keep it in buffer
          buffer = lines.pop(); 

          for (const line of lines) {
            handleData(line.trim());
          }
        }
      }
    } catch (error) {
      console.error("Read error:", error);
    } finally {
      reader.releaseLock();
    }
  };

  const handleData = (line) => {
    if (!line) return;
    try {
      // Assuming JSON data like {"x": 100, "y": 200}
      const parsed = JSON.parse(line);
      setData(parsed);
    } catch (e) {
      console.log("Raw data:", line);
    }
  };

  const disconnect = async () => {
    keepReadingRef.current = false;
    
    if (readerRef.current) {
      await readerRef.current.cancel();
      readerRef.current = null;
    }
    
    if (portRef.current) {
      await portRef.current.close();
      portRef.current = null;
    }
    
    setIsConnected(false);
  };

  return (
    <div className="p-4 border rounded bg-gray-900 text-white">
      <h2 className="text-xl mb-4">Micro:bit Sensor Bridge</h2>
      
      {!isConnected ? (
        <button 
          onClick={connect}
          className="bg-blue-600 px-4 py-2 rounded hover:bg-blue-500"
        >
          Connect Micro:bit
        </button>
      ) : (
        <button 
          onClick={disconnect}
          className="bg-red-600 px-4 py-2 rounded hover:bg-red-500"
        >
          Disconnect
        </button>
      )}

      <div className="mt-4">
        <h3 className="font-bold">Live Data:</h3>
        <pre className="bg-black p-2 rounded mt-2">
          {data ? JSON.stringify(data, null, 2) : "No data received yet..."}
        </pre>
      </div>
    </div>
  );
};

export default MicrobitReader;
```

## 4. Key Implementation Details

1.  **Vendor ID Filter**: The `usbVendorId: 0x0d28` filter helps the browser show only Micro:bit devices in the selection dialog.
2.  **Baud Rate**: Must match the Micro:bit's baud rate (default is usually `115200`).
3.  **Line Parsing**: Serial data arrives in chunks, not perfect lines. You **must** buffer the data and split by `\n` to get complete messages.
4.  **Cleanup**: Web Serial ports lock the stream. You must properly cancel the reader and close the port to reconnect without refreshing the page.

## 5. Troubleshooting

*   **"Access Denied"**: The port might be open in another tab or by another application (like a slicer or serial monitor). Close other apps.
*   **No Device Found**: Ensure you have the correct USB drivers (if on Windows 7/8) and the cable transfers data (some are power-only).
*   **Garbage Data**: Check if the `baudRate` matches the Micro:bit code.
