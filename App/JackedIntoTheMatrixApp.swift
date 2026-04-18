import SwiftUI

@main
struct JackedIntoTheMatrixApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var appEnvironment = AppEnvironment.bootstrap()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
                .environmentObject(appEnvironment)
        }
    }
}
