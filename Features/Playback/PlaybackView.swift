import SwiftUI

struct PlaybackView: View {
    let script: Script
    let state: PlaybackState?

    var body: some View {
        let step = state.flatMap { script.steps[safe: $0.currentStepIndex] }

        List {
            Section("Progress") {
                Text("\((state?.currentStepIndex ?? 0) + 1) / \(script.steps.count)")
            }

            Section("Current Step") {
                Text(step?.text ?? "No step loaded")
            }
        }
        .navigationTitle("Playback")
    }
}
