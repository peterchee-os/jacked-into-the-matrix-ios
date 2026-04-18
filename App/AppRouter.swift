import Foundation
import SwiftUI

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
    @Published var navigationPath = NavigationPath()

    func navigateToScript(_ script: Script) {
        navigationPath.append(script)
    }

    func navigateBack() {
        navigationPath.removeLast()
    }

    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
}
