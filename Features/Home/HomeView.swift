import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Query(sort: \Script.title) private var scripts: [Script]
    @State private var recentScripts: [Script] = []
    @State private var favoriteScripts: [Script] = []

    var body: some View {
        NavigationStack {
            List {
                if !recentScripts.isEmpty {
                    Section("Recent") {
                        ForEach(recentScripts.prefix(5)) { script in
                            ScriptRow(script: script)
                        }
                    }
                }

                if !favoriteScripts.isEmpty {
                    Section("Favorites") {
                        ForEach(favoriteScripts) { script in
                            ScriptRow(script: script)
                        }
                    }
                }

                Section("All Scripts") {
                    ForEach(scripts) { script in
                        ScriptRow(script: script)
                    }
                }
            }
            .navigationTitle("Home")
            .task {
                await loadRecentsAndFavorites()
            }
        }
    }

    private func loadRecentsAndFavorites() async {
        do {
            recentScripts = try await appEnvironment.scriptRepository.fetchRecentScripts()
            favoriteScripts = try await appEnvironment.scriptRepository.fetchFavorites()
        } catch {
            print("Failed to load recents/favorites: \(error)")
        }
    }
}

struct ScriptRow: View {
    let script: Script

    var body: some View {
        NavigationLink(value: script) {
            VStack(alignment: .leading, spacing: 4) {
                Text(script.title)
                    .font(.headline)
                Text(script.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack {
                    Label(script.category.displayName, systemImage: categoryIcon)
                        .font(.caption)
                    Spacer()
                    RiskBadge(level: script.riskLevel)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var categoryIcon: String {
        switch script.category {
        case .homeDIY: return "hammer"
        case .softwareCLI: return "terminal"
        case .climbingOutdoor: return "figure.climbing"
        case .cooking: return "fork.knife"
        case .fitnessMovement: return "figure.run"
        case .emergencyChecklists: return "cross.case"
        }
    }
}

struct RiskBadge: View {
    let level: RiskLevel

    var body: some View {
        Text(level.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
