import Foundation
import SwiftData

@MainActor
final class SwiftDataScriptRepository: ScriptRepository {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([Script.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = true
    }
    
    func fetchAllScripts() async throws -> [Script] {
        let descriptor = FetchDescriptor<Script>(
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchFavorites() async throws -> [Script] {
        let descriptor = FetchDescriptor<Script>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.title)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetchRecentScripts() async throws -> [Script] {
        let descriptor = FetchDescriptor<Script>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).prefix(20).map { $0 }
    }
    
    func fetchScript(id: UUID) async throws -> Script? {
        let descriptor = FetchDescriptor<Script>(
            predicate: #Predicate { $0.id == id }
        )
        let results = try modelContext.fetch(descriptor)
        if let script = results.first {
            script.updatedAt = Date()
            try modelContext.save()
        }
        return results.first
    }
    
    func saveScript(_ script: Script) async throws {
        script.updatedAt = Date()
        modelContext.insert(script)
        try modelContext.save()
    }
    
    func deleteScript(id: UUID) async throws {
        let descriptor = FetchDescriptor<Script>(
            predicate: #Predicate { $0.id == id }
        )
        let results = try modelContext.fetch(descriptor)
        for script in results {
            modelContext.delete(script)
        }
        try modelContext.save()
    }
    
    func seedIfNeeded() async throws {
        let descriptor = FetchDescriptor<Script>()
        let existingCount = try modelContext.fetchCount(descriptor)
        guard existingCount == 0 else { return }
        
        let seedScripts = SeedScriptLoader.load()
        for script in seedScripts {
            modelContext.insert(script)
        }
        try modelContext.save()
        print("Seeded \(seedScripts.count) scripts")
    }
}
