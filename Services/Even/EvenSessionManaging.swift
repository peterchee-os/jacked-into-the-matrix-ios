import Foundation

enum EvenSessionState: Equatable {
    case disconnected
    case connecting
    case connected(deviceName: String?)
    case failed(reason: String)
}

protocol EvenSessionManaging {
    var state: EvenSessionState { get }
    func connect() async
    func disconnect() async
    func send(payload: G2DisplayPayload) async throws
    func clearDisplay() async throws
}
