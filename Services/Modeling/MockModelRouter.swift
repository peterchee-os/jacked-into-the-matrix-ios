import Foundation

final class MockModelRouter: ModelRouting {
    func generateWearableSteps(
        from source: ScriptGenerationInput,
        constraints: StepGenerationConstraints
    ) async throws -> StepGenerationResult {
        let steps = source.rawInstructionText
            .split(separator: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .prefix(constraints.maxSteps)
            .enumerated()
            .map { index, line in
                InstructionStep(
                    id: UUID(),
                    orderIndex: index,
                    title: nil,
                    text: String(line).trimmingCharacters(in: .whitespacesAndNewlines),
                    tip: nil,
                    warning: nil,
                    estimatedDurationSeconds: nil
                )
            }

        let script = Script(
            id: UUID(),
            title: source.title,
            category: source.category,
            summary: "Mock-generated wearable steps.",
            riskLevel: source.riskLevel,
            sourceType: .aiGenerated,
            sourceReferences: [],
            prerequisites: [],
            toolsNeeded: [],
            materialsNeeded: [],
            warnings: [],
            verificationChecklist: [],
            steps: steps,
            isFavorite: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        return StepGenerationResult(
            modelID: "mock-gemma4-e2b",
            fallbackUsed: false,
            confidence: 0.5,
            generatedScript: script,
            warnings: []
        )
    }
}
