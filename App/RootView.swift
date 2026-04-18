import SwiftUI

struct RootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }
                .tag(AppRouter.Tab.home)

            CategoriesView()
                .tabItem { Label("Categories", systemImage: "square.grid.2x2") }
                .tag(AppRouter.Tab.categories)

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "star") }
                .tag(AppRouter.Tab.favorites)

            RecentsView()
                .tabItem { Label("Recents", systemImage: "clock") }
                .tag(AppRouter.Tab.recents)

            GlassesStatusView()
                .tabItem { Label("Glasses", systemImage: "eyeglasses") }
                .tag(AppRouter.Tab.glasses)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppRouter.Tab.settings)
        }
    }
}
