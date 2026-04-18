# Implementation Notes

## Project Setup

This is a Swift iOS project for Xcode. To open:
1. Open `JackedIntoTheMatrix.xcodeproj` in Xcode 15+
2. Build target: iOS 17.0+
3. Run on iPhone simulator or device

Or create the Xcode project fresh:
```bash
# Option 1: Use xcodegen (if installed)
xcodegen generate

# Option 2: Create new project in Xcode, add existing files
# File → New → Project → iOS App
# Then drag the folders (App, Models, Services, Features, Core, Resources, Prompts) into Xcode
```

## Primary principles
- Keep V1 local-first
- Phone owns logic, glasses render compact steps
- High-risk scripts require review before playback
- Gemma 4 E2B is the default local model route
- Fallback must be explicit and observable in debug state

## Immediate tasks
- Stand up models and repositories
- Get the seed scripts loading
- Build a mock playback loop on phone
- Define and test G2 display payload sizing
- Add validator before model integration
- Create proper Xcode project file
