import Foundation

struct PlaybackState: Codable, Hashable {
    var scriptID: UUID
    var currentStepIndex: Int
    var mode: PlaybackMode
    var completedStepIndices: Set<Int>
    var lastSyncedToGlassesAt: Date?
    var startedAt: Date?
    var updatedAt: Date
}
