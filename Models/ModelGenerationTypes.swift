import Foundation

struct ScriptGenerationInput: Codable, Hashable {
    var title: String
    var rawInstructionText: String
    var category: ScriptCategory
    var riskLevel: RiskLevel
}

struct StepGenerationConstraints: Codable, Hashable {
    var maxPrimaryTextCharacters: Int
    var maxSecondaryTextCharacters: Int
    var maxSteps: Int
    var preserveWarnings: Bool
    var requireVerbFirst: Bool
}

struct StepGenerationResult: Codable, Hashable {
    var modelID: String
    var fallbackUsed: Bool
    var confidence: Double?
    var generatedScript: Script
    var warnings: [String]
}
