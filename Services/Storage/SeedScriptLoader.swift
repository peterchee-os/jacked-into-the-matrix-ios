import Foundation

enum SeedScriptLoader {
    static func load() -> [Script] {
        // Try multiple methods to find seed scripts
        var urls: [URL] = []
        
        // Method 1: Try SeedScripts subdirectory
        if let subdirUrls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "SeedScripts") {
            urls.append(contentsOf: subdirUrls)
            print("Found \(subdirUrls.count) scripts in SeedScripts subdirectory")
        }
        
        // Method 2: Try Resources/SeedScripts path
        if urls.isEmpty, let resourcePath = Bundle.main.resourcePath {
            let seedScriptsPath = (resourcePath as NSString).appendingPathComponent("SeedScripts")
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: seedScriptsPath) {
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: seedScriptsPath)
                    let jsonFiles = files.filter { $0.hasSuffix(".json") }
                    urls = jsonFiles.map { (seedScriptsPath as NSString).appendingPathComponent($0) }.map { URL(fileURLWithPath: $0) }
                    print("Found \(urls.count) scripts in Resources/SeedScripts")
                } catch {
                    print("Error reading SeedScripts directory: \(error)")
                }
            }
        }
        
        // Method 3: Search all JSON files in bundle
        if urls.isEmpty, let allJsonUrls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            // Filter for files that look like seed scripts
            urls = allJsonUrls.filter { url in
                let name = url.lastPathComponent.lowercased()
                return name.contains("switch") || name.contains("cli") || name.contains("belay") || name.contains("pesto")
            }
            print("Found \(urls.count) scripts by searching all JSON files")
        }
        
        guard !urls.isEmpty else {
            print("⚠️ No seed scripts found in bundle - checked multiple locations")
            return []
        }
        
        print("Loading \(urls.count) seed scripts...")
        
        return urls.compactMap { url -> Script? in
            guard let data = try? Data(contentsOf: url) else {
                print("Failed to read seed script: \(url.lastPathComponent)")
                return nil
            }
            
            do {
                let dto = try JSONDecoder().decode(SeedScriptDTO.self, from: data)
                print("✅ Loaded: \(dto.title)")
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
