import SwiftUI

struct ScriptDetailView: View {
    let script: Script
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var showingRiskWarning = false
    @State private var showingPlaybackConfirmation = false

    var body: some View {
        List {
            // MARK: - Header Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label(script.category.displayName, systemImage: categoryIcon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        RiskBadge(level: script.riskLevel)
                    }

                    Text(script.summary)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }

            // MARK: - Warnings Section (High priority)
            if !script.warnings.isEmpty {
                Section("⚠️ Warnings") {
                    ForEach(script.warnings) { warning in
                        WarningRow(warning: warning)
                    }
                }
            }

            // MARK: - Prerequisites
            if !script.prerequisites.isEmpty {
                Section("Prerequisites") {
                    ForEach(script.prerequisites, id: \.self) { prereq in
                        Label(prereq, systemImage: "checkmark.circle")
                    }
                }
            }

            // MARK: - Tools & Materials
            if !script.toolsNeeded.isEmpty {
                Section("Tools Needed") {
                    FlowLayout(spacing: 8) {
                        ForEach(script.toolsNeeded, id: \.self) { tool in
                            ToolTag(text: tool)
                        }
                    }
                }
            }

            if !script.materialsNeeded.isEmpty {
                Section("Materials") {
                    ForEach(script.materialsNeeded, id: \.self) { material in
                        Label(material, systemImage: "cube.box")
                    }
                }
            }

            // MARK: - Steps Preview
            Section("Steps (\(script.steps.count))") {
                ForEach(script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })) { step in
                    StepPreviewRow(step: step)
                }
            }

            // MARK: - Verification Checklist
            if !script.verificationChecklist.isEmpty {
                Section("Verification") {
                    ForEach(script.verificationChecklist, id: \.self) { item in
                        Label(item, systemImage: "checkmark.square")
                    }
                }
            }
            
            // MARK: - Send to Glasses Button (Prominent)
            Section {
                SendToGlassesButton(riskLevel: script.riskLevel) {
                    prepareToSend()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(script.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavoriteButton(isFavorite: script.isFavorite) {
                    toggleFavorite()
                }
            }
        }
        .alert("High Risk Task", isPresented: $showingRiskWarning) {
            Button("Cancel", role: .cancel) { }
            Button("I Understand the Risks") {
                showingPlaybackConfirmation = true
            }
        } message: {
            Text("This task has been marked as high risk. Please review all warnings and ensure you understand the safety implications before proceeding.")
        }
        .sheet(isPresented: $showingPlaybackConfirmation) {
            PlaybackConfirmationSheet(script: script)
        }
        .navigationDestination(for: String.self) { value in
            if value == "playback" {
                PlaybackView(script: script)
            }
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

    private func toggleFavorite() {
        Task {
            script.isFavorite.toggle()
            script.updatedAt = Date()
            try? await appEnvironment.scriptRepository.saveScript(script)
        }
    }

    private func prepareToSend() {
        if script.riskLevel == .high {
            showingRiskWarning = true
        } else {
            showingPlaybackConfirmation = true
        }
    }
}

// MARK: - Supporting Views

struct WarningRow: View {
    let warning: WarningCard

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: warningIcon)
                .foregroundStyle(warningColor)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(warning.title)
                    .font(.headline)
                Text(warning.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var warningIcon: String {
        switch warning.severity {
        case .info: return "info.circle"
        case .caution: return "exclamationmark.triangle"
        case .warning: return "exclamationmark.triangle.fill"
        case .danger: return "xmark.octagon.fill"
        }
    }

    private var warningColor: Color {
        switch warning.severity {
        case .info: return .blue
        case .caution: return .yellow
        case .warning: return .orange
        case .danger: return .red
        }
    }
}

struct StepPreviewRow: View {
    let step: InstructionStep

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(step.orderIndex + 1)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                if let title = step.title {
                    Text(title)
                        .font(.headline)
                }
                Text(step.text)
                    .lineLimit(3)

                if let tip = step.tip {
                    Label(tip, systemImage: "lightbulb")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let warning = step.warning {
                    Label(warning, systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ToolTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundStyle(.blue)
            .clipShape(Capsule())
    }
}

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundStyle(isFavorite ? .yellow : .gray)
        }
    }
}

struct SendToGlassesButton: View {
    let riskLevel: RiskLevel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "eyeglasses")
                Text("Send to Glasses")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(buttonColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    private var buttonColor: Color {
        switch riskLevel {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct PlaybackConfirmationSheet: View {
    let script: Script
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "eyeglasses")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Ready to Send")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\"\(script.title)\" will be sent to your Even G2 glasses.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    Label("\(script.steps.count) steps", systemImage: "list.number")
                    Label(script.category.displayName, systemImage: "tag")
                    if script.riskLevel == .high {
                        Label("High risk - stay alert", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        startPlayback()
                    } label: {
                        HStack {
                            Image(systemName: "eyeglasses")
                            Text("Send to Glasses")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Confirm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func startPlayback() {
        // Start playback on phone
        appEnvironment.playbackEngine.start(script: script, mode: .stepByStep)

        // Launch Even Hub with the script
        EvenHubLauncher.launchWithScript(script)

        dismiss()

        // Navigate to playback view
        router.navigationPath.append("playback")
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
