import Foundation

enum SeedScriptLoader {
    static func load() -> [Script] {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "SeedScripts") else {
            print("No seed scripts found in bundle")
            return []
        }
        
        return urls.compactMap { url -> Script? in
            guard let data = try? Data(contentsOf: url) else {
                print("Failed to read seed script: \(url.lastPathComponent)")
                return nil
            }
            
            do {
                let dto = try JSONDecoder().decode(SeedScriptDTO.self, from: data)
                return dto.toScript()
            } catch {
                print("Failed to decode seed script \(url.lastPathComponent): \(error)")
                return nil
            }
        }
    }
}

// MARK: - Seed Script DTO

private struct SeedScriptDTO: Codable {
    let title: String
    let category: String
    let summary: String
    let riskLevel: String
    let steps: [String]
    let toolsNeeded: [String]?
    let materialsNeeded: [String]?
    let prerequisites: [String]?
    let warnings: [SeedWarningDTO]?
    
    func toScript() -> Script {
        let categoryEnum = ScriptCategory(rawValue: category) ?? .homeDIY
        let riskEnum = RiskLevel(rawValue: riskLevel) ?? .medium
        
        let instructionSteps = steps.enumerated().map { index, text in
            InstructionStep(
                id: UUID(),
                orderIndex: index,
                title: nil,
                text: text,
                tip: nil,
                warning: nil,
                estimatedDurationSeconds: nil
            )
        }
        
        let warningCards = warnings?.map { $0.toWarningCard() } ?? []
        
        return Script(
            title: title,
            category: categoryEnum,
            summary: summary,
            riskLevel: riskEnum,
            sourceType: .curated,
            prerequisites: prerequisites ?? [],
            toolsNeeded: toolsNeeded ?? [],
            materialsNeeded: materialsNeeded ?? [],
            warnings: warningCards,
            verificationChecklist: [],
            steps: instructionSteps
        )
    }
}

private struct SeedWarningDTO: Codable {
    let title: String
    let message: String
    let severity: String
    
    func toWarningCard() -> WarningCard {
        WarningCard(
            id: UUID(),
            title: title,
            message: message,
            severity: WarningSeverity(rawValue: severity) ?? .caution
        )
    }
}
