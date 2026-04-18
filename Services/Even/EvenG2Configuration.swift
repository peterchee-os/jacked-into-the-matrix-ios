import Foundation
import CoreBluetooth

/// Even G2 BLE UUID Configuration
/// Update these values when you receive the official SDK documentation
enum EvenG2Configuration {
    
    // MARK: - Service UUIDs
    
    /// Main Even G2 Service UUID
    /// This is the primary service for all G2 communications
    static let mainServiceUUID = CBUUID(string: "E2B00000-0000-0000-0000-000000000000")
    
    /// Alternative service UUIDs to try (some firmware versions may use different UUIDs)
    static let alternativeServiceUUIDs: [CBUUID] = [
        // Add alternative UUIDs here as they're discovered
        // CBUUID(string: "..."),
    ]
    
    // MARK: - Characteristic UUIDs
    
    /// Display/Write Characteristic
    /// Used to send display data from iPhone to G2 glasses
    static let displayCharacteristicUUID = CBUUID(string: "E2B00001-0000-0000-0000-000000000000")
    
    /// Input/Notify Characteristic
    /// Used to receive button presses and gestures from G2 glasses
    static let inputCharacteristicUUID = CBUUID(string: "E2B00002-0000-0000-0000-000000000000")
    
    /// Configuration Characteristic
    /// Used to configure display settings (brightness, font size, etc.)
    static let configCharacteristicUUID = CBUUID(string: "E2B00003-0000-0000-0000-000000000000")
    
    /// Status Characteristic
    /// Used to read battery level, connection quality, etc.
    static let statusCharacteristicUUID = CBUUID(string: "E2B00004-0000-0000-0000-000000000000")
    
    // MARK: - Device Identification
    
    /// Expected device name prefix for Even G2 glasses
    /// Used to filter scan results (e.g., "Even G2", "EVEN-G2", etc.)
    static let deviceNamePrefixes = [
        "Even G2",
        "EVEN-G2",
        "EvenG2",
        "G2",
    ]
    
    /// Manufacturer ID for Even Realities
    /// Used to validate manufacturer data in advertisement packets
    static let manufacturerID: UInt16 = 0x0000 // Replace with actual ID
    
    // MARK: - Connection Parameters
    
    /// Scan timeout in seconds
    static let scanTimeout: TimeInterval = 15.0
    
    /// Connection timeout in seconds
    static let connectionTimeout: TimeInterval = 10.0
    
    /// Maximum reconnection attempts
    static let maxReconnectAttempts = 3
    
    /// Delay between reconnection attempts (seconds)
    static let reconnectDelay: TimeInterval = 2.0
    
    // MARK: - Display Parameters
    
    /// Maximum characters per line on G2 display
    static let maxCharsPerLine = 40
    
    /// Maximum lines per screen on G2 display
    static let maxLinesPerScreen = 4
    
    /// Maximum total characters per payload
    static let maxPayloadLength = 160
    
    /// Default display brightness (0-100)
    static let defaultBrightness: UInt8 = 70
    
    /// Default font size (1-5, where 1 is smallest)
    static let defaultFontSize: UInt8 = 2
    
    // MARK: - Protocol Version
    
    /// Protocol version for payload format
    static let protocolVersion: UInt8 = 1
}

// MARK: - Payload Format

extension EvenG2Configuration {
    
    /// Command types for G2 communication
    enum CommandType: UInt8 {
        case displayText = 0x01
        case clearDisplay = 0x02
        case setBrightness = 0x03
        case setFontSize = 0x04
        case getStatus = 0x05
        case vibrate = 0x06
    }
    
    /// Input event types from G2
    enum InputEvent: UInt8 {
        case buttonSingle = 0x01
        case buttonDouble = 0x02
        case buttonLong = 0x03
        case swipeUp = 0x10
        case swipeDown = 0x11
        case swipeLeft = 0x12
        case swipeRight = 0x13
    }
}

// MARK: - Debug Configuration

#if DEBUG
extension EvenG2Configuration {
    /// Enable verbose logging for BLE operations
    static let verboseLogging = true
    
    /// Simulate glasses connection for testing (without real hardware)
    static let simulateConnection = false
    
    /// Simulated latency for testing (seconds)
    static let simulatedLatency: TimeInterval = 0.5
}
#else
extension EvenG2Configuration {
    static let verboseLogging = false
    static let simulateConnection = false
    static let simulatedLatency: TimeInterval = 0
}
#endif
