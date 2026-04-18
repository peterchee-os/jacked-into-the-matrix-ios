# Even G2 Tutorial - My First App

Following the official Even Realities tutorial: https://hub.evenrealities.com/docs/getting-started/first-app

## Setup

### 1. Install Even Hub Simulator
```bash
npm install -g @evenrealities/evenhub-simulator
```

### 2. Start the development server
```bash
cd EvenTutorial
python3 -m http.server 5173
```

### 3. Run the simulator
```bash
evenhub-simulator http://localhost:5173
```

This should open a native window showing the G2 glasses display simulator.

## What This App Does

1. **Initialize SDK**: Waits for the Even App Bridge to connect
2. **Create Text Container**: Uses `TextContainerProperty` to create a text display
3. **Display on Glasses**: Calls `createStartUpPageContainer()` to show content

## Key SDK Concepts

### Initialize the Bridge
```javascript
import { waitForEvenAppBridge } from '@evenrealities/even_hub_sdk'
const bridge = await waitForEvenAppBridge()
```

### Create a Container
```javascript
const { TextContainerProperty } = window.EvenHubSDK;

const textContainer = new TextContainerProperty({
    xPosition: 0,
    yPosition: 0,
    width: 576,        // G2 display width
    height: 288,       // G2 display height
    borderWidth: 0,
    borderColor: 5,
    paddingLength: 4,
    containerID: 1,
    containerName: 'main',
    content: 'Hello from G2! 🎉',
    isEventCapture: 1,
});
```

### Display on Glasses
```javascript
const result = await bridge.createStartUpPageContainer(1, [textContainer])
// result: 0 = success, 1 = invalid, 2 = oversize, 3 = out of memory
```

## G2 Display Specs

- **Resolution**: 576 x 288 pixels
- **Color**: Monochrome (green on black)
- **Input**: Touchpads on temples (single tap, double tap, swipe)

## Important: SDK Only Works in Even Hub Environment

**The Even SDK is NOT available in regular browsers!** It only works when:
1. Running inside the Even Hub Simulator
2. Running as a plugin inside the Even Hub app

The `<script>` tag loads a placeholder - the actual SDK is injected by the Even Hub runtime.

### Testing in Browser (without SDK)
If you open `http://localhost:5173` in Safari/Chrome, you'll see:
- ❌ "Even SDK not found" error
- This is **expected** - the SDK isn't injected

### Testing in Simulator (with SDK)
Run the simulator and load the URL:
```bash
evenhub-simulator http://localhost:5173
```
The simulator injects the SDK and you should see:
- ✅ "Connected to G2 glasses!"
- Button becomes enabled

## Troubleshooting

If the simulator doesn't open:
1. Check it's installed: `which evenhub-simulator`
2. Try opening the binary directly: 
   ```bash
   open /opt/homebrew/lib/node_modules/@evenrealities/evenhub-simulator/node_modules/@evenrealities/sim-darwin-arm64/bin/evenhub-simulator
   ```
3. Check for errors in terminal output
4. **Make sure you're viewing the app IN the simulator, not a regular browser**

## Next Steps

- Learn about [Display & UI System](https://hub.evenrealities.com/docs/guides/display)
- Understand [Input & Events](https://hub.evenrealities.com/docs/guides/input-events)
- Read [Design Guidelines](https://hub.evenrealities.com/docs/guides/design-guidelines)
