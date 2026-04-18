import Foundation

final class MockEvenSessionManager: EvenSessionManaging, ObservableObject {
    @Published private(set) var state: EvenSessionState = .disconnected
    private(set) var lastPayload: G2DisplayPayload?

    func connect() async {
        state = .connecting
        state = .connected(deviceName: "Mock Even G2")
    }

    func disconnect() async {
        state = .disconnected
        lastPayload = nil
    }

    func send(payload: G2DisplayPayload) async throws {
        lastPayload = payload
    }

    func clearDisplay() async throws {
        lastPayload = nil
    }
}
