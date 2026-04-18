import Foundation

struct Script: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var category: ScriptCategory
    var summary: String
    var riskLevel: RiskLevel
    var sourceType: SourceType
    var sourceReferences: [SourceReference]
    var prerequisites: [String]
    var toolsNeeded: [String]
    var materialsNeeded: [String]
    var warnings: [WarningCard]
    var verificationChecklist: [String]
    var steps: [InstructionStep]
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
}
