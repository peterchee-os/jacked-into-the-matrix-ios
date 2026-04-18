# Development Setup

## Initial Setup

### 1. Install Dependencies

```bash
# Install xcodegen if not already installed
brew install xcodegen
```

### 2. Generate Xcode Project

```bash
xcodegen generate
```

### 3. Configure Code Signing (Important!)

The project uses automatic code signing. You need to set your Apple Development Team:

**Option A: Via Xcode (Recommended)**
1. Open `JackedIntoTheMatrix.xcodeproj` in Xcode
2. Select the project in the navigator
3. Go to "Signing & Capabilities" tab
4. Select your Team from the dropdown
5. Xcode will automatically manage signing

**Option B: Via project.local.yml**
1. Copy `project.local.yml` to your own local version:
   ```bash
   cp project.local.yml project.local.yml
   ```
2. Edit `project.local.yml` and add your Team ID:
   ```yaml
   targets:
     JackedIntoTheMatrix:
       settings:
         base:
           DEVELOPMENT_TEAM: "ABCD123456"  # Your 10-character Team ID
   ```
3. Generate project with local settings:
   ```bash
   xcodegen generate --spec project.yml --spec project.local.yml
   ```

**Finding Your Team ID:**
- Log in to https://developer.apple.com/account
- Go to "Membership" - your Team ID is listed there
- Or check in Xcode → Preferences → Accounts

### 4. Build and Run

```bash
# Build for simulator
xcodebuild -project JackedIntoTheMatrix.xcodeproj -scheme JackedIntoTheMatrix -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Or build for device (requires signing setup)
xcodebuild -project JackedIntoTheMatrix.xcodeproj -scheme JackedIntoTheMatrix -destination 'platform=iOS,name=Your iPhone' build
```

## Regenerating the Project

When you pull changes that affect the project structure:

```bash
xcodegen generate
```

**Note:** Code signing settings in Xcode will be preserved if you use the Xcode GUI method. If you use `project.local.yml`, include it in the generate command.

## Troubleshooting

### "Signing requires a development team"

Follow step 3 above to configure code signing.

### "Could not find target"

Regenerate the project:
```bash
xcodegen generate
```

### Changes to project.yml not reflected

You must regenerate the project after editing `project.yml`:
```bash
xcodegen generate
```

## Project Structure

- `project.yml` - Main project configuration (committed to git)
- `project.local.yml` - Local settings template (committed)
- `project.local.yml` - Your local settings (gitignored)
- `JackedIntoTheMatrix.xcodeproj` - Generated Xcode project (gitignored)
