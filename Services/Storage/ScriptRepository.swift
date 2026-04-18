import Foundation

protocol ScriptRepository {
    func fetchAllScripts() async throws -> [Script]
    func fetchFavorites() async throws -> [Script]
    func fetchRecentScripts() async throws -> [Script]
    func fetchScript(id: UUID) async throws -> Script?
    func saveScript(_ script: Script) async throws
    func deleteScript(id: UUID) async throws
    func seedIfNeeded() async throws
}
