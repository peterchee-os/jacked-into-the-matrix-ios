import Foundation

final class AppRouter: ObservableObject {
    enum Tab: String, CaseIterable {
        case home
        case categories
        case favorites
        case recents
        case glasses
        case settings
    }

    @Published var selectedTab: Tab = .home
}
