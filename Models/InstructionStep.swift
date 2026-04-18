import Foundation

struct InstructionStep: Identifiable, Codable, Hashable {
    let id: UUID
    var orderIndex: Int
    var title: String?
    var text: String
    var tip: String?
    var warning: String?
    var estimatedDurationSeconds: Int?
}
