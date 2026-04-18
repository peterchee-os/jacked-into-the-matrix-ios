import Foundation
import SwiftData

@MainActor
final class AppEnvironment: ObservableObject {
    let scriptRepository: ScriptRepository
    let playbackEngine: PlaybackEngine
    let evenSessionManager: EvenSessionManaging
    let modelRouter: ModelRouting
    let analyticsService: AnalyticsService

    init(
        scriptRepository: ScriptRepository,
        playbackEngine: PlaybackEngine,
        evenSessionManager: EvenSessionManaging,
        modelRouter: ModelRouting,
        analyticsService: AnalyticsService
    ) {
        self.scriptRepository = scriptRepository
        self.playbackEngine = playbackEngine
        self.evenSessionManager = evenSessionManager
        self.modelRouter = modelRouter
        self.analyticsService = analyticsService
    }

    static func bootstrap() -> AppEnvironment {
        let repository: ScriptRepository
        do {
            repository = try SwiftDataScriptRepository()
        } catch {
            print("Failed to initialize SwiftData repository: \(error). Falling back to in-memory.")
            repository = InMemoryScriptRepository()
        }
        
        let playbackEngine = PlaybackEngine()
        
        // Use real Even G2 manager if available, otherwise fall back to mock
        #if targetEnvironment(simulator)
        let evenManager: EvenSessionManaging = MockEvenSessionManager()
        print("Running on simulator - using mock Even session manager")
        #else
        let evenManager: EvenSessionManaging = EvenG2SessionManager()
        print("Running on device - using real Even G2 session manager")
        #endif
        
        let modelRouter = MockModelRouter()
        let analytics = ConsoleAnalyticsService()

        return AppEnvironment(
            scriptRepository: repository,
            playbackEngine: playbackEngine,
            evenSessionManager: evenManager,
            modelRouter: modelRouter,
            analyticsService: analytics
        )
    }
}
