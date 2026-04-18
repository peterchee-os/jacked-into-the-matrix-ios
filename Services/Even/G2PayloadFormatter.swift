import Foundation

enum G2PayloadFormatter {
    static func makePayload(
        script: Script,
        stepIndex: Int,
        mode: PlaybackMode,
        maxPrimaryTextCharacters: Int = 80,
        maxSecondaryTextCharacters: Int = 40
    ) -> G2DisplayPayload? {
        guard let step = script.steps[safe: stepIndex] else { return nil }

        let primary = String(step.text.prefix(maxPrimaryTextCharacters))
        let secondarySource = step.warning ?? step.tip
        let secondary = secondarySource.map { String($0.prefix(maxSecondaryTextCharacters)) }

        return G2DisplayPayload(
            scriptTitle: String(script.title.prefix(24)),
            stepIndex: stepIndex + 1,
            totalSteps: script.steps.count,
            primaryText: primary,
            secondaryText: secondary,
            mode: mode
        )
    }
}
