import Foundation

protocol ModelRouting {
    func generateWearableSteps(
        from source: ScriptGenerationInput,
        constraints: StepGenerationConstraints
    ) async throws -> StepGenerationResult
}
