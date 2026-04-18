import Foundation

struct G2DisplayPayload: Codable, Hashable {
    var scriptTitle: String
    var stepIndex: Int
    var totalSteps: Int
    var primaryText: String
    var secondaryText: String?
    var mode: PlaybackMode
}
