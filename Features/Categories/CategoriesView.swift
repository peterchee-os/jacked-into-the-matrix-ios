import SwiftUI
import SwiftData

struct CategoriesView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Script.title) private var allScripts: [Script]
    @State private var selectedCategory: ScriptCategory?
    @State private var searchText = ""

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            List {
                // Category grid
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                        ForEach(ScriptCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                scriptCount: scriptCount(for: category)
                            )
                            .onTapGesture {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // All scripts (searchable)
                Section("All Scripts") {
                    ForEach(filteredScripts) { script in
                        ScriptRow(script: script)
                            .onTapGesture {
                                router.navigateToScript(script)
                            }
                    }
                }
            }
            .navigationTitle("Categories")
            .searchable(text: $searchText, prompt: "Search scripts...")
            .navigationDestination(for: Script.self) { script in
                ScriptDetailView(script: script)
            }
            .sheet(item: $selectedCategory) { category in
                CategoryDetailView(category: category)
            }
        }
    }

    private func scriptCount(for category: ScriptCategory) -> Int {
        allScripts.filter { $0.category == category }.count
    }

    private var filteredScripts: [Script] {
        if searchText.isEmpty {
            return allScripts
        }
        return allScripts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.summary.localizedCaseInsensitiveContains(searchText)
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: ScriptCategory
    let scriptCount: Int

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: categoryIcon)
                .font(.system(size: 32))
                .foregroundStyle(categoryColor)

            VStack(spacing: 4) {
                Text(category.displayName)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("\(scriptCount) script\(scriptCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var categoryIcon: String {
        switch category {
        case .homeDIY: return "hammer.fill"
        case .softwareCLI: return "terminal.fill"
        case .climbingOutdoor: return "figure.climbing"
        case .cooking: return "fork.knife"
        case .fitnessMovement: return "figure.run"
        case .emergencyChecklists: return "cross.case.fill"
        }
    }

    private var categoryColor: Color {
        switch category {
        case .homeDIY: return .orange
        case .softwareCLI: return .blue
        case .climbingOutdoor: return .green
        case .cooking: return .red
        case .fitnessMovement: return .purple
        case .emergencyChecklists: return .red
        }
    }
}

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let category: ScriptCategory
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: AppRouter
    @Query(sort: \Script.title) private var allScripts: [Script]
    @State private var riskFilter: RiskFilter = .all

    var body: some View {
        NavigationStack {
            List {
                // Risk level filter
                Section {
                    Picker("Risk Level", selection: $riskFilter) {
                        ForEach(RiskFilter.allCases, id: \.self) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Filtered scripts
                Section("\(filteredScripts.count) Scripts") {
                    ForEach(filteredScripts) { script in
                        ScriptRow(script: script)
                            .onTapGesture {
                                dismiss()
                                router.navigateToScript(script)
                            }
                    }
                }
            }
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var filteredScripts: [Script] {
        allScripts.filter { script in
            script.category == category &&
            riskFilter.matches(script.riskLevel)
        }
    }
}

enum RiskFilter: CaseIterable {
    case all
    case low
    case medium
    case high

    var displayName: String {
        switch self {
        case .all: return "All"
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    func matches(_ risk: RiskLevel) -> Bool {
        switch self {
        case .all: return true
        case .low: return risk == .low
        case .medium: return risk == .medium
        case .high: return risk == .high
        }
    }
}

// MARK: - Script Row (reused from HomeView)

struct CategoryScriptRow: View {
    let script: Script

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(script.title)
                .font(.headline)
            Text(script.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack {
                RiskBadge(level: script.riskLevel)
                Spacer()
                if script.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
