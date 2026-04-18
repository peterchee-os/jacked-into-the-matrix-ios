import SwiftUI

struct DrillModeView: View {
    let script: Script
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var showingAnswer = false
    @State private var currentStepIndex = 0
    @State private var completedSteps: Set<Int> = []
    @State private var showingExitConfirmation = false
    @State private var showingRestartConfirmation = false

    private var sortedSteps: [InstructionStep] {
        script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })
    }

    private var currentStep: InstructionStep? {
        sortedSteps[safe: currentStepIndex]
    }

    private var isLastStep: Bool {
        currentStepIndex >= sortedSteps.count - 1
    }

    private var progress: Double {
        guard !sortedSteps.isEmpty else { return 0 }
        return Double(completedSteps.count) / Double(sortedSteps.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            drillHeader
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 1)

            // MARK: - Main Content
            ScrollView {
                VStack(spacing: 24) {
                    if let step = currentStep {
                        // Prompt Card (always visible)
                        PromptCard(
                            stepNumber: currentStepIndex + 1,
                            totalSteps: sortedSteps.count,
                            prompt: drillPrompt(for: step)
                        )

                        // Answer Card (revealed on demand)
                        if showingAnswer {
                            AnswerCard(step: step)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    } else {
                        CompletionView(
                            completedCount: completedSteps.count,
                            totalCount: sortedSteps.count
                        )
                    }
                }
                .padding()
            }

            // MARK: - Controls
            drillControls
                .padding()
                .background(Color(.systemBackground))
                .shadow(radius: 1, y: -1)
        }
        .navigationTitle("Drill Mode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    showingExitConfirmation = true
                }
            }
        }
        .alert("Exit Drill?", isPresented: $showingExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Exit") {
                dismiss()
            }
        } message: {
            Text("Your progress will be saved. You've completed \(completedSteps.count) of \(sortedSteps.count) steps.")
        }
        .alert("Restart Drill?", isPresented: $showingRestartConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Restart", role: .destructive) {
                restartDrill()
            }
        } message: {
            Text("This will reset all progress and start from the beginning.")
        }
    }

    // MARK: - Header

    private var drillHeader: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .clipShape(Capsule())

                    Rectangle()
                        .fill(drillProgressColor)
                        .frame(width: geo.size.width * progress, height: 8)
                        .clipShape(Capsule())
                }
            }
            .frame(height: 8)

            HStack {
                Text("Drill Progress: \(completedSteps.count)/\(sortedSteps.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    showingRestartConfirmation = true
                } label: {
                    Label("Restart", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                }
            }
        }
    }

    private var drillProgressColor: Color {
        if progress < 0.33 { return .blue }
        if progress < 0.66 { return .orange }
        return .green
    }

    // MARK: - Controls

    private var drillControls: some View {
        VStack(spacing: 12) {
            if currentStep != nil {
                if !showingAnswer {
                    // Reveal Answer button
                    Button(action: revealAnswer) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Reveal Answer")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    // Got it / Need practice buttons
                    HStack(spacing: 12) {
                        Button(action: markNeedsPractice) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Again")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Button(action: markComplete) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Got It")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            } else {
                // Completion state
                Button(action: restartDrill) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Drill Again")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button("Exit") {
                    dismiss()
                }
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Actions

    private func drillPrompt(for step: InstructionStep) -> String {
        // Generate a prompt that asks what to do without revealing the answer
        if let title = step.title {
            return "What is '\(title)'?"
        }
        // Extract action verb from step text
        let words = step.text.split(separator: " ")
        if let firstWord = words.first {
            return "What should you do? (Starts with '\(firstWord)')"
        }
        return "What is the next step?"
    }

    private func revealAnswer() {
        withAnimation(.spring(response: 0.3)) {
            showingAnswer = true
        }
    }

    private func markComplete() {
        completedSteps.insert(currentStepIndex)
        advanceStep()
    }

    private func markNeedsPractice() {
        // Don't mark as complete, just advance
        advanceStep()
    }

    private func advanceStep() {
        withAnimation {
            showingAnswer = false
            if currentStepIndex < sortedSteps.count - 1 {
                currentStepIndex += 1
            } else {
                // Completed all steps
                currentStepIndex = sortedSteps.count
            }
        }
    }

    private func restartDrill() {
        withAnimation {
            completedSteps.removeAll()
            currentStepIndex = 0
            showingAnswer = false
        }
    }
}

// MARK: - Supporting Views

struct PromptCard: View {
    let stepNumber: Int
    let totalSteps: Int
    let prompt: String

    var body: some View {
        VStack(spacing: 20) {
            // Step indicator
            HStack {
                Text("STEP \(stepNumber) OF \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.blue)
            }

            // The prompt/question
            Text(prompt)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            // Hint
            Text("Try to recall the answer before revealing.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AnswerCard: View {
    let step: InstructionStep

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)

                Text("ANSWER")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if let title = step.title {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Text(step.text)
                .font(.body)

            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    Text(tip)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if let warning = step.warning {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                    Text(warning)
                        .font(.subheadline)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct CompletionView: View {
    let completedCount: Int
    let totalCount: Int

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text("Drill Complete!")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text("You reviewed \(totalCount) steps")
                    .font(.headline)

                if completedCount == totalCount {
                    Text("Perfect! You marked all steps as complete.")
                        .foregroundStyle(.green)
                } else {
                    Text("You marked \(completedCount) of \(totalCount) as mastered.")
                        .foregroundStyle(.secondary)
                }
            }

            Text("Regular practice builds muscle memory for safety-critical procedures.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}
