import Foundation
import SwiftData

@Model
final class Script {
    @Attribute(.unique) var id: UUID
    var title: String
    var categoryRaw: String
    var summary: String
    var riskLevelRaw: String
    var sourceTypeRaw: String
    var prerequisitesData: Data?
    var toolsNeededData: Data?
    var materialsNeededData: Data?
    var warningsData: Data?
    var verificationChecklistData: Data?
    var stepsData: Data?
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var category: ScriptCategory {
        get { ScriptCategory(rawValue: categoryRaw) ?? .homeDIY }
        set { categoryRaw = newValue.rawValue }
    }
    
    var riskLevel: RiskLevel {
        get { RiskLevel(rawValue: riskLevelRaw) ?? .medium }
        set { riskLevelRaw = newValue.rawValue }
    }
    
    var sourceType: SourceType {
        get { SourceType(rawValue: sourceTypeRaw) ?? .curated }
        set { sourceTypeRaw = newValue.rawValue }
    }
    
    var prerequisites: [String] {
        get { (try? JSONDecoder().decode([String].self, from: prerequisitesData ?? Data())) ?? [] }
        set { prerequisitesData = try? JSONEncoder().encode(newValue) }
    }
    
    var toolsNeeded: [String] {
        get { (try? JSONDecoder().decode([String].self, from: toolsNeededData ?? Data())) ?? [] }
        set { toolsNeededData = try? JSONEncoder().encode(newValue) }
    }
    
    var materialsNeeded: [String] {
        get { (try? JSONDecoder().decode([String].self, from: materialsNeededData ?? Data())) ?? [] }
        set { materialsNeededData = try? JSONEncoder().encode(newValue) }
    }
    
    var warnings: [WarningCard] {
        get { (try? JSONDecoder().decode([WarningCard].self, from: warningsData ?? Data())) ?? [] }
        set { warningsData = try? JSONEncoder().encode(newValue) }
    }
    
    var verificationChecklist: [String] {
        get { (try? JSONDecoder().decode([String].self, from: verificationChecklistData ?? Data())) ?? [] }
        set { verificationChecklistData = try? JSONEncoder().encode(newValue) }
    }
    
    var steps: [InstructionStep] {
        get { (try? JSONDecoder().decode([InstructionStep].self, from: stepsData ?? Data())) ?? [] }
        set { stepsData = try? JSONEncoder().encode(newValue) }
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        category: ScriptCategory,
        summary: String,
        riskLevel: RiskLevel,
        sourceType: SourceType,
        prerequisites: [String] = [],
        toolsNeeded: [String] = [],
        materialsNeeded: [String] = [],
        warnings: [WarningCard] = [],
        verificationChecklist: [String] = [],
        steps: [InstructionStep] = [],
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.summary = summary
        self.riskLevelRaw = riskLevel.rawValue
        self.sourceTypeRaw = sourceType.rawValue
        self.prerequisitesData = try? JSONEncoder().encode(prerequisites)
        self.toolsNeededData = try? JSONEncoder().encode(toolsNeeded)
        self.materialsNeededData = try? JSONEncoder().encode(materialsNeeded)
        self.warningsData = try? JSONEncoder().encode(warnings)
        self.verificationChecklistData = try? JSONEncoder().encode(verificationChecklist)
        self.stepsData = try? JSONEncoder().encode(steps)
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - SwiftData Compatible Models

struct InstructionStep: Identifiable, Codable, Hashable {
    let id: UUID
    var orderIndex: Int
    var title: String?
    var text: String
    var tip: String?
    var warning: String?
    var estimatedDurationSeconds: Int?
}

struct WarningCard: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var message: String
    var severity: WarningSeverity
}

enum WarningSeverity: String, Codable, CaseIterable {
    case info
    case caution
    case warning
    case danger
}
