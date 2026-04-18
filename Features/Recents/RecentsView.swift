import SwiftUI

struct RecentsView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @State private var recentScripts: [Script] = []

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            List {
                if recentScripts.isEmpty {
                    Section {
                        EmptyStateView(
                            icon: "clock",
                            title: "No Recent Scripts",
                            message: "Scripts you view will appear here for quick access."
                        )
                    }
                } else {
                    Section("Recently Viewed") {
                        ForEach(recentScripts) { script in
                            HStack {
                                ScriptRow(script: script)
                                    .onTapGesture {
                                        router.navigateToScript(script)
                                    }

                                Spacer()

                                // Show how long ago
                                Text(timeAgo(from: script.updatedAt))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section {
                        Button("Clear History", role: .destructive) {
                            Task {
                                await clearRecents()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Recents")
            .navigationDestination(for: Script.self) { script in
                ScriptDetailView(script: script)
            }
            .task {
                await loadRecents()
            }
            .refreshable {
                await loadRecents()
            }
        }
    }

    private func loadRecents() async {
        do {
            recentScripts = try await appEnvironment.scriptRepository.fetchRecentScripts()
        } catch {
            print("Failed to load recents: \(error)")
        }
    }

    private func clearRecents() async {
        // Note: In a real implementation, we'd have a clearRecents method on the repository
        // For now, we'll just reload (the in-memory version clears on app restart)
        await loadRecents()
    }

    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
