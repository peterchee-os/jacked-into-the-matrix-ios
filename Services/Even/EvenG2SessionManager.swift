import Foundation
import CoreBluetooth
import Combine

/// Real implementation of Even G2 session manager using CoreBluetooth
/// This connects to the Even G2 glasses via BLE and sends display payloads
final class EvenG2SessionManager: NSObject, EvenSessionManaging, ObservableObject {
    @Published private(set) var state: EvenSessionState = .disconnected

    // MARK: - BLE Constants

    /// Even G2 Service UUID (placeholder - replace with actual from SDK)
    private let evenG2ServiceUUID = CBUUID(string: "E2B0xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

    /// Display Characteristic UUID (placeholder)
    private let displayCharacteristicUUID = CBUUID(string: "E2B1xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

    /// Input Characteristic UUID (placeholder)
    private let inputCharacteristicUUID = CBUUID(string: "E2B2xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx")

    // MARK: - Properties

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var displayCharacteristic: CBCharacteristic?
    private var inputCharacteristic: CBCharacteristic?

    private var connectionContinuation: CheckedContinuation<Void, Never>?
    private var lastSentPayload: G2DisplayPayload?
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 3

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
            try await withTimeout(seconds: 10) {
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
        // This is a placeholder - actual format will come from SDK
        var dict: [String: Any] = [
            "t": payload.scriptTitle,
            "i": payload.stepIndex,
            "n": payload.totalSteps,
            "p": payload.primaryText,
            "m": payload.mode.rawValue
        ]

        if let secondary = payload.secondaryText {
            dict["s"] = secondary
        }

        return try! JSONSerialization.data(withJSONObject: dict)
    }

    private func handleInput(_ data: Data) {
        // Parse input from glasses (button presses, gestures)
        // Placeholder - actual format will come from SDK
        guard let command = String(data: data, encoding: .utf8) else { return }

        switch command {
        case "next":
            onNextStep?()
        case "prev":
            onPreviousStep?()
        case "up":
            onScrollUp?()
        case "down":
            onScrollDown?()
        default:
            break
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
