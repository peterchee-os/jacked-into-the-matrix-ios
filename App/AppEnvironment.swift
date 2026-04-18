import Foundation

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
        let repository = InMemoryScriptRepository()
        let playbackEngine = PlaybackEngine()
        let evenManager = MockEvenSessionManager()
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
