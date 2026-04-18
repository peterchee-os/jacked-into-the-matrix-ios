import SwiftUI

struct GlassesStatusView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @State private var showingDebugInfo = false

    var body: some View {
        NavigationStack {
            List {
                // Connection Status Section
                connectionSection

                // Active Script Section
                activeScriptSection

                // Device Info Section
                deviceInfoSection

                // Actions Section
                actionsSection

                // Debug Section (hidden by default)
                if showingDebugInfo {
                    debugSection
                }
            }
            .navigationTitle("Glasses")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Debug") {
                        showingDebugInfo.toggle()
                    }
                    .font(.caption)
                }
            }
        }
    }

    // MARK: - Connection Status

    private var connectionSection: some View {
        Section("Connection") {
            HStack(spacing: 16) {
                // Status indicator
                ZStack {
                    Circle()
                        .fill(connectionColor.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Image(systemName: connectionIcon)
                        .font(.system(size: 28))
                        .foregroundStyle(connectionColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(connectionStatusText)
                        .font(.headline)

                    Text(connectionDetailText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 8)

            // Connect/Disconnect button
            Button(action: toggleConnection) {
                HStack {
                    Image(systemName: isConnected ? "xmark.circle" : "checkmark.circle")
                    Text(isConnected ? "Disconnect" : "Connect")
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(isConnected ? .red : .blue)
            }
            .disabled(isConnecting)
        }
    }

    // MARK: - Active Script

    private var activeScriptSection: some View {
        Section("Active Script") {
            if let script = activeScript, let state = appEnvironment.playbackEngine.playbackState {
                VStack(alignment: .leading, spacing: 12) {
                    Text(script.title)
                        .font(.headline)

                    HStack {
                        Label("Step \(state.currentStepIndex + 1) of \(script.steps.count)", systemImage: "list.number")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Label(state.mode.displayName, systemImage: state.mode.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Current step preview
                    if let step = script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })[safe: state.currentStepIndex] {
                        Text(step.text)
                            .font(.body)
                            .lineLimit(2)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.vertical, 4)

                // Quick actions
                HStack(spacing: 12) {
                    Button(action: resendToGlasses) {
                        Label("Resend", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)

                    Button(action: clearActiveScript) {
                        Label("Clear", systemImage: "xmark")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                EmptyStateView(
                    icon: "eyeglasses",
                    title: "No Active Script",
                    message: "Send a script from the detail view to start playback on your glasses."
                )
                .frame(maxWidth: .infinity, minHeight: 150)
            }
        }
    }

    // MARK: - Device Info

    private var deviceInfoSection: some View {
        Section("Device Info") {
            LabeledContent("Device", value: "Even Realities G2")
            LabeledContent("Firmware", value: "1.0.0 (Mock)")
            LabeledContent("Battery", value: "85%")
            LabeledContent("Last Sync", value: lastSyncText)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        Section("Actions") {
            Button(action: testConnection) {
                Label("Test Connection", systemImage: "antenna.radiowaves.left.and.right")
            }

            Button(action: resetGlasses) {
                Label("Reset Glasses Display", systemImage: "arrow.counterclockwise")
            }

            Button(action: calibrate) {
                Label("Calibrate Display", systemImage: "viewfinder")
            }
        }
    }

    // MARK: - Debug Section

    private var debugSection: some View {
        Section("Debug Information") {
            LabeledContent("Session State", value: String(describing: appEnvironment.evenSessionManager.state))

            if let payload = lastSentPayload {
                LabeledContent("Last Payload Size", value: "\(payload.primaryText.count) chars")
            }

            LabeledContent("Model Router", value: appEnvironment.modelRouter is MockModelRouter ? "Mock" : "Live")

            Button(action: simulateDisconnect) {
                Label("Simulate Disconnect", systemImage: "network.slash")
                    .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Computed Properties

    private var isConnected: Bool {
        if case .connected = appEnvironment.evenSessionManager.state {
            return true
        }
        return false
    }

    private var isConnecting: Bool {
        if case .connecting = appEnvironment.evenSessionManager.state {
            return true
        }
        return false
    }

    private var connectionColor: Color {
        switch appEnvironment.evenSessionManager.state {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .gray
        case .failed: return .red
        }
    }

    private var connectionIcon: String {
        switch appEnvironment.evenSessionManager.state {
        case .connected: return "eyeglasses"
        case .connecting: return "antenna.radiowaves.left.and.right"
        case .disconnected: return "eyeglasses.slash"
        case .failed: return "exclamationmark.triangle"
        }
    }

    private var connectionStatusText: String {
        switch appEnvironment.evenSessionManager.state {
        case .connected: return "Connected"
        case .connecting: return "Connecting..."
        case .disconnected: return "Disconnected"
        case .failed: return "Connection Failed"
        }
    }

    private var connectionDetailText: String {
        switch appEnvironment.evenSessionManager.state {
        case .connected(let name): return name ?? "Even G2"
        case .connecting: return "Establishing connection..."
        case .disconnected: return "Tap Connect to pair"
        case .failed(let reason): return reason
        }
    }

    private var activeScript: Script? {
        guard appEnvironment.playbackEngine.playbackState != nil else { return nil }
        // In a real implementation, we'd fetch the script from the repository
        // For now, return nil to show the empty state
        return nil
    }

    private var lastSyncText: String {
        guard let state = appEnvironment.playbackEngine.playbackState,
              let lastSync = state.lastSyncedToGlassesAt else {
            return "Never"
        }
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: lastSync, relativeTo: Date())
    }

    private var lastSentPayload: G2DisplayPayload? {
        // Would track last sent payload in a real implementation
        return nil
    }

    // MARK: - Actions

    private func toggleConnection() {
        Task {
            if isConnected {
                await appEnvironment.evenSessionManager.disconnect()
            } else {
                await appEnvironment.evenSessionManager.connect()
            }
        }
    }

    private func resendToGlasses() {
        // Resend current step to glasses
        syncToGlasses()
    }

    private func clearActiveScript() {
        // Would need to add a method to PlaybackEngine to stop/clear
        Task {
            try? await appEnvironment.evenSessionManager.clearDisplay()
        }
    }

    private func testConnection() {
        // Send a test payload
        Task {
            let testPayload = G2DisplayPayload(
                scriptTitle: "Test",
                stepIndex: 0,
                totalSteps: 1,
                primaryText: "Connection test successful",
                secondaryText: nil,
                mode: .stepByStep
            )
            try? await appEnvironment.evenSessionManager.send(payload: testPayload)
        }
    }

    private func resetGlasses() {
        Task {
            try? await appEnvironment.evenSessionManager.clearDisplay()
        }
    }

    private func calibrate() {
        // Would trigger calibration flow
    }

    private func simulateDisconnect() {
        // For testing disconnect handling
    }

    private func syncToGlasses() {
        guard appEnvironment.playbackEngine.playbackState != nil else { return }
        // Would fetch script and format payload
        // let payload = G2PayloadFormatter.format(...)
        // Task { try? await appEnvironment.evenSessionManager.send(payload: payload) }
    }
}
