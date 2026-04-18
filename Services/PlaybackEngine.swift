import Foundation

final class PlaybackEngine: ObservableObject {
    @Published private(set) var playbackState: PlaybackState?

    func start(script: Script, mode: PlaybackMode) {
        playbackState = PlaybackState(
            scriptID: script.id,
            currentStepIndex: 0,
            mode: mode,
            completedStepIndices: [],
            lastSyncedToGlassesAt: nil,
            startedAt: Date(),
            updatedAt: Date()
        )
    }

    func next(totalSteps: Int) {
        guard var state = playbackState else { return }
        state.completedStepIndices.insert(state.currentStepIndex)
        state.currentStepIndex = min(state.currentStepIndex + 1, max(0, totalSteps - 1))
        state.updatedAt = Date()
        playbackState = state
    }

    func previous() {
        guard var state = playbackState else { return }
        state.currentStepIndex = max(0, state.currentStepIndex - 1)
        state.updatedAt = Date()
        playbackState = state
    }

    func setMode(_ mode: PlaybackMode) {
        guard var state = playbackState else { return }
        state.mode = mode
        state.updatedAt = Date()
        playbackState = state
    }
}
