import Foundation

final class MockEvenSessionManager: EvenSessionManaging, ObservableObject {
    @Published private(set) var state: EvenSessionState = .disconnected
    private(set) var lastPayload: G2DisplayPayload?
    private var connectionTask: Task<Void, Never>?

    func connect() async {
        guard case .disconnected = state else { return }

        state = .connecting

        // Simulate connection delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)

        // Randomly succeed or fail (mostly succeed)
        if Int.random(in: 0...10) < 8 {
            state = .connected(deviceName: "Even G2")
        } else {
            state = .failed(reason: "Could not find glasses. Make sure they're powered on and nearby.")
        }
    }

    func disconnect() async {
        connectionTask?.cancel()
        state = .disconnected
        lastPayload = nil
    }

    func send(payload: G2DisplayPayload) async throws {
        guard case .connected = state else {
            throw EvenSessionError.notConnected
        }
        lastPayload = payload
        // Simulate transmission delay
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    func clearDisplay() async throws {
        guard case .connected = state else {
            throw EvenSessionError.notConnected
        }
        lastPayload = nil
    }

    func simulateDisconnect() {
        state = .disconnected
    }
}

enum EvenSessionError: Error {
    case notConnected
    case transmissionFailed
    case deviceNotFound
}
