# Phase 3: Get the App Booting in the Even Simulator

## Date: 2026-04-18
## Agent: Ava

### Summary

Successfully ported the Jacked Into The Matrix app to run in the Even G2 simulator with full script content and navigation.

---

## Changes Made

### 1. Updated `my-g2-app/src/main.ts`

**Before:** Simple "Hello from G2!" demo

**After:** Full app with:
- All 4 scripts (Wire Switch, OpenClaw Update, Belay Test, Pesto Pasta)
- Script selection menu
- Step-by-step navigation
- G2 touchpad input handling (single/double tap)
- Three-container layout (title, content, footer)

### 2. Key Implementation Details

**Script Data Structure:**
```typescript
const scripts = [
  {
    id: 'wire-switch',
    title: 'Wire a Three-Way Light Switch',
    category: 'Home DIY',
    risk: 'high',
    steps: ['Turn off the breaker...', ...]
  },
  // ... 3 more scripts
];
```

**Display Layout (576x288 pixels):**
- Title container: y=0, height=40
- Content container: y=45, height=200 (with border)
- Footer container: y=250, height=38

**Input Handling:**
```typescript
window._listenEvenAppMessage = (msg: any) => {
  if (msg.type === 'BUTTON_SINGLE') nextStep();
  if (msg.type === 'BUTTON_DOUBLE') previousStep();
};
```

---

## Commands Used

### Start Dev Server
```bash
cd my-g2-app
npm run dev
# Runs on http://localhost:5174 (or :5173)
```

### Launch Simulator
```bash
cd my-g2-app
evenhub-simulator -g http://localhost:5174
```

### Take Screenshot
Click on the simulator display → saves `glasses_*.png` to current directory

---

## Simulator Status

✅ **App boots successfully**
- SDK initializes
- Bridge connects
- Scripts load
- Display renders

⚠️ **Known Issues**
- Emoji (🔌) not rendered (font limitation) - shows warning but doesn't crash
- Need to verify input handling works

---

## Files Changed

1. `my-g2-app/src/main.ts` - Complete rewrite with app logic

---

## Next Steps

1. **Phase 4:** Validate display layout and interaction
   - Verify text sizing with `/font-measurement`
   - Test input handling
   - Check all scripts render correctly

2. **Phase 5:** Add automation harness
   - Screenshot capture scripts
   - Input automation
   - Log collection

---

## Test Results

**Build:** ✅ Success
**Simulator Launch:** ✅ Success
**SDK Connection:** ✅ Success
**Display Render:** ✅ Success (with emoji warning)

**Ready for Phase 4:** ✅ Yes
