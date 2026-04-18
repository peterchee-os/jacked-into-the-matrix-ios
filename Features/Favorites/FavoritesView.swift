import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @State private var favoriteScripts: [Script] = []

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            List {
                if favoriteScripts.isEmpty {
                    Section {
                        EmptyStateView(
                            icon: "star",
                            title: "No Favorites",
                            message: "Tap the star button on any script to add it to your favorites."
                        )
                    }
                } else {
                    Section("\(favoriteScripts.count) Favorite Scripts") {
                        ForEach(favoriteScripts) { script in
                            ScriptRow(script: script)
                                .onTapGesture {
                                    router.navigateToScript(script)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationDestination(for: Script.self) { script in
                ScriptDetailView(script: script)
            }
            .task {
                await loadFavorites()
            }
            .refreshable {
                await loadFavorites()
            }
        }
    }

    private func loadFavorites() async {
        do {
            favoriteScripts = try await appEnvironment.scriptRepository.fetchFavorites()
        } catch {
            print("Failed to load favorites: \(error)")
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}
