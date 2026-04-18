import Foundation

final class InMemoryScriptRepository: ScriptRepository {
    private var scripts: [UUID: Script] = [:]
    private var recents: [UUID] = []

    func fetchAllScripts() async throws -> [Script] {
        Array(scripts.values).sorted { $0.title < $1.title }
    }

    func fetchFavorites() async throws -> [Script] {
        Array(scripts.values).filter(\.isFavorite).sorted { $0.title < $1.title }
    }

    func fetchRecentScripts() async throws -> [Script] {
        recents.compactMap { scripts[$0] }
    }

    func fetchScript(id: UUID) async throws -> Script? {
        if scripts[id] != nil {
            recents.removeAll(where: { $0 == id })
            recents.insert(id, at: 0)
            recents = Array(recents.prefix(20))
        }
        return scripts[id]
    }

    func saveScript(_ script: Script) async throws {
        scripts[script.id] = script
    }

    func deleteScript(id: UUID) async throws {
        scripts.removeValue(forKey: id)
        recents.removeAll(where: { $0 == id })
    }

    func seedIfNeeded() async throws {
        guard scripts.isEmpty else { return }
        for script in SeedScriptLoader.load() {
            scripts[script.id] = script
        }
    }
}
