import SwiftUI

struct PlaybackView: View {
    let script: Script
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitConfirmation = false

    var body: some View {
        let state = appEnvironment.playbackEngine.playbackState
        let currentStepIndex = state?.currentStepIndex ?? 0
        let step = script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })[safe: currentStepIndex]
        let mode = state?.mode ?? .stepByStep

        VStack(spacing: 0) {
            // MARK: - Progress Header
            ProgressHeader(
                currentStep: currentStepIndex + 1,
                totalSteps: script.steps.count,
                mode: mode
            )
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 1)

            // MARK: - Main Step Display
            ScrollView {
                VStack(spacing: 24) {
                    if let step = step {
                        StepCard(step: step, stepNumber: currentStepIndex + 1)
                    } else {
                        EmptyStepView()
                    }
                }
                .padding()
            }

            // MARK: - Navigation Controls
            NavigationControls(
                script: script,
                currentMode: mode,
                canGoPrevious: currentStepIndex > 0,
                canGoNext: currentStepIndex < script.steps.count - 1,
                onPrevious: { appEnvironment.playbackEngine.previous() },
                onNext: { appEnvironment.playbackEngine.next(totalSteps: script.steps.count) },
                onModeChange: { newMode in
                    appEnvironment.playbackEngine.setMode(newMode)
                }
            )
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 1, y: -1)
        }
        .navigationTitle(script.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    showingExitConfirmation = true
                }
            }
        }
        .alert("End Playback?", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("End", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Your progress has been saved.")
        }
        .onAppear {
            // Sync to glasses when view appears
            syncToGlasses()
        }
        .onChange(of: currentStepIndex) {
            syncToGlasses()
        }
    }

    private func syncToGlasses() {
        // TODO: Send current step to Even G2 glasses
        // let payload = G2PayloadFormatter.format(script: script, stepIndex: currentStepIndex, mode: mode)
        // appEnvironment.evenSessionManager.send(payload: payload)
    }
}

// MARK: - Supporting Views

struct ProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let mode: PlaybackMode

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .clipShape(Capsule())

                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geo.size.width * progress, height: 8)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 8)

            HStack {
                Text("Step \(currentStep) of \(totalSteps)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Label(mode.displayName, systemImage: mode.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }

    private var progressColor: Color {
        let pct = progress
        if pct < 0.33 { return .blue }
        if pct < 0.66 { return .orange }
        return .green
    }
}

struct StepCard: View {
    let step: InstructionStep
    let stepNumber: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step number badge
            HStack {
                Text("STEP \(stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())

                Spacer()
            }

            // Title if present
            if let title = step.title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }

            // Main instruction
            Text(step.text)
                .font(.title3)
                .lineSpacing(4)

            // Tip if present
            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                    Text(tip)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Warning if present
            if let warning = step.warning {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(warning)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Estimated duration
            if let duration = step.estimatedDurationSeconds {
                HStack {
                    Image(systemName: "clock")
                    Text("~\(duration / 60) min")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EmptyStepView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No step loaded")
                .font(.headline)
            Text("There was a problem loading this step.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

struct NavigationControls: View {
    let script: Script
    let currentMode: PlaybackMode
    let canGoPrevious: Bool
    let canGoNext: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onModeChange: (PlaybackMode) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Mode selector menu
            Menu {
                ForEach(PlaybackMode.allCases, id: \.self) { mode in
                    Button {
                        onModeChange(mode)
                    } label: {
                        Label(mode.displayName, systemImage: mode.icon)
                        if mode == currentMode {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Divider()
                
                NavigationLink {
                    DrillModeView(script: script)
                } label: {
                    Label("Drill Mode", systemImage: "graduationcap")
                }
            } label: {
                Label("Change Mode", systemImage: "gear")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)

            // Navigation buttons
            HStack(spacing: 20) {
                Button(action: onPrevious) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canGoPrevious ? Color.blue : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canGoPrevious)

                Button(action: onNext) {
                    HStack {
                        Text(canGoNext ? "Next" : "Finish")
                        Image(systemName: canGoNext ? "chevron.right" : "checkmark")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canGoNext ? Color.green : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

// MARK: - Playback Mode Extensions

extension PlaybackMode {
    var displayName: String {
        switch self {
        case .stepByStep: return "Step by Step"
        case .continuous: return "Continuous"
        case .drill: return "Drill Mode"
        }
    }

    var icon: String {
        switch self {
        case .stepByStep: return "list.number"
        case .continuous: return "play.fill"
        case .drill: return "graduationcap.fill"
        }
    }
}
