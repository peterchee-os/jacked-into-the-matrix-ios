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
        
        // Use hybrid WebView approach for Even G2 integration
        // This loads the Even SDK in a hidden WebView and communicates via JS bridge
        #if targetEnvironment(simulator)
        let evenManager: EvenSessionManaging = MockEvenSessionManager()
        print("Running on simulator - using mock Even session manager")
        #else
        let evenManager: EvenSessionManaging = EvenWebViewManager()
        print("Running on device - using Even WebView bridge")
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
