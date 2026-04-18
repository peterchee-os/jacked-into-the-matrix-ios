# Even Hub Plugin Guide

## Overview

To display content on Even G2 glasses, we need to build a web app plugin that runs inside the Even Hub app.

## Architecture

```
[Even Hub App] <-- WebView --> [Your Plugin HTML/JS] <-- BLE --> [G2 Glasses]
```

## Steps to Create Plugin

### 1. Build Web App

Create an HTML file that uses the Even SDK:

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jacked Into The Matrix</title>
    <script src="https://unpkg.com/@evenrealities/even_hub_sdk@latest/dist/index.umd.js"></script>
</head>
<body>
    <div id="app">
        <h1>Select a Script</h1>
        <div id="scripts"></div>
    </div>
    
    <script>
        // Your scripts data
        const scripts = [
            {
                title: "Wire a Three-Way Light Switch",
                steps: ["Turn off breaker", "Check power", "Connect wires"]
            },
            // ... more scripts
        ];
        
        // Initialize Even SDK
        const { waitForEvenAppBridge } = window.EvenHubSDK;
        
        waitForEvenAppBridge().then(bridge => {
            console.log('Connected to G2 glasses');
            
            // Display first step
            bridge.displayText({
                title: scripts[0].title,
                text: scripts[0].steps[0],
                step: 1,
                total: scripts[0].steps.length
            });
            
            // Handle input from glasses
            window._listenEvenAppMessage = (msg) => {
                if (msg.type === 'BUTTON_SINGLE') {
                    // Next step
                } else if (msg.type === 'BUTTON_DOUBLE') {
                    // Previous step
                }
            };
        });
    </script>
</body>
</html>
```

### 2. Create app.json Manifest

```json
{
  "name": "Jacked Into The Matrix",
  "bundleId": "com.thinkspace.jackedintothematrix",
  "version": "1.0.0",
  "entry": "index.html",
  "icon": "icon.png",
  "permissions": ["microphone", "storage"]
}
```

### 3. Package as .ehpk

Using the Even Hub CLI:

```bash
# Install CLI
npm install -g @evenrealities/evenhub-cli

# Package the app
evenhub pack app.json dist -o jackedintothematrix.ehpk
```

### 4. Generate QR Code for Sideloading

Host the .ehpk file on a server, then:

```bash
# Generate QR code pointing to the download URL
evenhub qr https://yourserver.com/jackedintothematrix.ehpk
```

Or use any QR generator with the URL.

### 5. Install on G2

1. Open Even Hub app on iPhone
2. Tap "Add Plugin" or "Sideload"
3. Scan the QR code
4. The plugin installs and runs

## Alternative: Development Mode

For development, you can run locally:

```bash
# Install simulator
npm install -g @evenrealities/evenhub-simulator

# Run your app
evenhub-simulator http://localhost:3000
```

This opens a simulator where you can test without glasses.

## Resources

- Even SDK: https://www.npmjs.com/package/@evenrealities/even_hub_sdk
- CLI: https://www.npmjs.com/package/@evenrealities/evenhub-cli
- Docs: https://hub.evenrealities.com/docs
