# Jacked Into The Matrix - Even G2 Plugin

## Quick Start

### Option 1: Direct HTML (Fastest)

1. Host `index.html` on any web server (GitHub Pages, Netlify, Vercel, etc.)
2. Open the URL in Safari on your iPhone
3. Tap Share → "Open in Even Hub" (if available)

### Option 2: Package as .ehpk (Recommended)

1. **Install Even Hub CLI:**
   ```bash
   npm install -g @evenrealities/evenhub-cli
   ```

2. **Package the plugin:**
   ```bash
   cd EvenPlugin
   evenhub pack app.json . -o jackedintothematrix.ehpk
   ```

3. **Host the .ehpk file:**
   - Upload to any web server
   - Or use GitHub Releases
   - Get a direct download URL

4. **Generate QR Code:**
   ```bash
   evenhub qr https://yourserver.com/jackedintothematrix.ehpk
   ```
   
   Or use any online QR generator with your URL.

5. **Install on G2:**
   - Open Even Hub app
   - Tap "Add Plugin" or "Sideload"
   - Scan the QR code
   - Plugin installs and runs

### Option 3: Local Development

1. **Install simulator:**
   ```bash
   npm install -g @evenrealities/evenhub-simulator
   ```

2. **Run locally:**
   ```bash
   cd EvenPlugin
   python3 -m http.server 8000
   evenhub-simulator http://localhost:8000
   ```

## Features

- 4 built-in scripts (Electrical, CLI, Climbing, Cooking)
- Step-by-step navigation
- G2 touchpad controls (single tap = next, double tap = previous)
- Progress tracking
- Risk level indicators

## Files

- `index.html` - Main web app
- `app.json` - Plugin manifest
- `README.md` - This file

## Support

For issues with the Even SDK or G2 glasses, contact Even Realities support.
For issues with this plugin, check the GitHub repository.
