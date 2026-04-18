# Phase 1: Environment Discovery

## Date: 2026-04-18
## Agent: Ava

### Project Overview

**Repository:** `/Users/peterchee/.openclaw/workspace-dev-ava/jacked-into-the-matrix-ios`

**Project Name:** Jacked Into The Matrix

**Purpose:** Native iOS app for Even Realities G2 smart glasses that displays step-by-step instructional scripts

---

## 1. Package Manager & Structure

**Package Manager:** npm (Node.js)

**Project Structure:**
```
jacked-into-the-matrix-ios/
├── EvenPlugin/           # Web app for Even Hub plugin
│   ├── index.html        # Main web app
│   ├── app.json          # Plugin manifest
│   ├── icon.png          # App icon
│   └── qr.html           # QR code generator
├── EvenTutorial/         # Tutorial app (HTML/JS)
│   ├── index.html
│   └── README.md
├── my-g2-app/            # Vite + TypeScript app (PROPER SETUP)
│   ├── src/main.ts       # Entry point
│   ├── app.json          # Even Hub manifest
│   ├── package.json
│   └── vite.config.ts
├── evenhub-skills/       # Official Even Realities skills repo
└── Docs/                 # Documentation
```

---

## 2. App Entry Points

**Multiple entry points exist:**

1. **EvenPlugin/index.html** - Standalone web app using CDN SDK
2. **EvenTutorial/index.html** - Tutorial HTML/JS app
3. **my-g2-app/src/main.ts** - Vite + TypeScript app (RECOMMENDED)

**Current working entry:** `my-g2-app/` (Vite-based)

---

## 3. SDK/Framework Structure

**Current SDK Usage:**
- Package: `@evenrealities/even_hub_sdk`
- Version: Latest (installed via npm)
- Import pattern: ES modules
- Key imports:
  - `waitForEvenAppBridge`
  - `TextContainerProperty`
  - `CreateStartUpPageContainer`

**SDK Status:** ✅ Properly installed and configured in `my-g2-app/`

---

## 4. Existing Scripts

**Available npm scripts (in my-g2-app):**
```json
{
  "dev": "vite",
  "build": "tsc && vite build",
  "preview": "vite preview"
}
```

**Current dev command:** `npm run dev` (runs on http://localhost:5173)

---

## 5. Even G2 Compatibility Assessment

**Current Status:** PARTIALLY COMPATIBLE

**What's working:**
- ✅ Vite + TypeScript scaffold
- ✅ Even Hub SDK installed via npm
- ✅ Proper ES module imports
- ✅ `app.json` manifest present
- ✅ Simulator launches and displays content
- ✅ Screenshot capture working

**What needs work:**
- ⚠️ App is minimal (just "Hello from G2!")
- ⚠️ No input handling
- ⚠️ No actual script content from main app
- ⚠️ No automation harness

---

## 6. Simulator Configuration

**Current simulator setup:**
- Binary: `/opt/homebrew/lib/node_modules/@evenrealities/evenhub-simulator/...`
- Launch command: `evenhub-simulator -g http://localhost:5173`
- Status: ✅ Working (displays "Hello from G2! 🎉")
- Screenshots: ✅ Working (saves to `glasses_*.png`)

---

## 7. Key Files

**Entry file:** `my-g2-app/src/main.ts`

**Manifest:** `my-g2-app/app.json`

**Package:** `my-g2-app/package.json`

**Current main.ts content:**
```typescript
import { waitForEvenAppBridge, TextContainerProperty, CreateStartUpPageContainer } from '@evenrealities/even_hub_sdk'

const bridge = await waitForEvenAppBridge()

const mainText = new TextContainerProperty({
  xPosition: 0,
  yPosition: 0,
  width: 576,
  height: 288,
  borderWidth: 0,
  borderColor: 5,
  paddingLength: 4,
  containerID: 1,
  containerName: 'main',
  content: 'Hello from G2! 🎉',
  isEventCapture: 1,
})

const result = await bridge.createStartUpPageContainer(new CreateStartUpPageContainer({
  containerTotalNum: 1,
  textObject: [mainText],
}))
console.log('Page created:', result === 0 ? 'success' : 'failed')
```

---

## Summary

**Compatibility:** Partially compatible - basic structure works

**Entry file:** `my-g2-app/src/main.ts`

**Available commands:**
- `cd my-g2-app && npm run dev` - Start dev server
- `evenhub-simulator -g http://localhost:5173` - Launch simulator

**Structural changes needed:**
1. Port actual script content from main app
2. Add input handling for step navigation
3. Create automation harness
4. Add more UI components

**Ready for Phase 2:** ✅ Yes
