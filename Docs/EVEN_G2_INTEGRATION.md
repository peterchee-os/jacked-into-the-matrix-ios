# Even G2 Integration Guide

This document describes the Even G2 glasses integration for Jacked Into The Matrix.

## Overview

The app connects to Even Realities G2 glasses via Bluetooth Low Energy (BLE) to display step-by-step instructions. The integration is implemented in `EvenG2SessionManager.swift` using CoreBluetooth.

## Configuration

All BLE UUIDs and parameters are centralized in `EvenG2Configuration.swift`.

### UUIDs to Update

When you receive the official Even G2 SDK documentation, update these values in `EvenG2Configuration.swift`:

```swift
// Service UUID
static let mainServiceUUID = CBUUID(string: "ACTUAL-UUID-HERE")

// Characteristic UUIDs
static let displayCharacteristicUUID = CBUUID(string: "ACTUAL-UUID-HERE")
static let inputCharacteristicUUID = CBUUID(string: "ACTUAL-UUID-HERE")
static let configCharacteristicUUID = CBUUID(string: "ACTUAL-UUID-HERE")
static let statusCharacteristicUUID = CBUUID(string: "ACTUAL-UUID-HERE")
```

### Device Identification

Update the expected device name prefixes:

```swift
static let deviceNamePrefixes = [
    "Even G2",      // Update if different
    "EVEN-G2",      // Alternative naming
]
```

Update the manufacturer ID (if applicable):

```swift
static let manufacturerID: UInt16 = 0xXXXX // Replace with actual ID
```

## Protocol

### Outgoing (iPhone → Glasses)

The app sends binary payloads with this structure:

| Byte | Description |
|------|-------------|
| 0 | Protocol version (0x01) |
| 1 | Command type (0x01 = display text) |
| 2-3 | Step index (uint16, little endian) |
| 4-5 | Total steps (uint16, little endian) |
| 6 | Mode ('s' = stepByStep, 'c' = continuous, 'd' = drill) |
| 7 | Title length |
| 8... | Title text (UTF-8) |
| n | Primary text length (low byte) |
| n+1 | Primary text length (high byte) |
| n+2... | Primary text (UTF-8) |
| m | Secondary text length (0 if none) |
| m+1... | Secondary text (UTF-8, optional) |

### Incoming (Glasses → iPhone)

The app receives input events:

| Byte | Event |
|------|-------|
| 0x01 | Single button press (Next) |
| 0x02 | Double button press (Previous) |
| 0x03 | Long button press |
| 0x10 | Swipe up |
| 0x11 | Swipe down |
| 0x12 | Swipe left |
| 0x13 | Swipe right |

## Testing

### Simulator

On the iOS Simulator, the app uses `MockEvenSessionManager` which simulates:
- Connection delays
- Random connection failures
- Payload sending

### Physical Device

On a physical iPhone, the app uses `EvenG2SessionManager` which:
- Scans for Even G2 devices
- Connects via BLE
- Sends real display data
- Receives button input

## Permissions

The app requires Bluetooth permissions. These are declared in `Info.plist`:

- `NSBluetoothAlwaysUsageDescription` - For iOS 13+
- `NSBluetoothPeripheralUsageDescription` - For older iOS versions

## Debugging

Enable verbose logging in debug builds:

```swift
// In EvenG2Configuration.swift
static let verboseLogging = true
```

This logs:
- Discovered devices
- Connection events
- Sent/received data
- Errors

## Known Limitations

1. **UUIDs are placeholders** - Replace with actual values from Even Realities SDK
2. **Protocol is assumed** - Update binary format if different from specification
3. **No encryption** - Add if required by Even G2 protocol
4. **No authentication** - Add pairing flow if required

## Next Steps

1. Obtain official Even G2 SDK documentation
2. Update UUIDs in `EvenG2Configuration.swift`
3. Update protocol format if needed
4. Test with real Even G2 hardware
5. Add encryption/authentication if required
