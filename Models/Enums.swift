import Foundation

enum ScriptCategory: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case homeDIY
    case softwareCLI
    case climbingOutdoor
    case cooking
    case fitnessMovement
    case emergencyChecklists

    var displayName: String {
        switch self {
        case .homeDIY: return "Home DIY"
        case .softwareCLI: return "Software / CLI"
        case .climbingOutdoor: return "Climbing / Outdoor"
        case .cooking: return "Cooking"
        case .fitnessMovement: return "Fitness / Movement"
        case .emergencyChecklists: return "Emergency / Checklists"
        }
    }
}

enum RiskLevel: String, Codable {
    case low
    case medium
    case high
}

enum PlaybackMode: String, Codable, CaseIterable {
    case stepByStep
    case continuous
    case drill
}

enum SourceType: String, Codable {
    case curated
    case userAuthored
    case aiGenerated
    case hybrid
}
