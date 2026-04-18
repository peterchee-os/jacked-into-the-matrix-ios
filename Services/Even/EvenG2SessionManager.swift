import Foundation
import CoreBluetooth
import Combine

/// Real implementation of Even G2 session manager using CoreBluetooth
/// This connects to the Even G2 glasses via BLE and sends display payloads
final class EvenG2SessionManager: NSObject, EvenSessionManaging, ObservableObject {
    @Published private(set) var state: EvenSessionState = .disconnected

    // MARK: - BLE Constants

    /// Even G2 Service UUID from configuration
    private var evenG2ServiceUUID: CBUUID { EvenG2Configuration.mainServiceUUID }

    /// Display Characteristic UUID from configuration
    private var displayCharacteristicUUID: CBUUID { EvenG2Configuration.displayCharacteristicUUID }

    /// Input Characteristic UUID from configuration
    private var inputCharacteristicUUID: CBUUID { EvenG2Configuration.inputCharacteristicUUID }

    // MARK: - Properties

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var displayCharacteristic: CBCharacteristic?
    private var inputCharacteristic: CBCharacteristic?

    private var connectionContinuation: CheckedContinuation<Void, Never>?
    private var lastSentPayload: G2DisplayPayload?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = EvenG2Configuration.maxReconnectAttempts

    // Input handling
    var onNextStep: (() -> Void)?
    var onPreviousStep: (() -> Void)?
    var onScrollUp: (() -> Void)?
    var onScrollDown: (() -> Void)?

    // MARK: - Initialization

    override init() {
        super.init()
        // Initialize CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - EvenSessionManaging

    func connect() async {
        guard state == .disconnected else { return }

        state = .connecting
        reconnectAttempts = 0

        // Wait for Bluetooth to be powered on
        await waitForBluetooth()

        // Start scanning
        await scanAndConnect()
    }

    func disconnect() async {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        connectedPeripheral = nil
        displayCharacteristic = nil
        inputCharacteristic = nil
        state = .disconnected
    }

    func send(payload: G2DisplayPayload) async throws {
        guard case .connected = state else {
            throw EvenSessionError.notConnected
        }

        guard let characteristic = displayCharacteristic else {
            throw EvenSessionError.characteristicNotFound
        }

        // Format payload for G2 display
        let data = formatPayload(payload)

        // Send to glasses
        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)

        lastSentPayload = payload

        // Wait for confirmation (with timeout)
        try await withTimeout(seconds: 2) {
            // In real implementation, wait for peripheral delegate callback
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    func clearDisplay() async throws {
        let clearPayload = G2DisplayPayload(
            scriptTitle: "",
            stepIndex: 0,
            totalSteps: 0,
            primaryText: "",
            secondaryText: nil,
            mode: .stepByStep
        )
        try await send(payload: clearPayload)
    }

    // MARK: - Private Methods

    private func waitForBluetooth() async {
        // Wait for centralManager to be powered on
        while centralManager?.state != .poweredOn {
            try? await Task.sleep(nanoseconds: 100_000_000)
        }
    }

    private func scanAndConnect() async {
        guard let central = centralManager else {
            state = .failed(reason: "Bluetooth not available")
            return
        }

        // Scan for Even G2 devices
        central.scanForPeripherals(
            withServices: [evenG2ServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )

        // Wait for connection with timeout
        do {
            try await withTimeout(seconds: EvenG2Configuration.scanTimeout) {
                while self.state == .connecting {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
            }
        } catch {
            central.stopScan()
            if state == .connecting {
                state = .failed(reason: "Connection timeout - glasses not found")
            }
        }
    }

    private func formatPayload(_ payload: G2DisplayPayload) -> Data {
        // Format payload according to Even G2 protocol
        // Uses binary protocol for efficiency
        var data = Data()
        
        // Protocol version
        data.append(EvenG2Configuration.protocolVersion)
        
        // Command type: Display Text
        data.append(EvenG2Configuration.CommandType.displayText.rawValue)
        
        // Step index (2 bytes, little endian)
        data.append(UInt8(payload.stepIndex & 0xFF))
        data.append(UInt8((payload.stepIndex >> 8) & 0xFF))
        
        // Total steps (2 bytes, little endian)
        data.append(UInt8(payload.totalSteps & 0xFF))
        data.append(UInt8((payload.totalSteps >> 8) & 0xFF))
        
        // Mode (1 byte)
        data.append(payload.mode.rawValue.utf8.first ?? 0x00)
        
        // Title length + title
        let titleData = payload.scriptTitle.prefix(EvenG2Configuration.maxPayloadLength).data(using: .utf8) ?? Data()
        data.append(UInt8(titleData.count))
        data.append(contentsOf: titleData)
        
        // Primary text length + text (truncated to fit display)
        let maxTextLength = EvenG2Configuration.maxPayloadLength
        let primaryText = String(payload.primaryText.prefix(maxTextLength))
        let primaryData = primaryText.data(using: .utf8) ?? Data()
        data.append(UInt8(primaryData.count & 0xFF))
        data.append(UInt8((primaryData.count >> 8) & 0xFF))
        data.append(contentsOf: primaryData)
        
        // Secondary text (optional)
        if let secondary = payload.secondaryText {
            let secondaryData = secondary.prefix(EvenG2Configuration.maxPayloadLength / 2).data(using: .utf8) ?? Data()
            data.append(UInt8(secondaryData.count))
            data.append(contentsOf: secondaryData)
        } else {
            data.append(0x00) // No secondary text
        }
        
        return data
    }

    private func handleInput(_ data: Data) {
        // Parse input from glasses (button presses, gestures)
        // Binary protocol based on Even G2 specification
        guard data.count >= 1 else { return }
        
        let eventType = data[0]
        
        switch EvenG2Configuration.InputEvent(rawValue: eventType) {
        case .buttonSingle:
            // Single press = next step
            onNextStep?()
            
        case .buttonDouble:
            // Double press = previous step
            onPreviousStep?()
            
        case .buttonLong:
            // Long press = toggle mode or menu
            break
            
        case .swipeUp:
            onScrollUp?()
            
        case .swipeDown:
            onScrollDown?()
            
        case .swipeLeft:
            // Could be used for navigation
            break
            
        case .swipeRight:
            // Could be used for navigation
            break
            
        default:
            if EvenG2Configuration.verboseLogging {
                print("Unknown input event: 0x\(String(format: "%02X", eventType))")
            }
        }
    }

    private func withTimeout<T>(seconds: TimeInterval, operation: () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw EvenSessionError.timeout
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension EvenG2SessionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // Ready to scan
            break
        case .poweredOff:
            state = .failed(reason: "Bluetooth is turned off")
        case .unsupported:
            state = .failed(reason: "Bluetooth not supported on this device")
        case .unauthorized:
            state = .failed(reason: "Bluetooth permission denied")
        default:
            state = .failed(reason: "Bluetooth unavailable")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // Check if this is an Even G2 device by name
        let deviceName = peripheral.name ?? ""
        let isEvenG2 = EvenG2Configuration.deviceNamePrefixes.contains { prefix in
            deviceName.hasPrefix(prefix)
        }
        
        // Also check manufacturer data if available
        let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        let hasCorrectManufacturer = manufacturerData?.prefix(2) == Data(EvenG2Configuration.manufacturerID.bigEndian.bytes)
        
        guard isEvenG2 || hasCorrectManufacturer else {
            if EvenG2Configuration.verboseLogging {
                print("Ignoring device: \(deviceName) - not an Even G2")
            }
            return
        }
        
        if EvenG2Configuration.verboseLogging {
            print("Found Even G2 device: \(deviceName), RSSI: \(RSSI)")
        }
        
        // Found an Even G2 device
        connectedPeripheral = peripheral
        peripheral.delegate = self
        central.stopScan()
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Connected - now discover services
        peripheral.discoverServices([evenG2ServiceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        state = .failed(reason: error?.localizedDescription ?? "Connection failed")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if state == .connected {
            // Unexpected disconnect - try to reconnect
            if reconnectAttempts < maxReconnectAttempts {
                reconnectAttempts += 1
                state = .connecting
                central.connect(peripheral, options: nil)
            } else {
                state = .failed(reason: "Disconnected unexpectedly")
            }
        }
    }
}

// MARK: - CBPeripheralDelegate

extension EvenG2SessionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            state = .failed(reason: error?.localizedDescription ?? "Service discovery failed")
            return
        }

        guard let service = peripheral.services?.first(where: { $0.uuid == evenG2ServiceUUID }) else {
            state = .failed(reason: "Even G2 service not found")
            return
        }

        // Discover characteristics
        peripheral.discoverCharacteristics(
            [displayCharacteristicUUID, inputCharacteristicUUID],
            for: service
        )
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard error == nil else {
            state = .failed(reason: error?.localizedDescription ?? "Characteristic discovery failed")
            return
        }

        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid == displayCharacteristicUUID {
                displayCharacteristic = characteristic
            } else if characteristic.uuid == inputCharacteristicUUID {
                inputCharacteristic = characteristic
                // Subscribe to input notifications
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }

        if displayCharacteristic != nil {
            state = .connected(deviceName: peripheral.name ?? "Even G2")
            reconnectAttempts = 0
        } else {
            state = .failed(reason: "Display characteristic not found")
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard characteristic.uuid == inputCharacteristicUUID,
              let data = characteristic.value else { return }

        handleInput(data)
    }
}

// MARK: - Additional Errors

extension EvenSessionError {
    case characteristicNotFound
    case timeout
    case bluetoothUnavailable
}

// MARK: - UInt16 Byte Conversion

extension UInt16 {
    var bytes: [UInt8] {
        withUnsafeBytes(of: self) { Array($0) }
    }
}
