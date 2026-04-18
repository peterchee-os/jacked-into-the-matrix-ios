import SwiftUI

struct SettingsView: View {
    @AppStorage("autoSyncToGlasses") private var autoSyncToGlasses = true
    @AppStorage("defaultPlaybackMode") private var defaultPlaybackMode = PlaybackMode.stepByStep.rawValue
    @AppStorage("highRiskConfirmation") private var highRiskConfirmation = true
    @AppStorage("debugMode") private var debugMode = false
    @EnvironmentObject private var appEnvironment: AppEnvironment

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Playback Settings
                Section("Playback") {
                    Picker("Default Mode", selection: $defaultPlaybackMode) {
                        ForEach(PlaybackMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }

                    Toggle("Auto-sync to Glasses", isOn: $autoSyncToGlasses)

                    Toggle("High-risk Confirmation", isOn: $highRiskConfirmation)
                }

                // MARK: - Glasses Settings
                Section("Glasses") {
                    NavigationLink {
                        GlassesSettingsView()
                    } label: {
                        Label("Glasses Configuration", systemImage: "eyeglasses")
                    }
                }

                // MARK: - AI Model Settings
                Section("AI Model") {
                    NavigationLink {
                        ModelSettingsView()
                    } label: {
                        Label("Model Configuration", systemImage: "cpu")
                    }
                }

                // MARK: - Data Management
                Section("Data") {
                    Button(action: exportScripts) {
                        Label("Export Scripts", systemImage: "square.and.arrow.up")
                    }

                    Button(action: importScripts) {
                        Label("Import Scripts", systemImage: "square.and.arrow.down")
                    }

                    Button(action: clearAllData) {
                        Label("Clear All Data", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: - About
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "100")

                    Link(destination: URL(string: "https://github.com/peterchee-os/jacked-into-the-matrix-ios")!) {
                        Label("GitHub Repository", systemImage: "link")
                    }

                    NavigationLink {
                        AcknowledgmentsView()
                    } label: {
                        Label("Acknowledgments", systemImage: "hands.clap")
                    }
                }

                // MARK: - Debug
                if debugMode {
                    Section("Debug") {
                        Toggle("Enable Debug Logging", isOn: $debugMode)

                        Button(action: resetOnboarding) {
                            Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                        }

                        Button(action: simulateCrash) {
                            Label("Simulate Crash", systemImage: "exclamationmark.octagon")
                                .foregroundStyle(.red)
                        }
                    }
                } else {
                    Section {
                        Toggle("Enable Debug Options", isOn: $debugMode)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func exportScripts() {
        // Would export scripts to JSON
    }

    private func importScripts() {
        // Would import scripts from JSON
    }

    private func clearAllData() {
        // Would clear all SwiftData
    }

    private func resetOnboarding() {
        // Would reset onboarding flags
    }

    private func simulateCrash() {
        fatalError("Debug crash triggered")
    }
}

// MARK: - Sub-views

struct GlassesSettingsView: View {
    @AppStorage("glassesBrightness") private var brightness = 50.0
    @AppStorage("glassesFontSize") private var fontSize = 14.0

    var body: some View {
        List {
            Section("Display") {
                VStack(alignment: .leading) {
                    Text("Brightness")
                    Slider(value: $brightness, in: 0...100, step: 1)
                }

                VStack(alignment: .leading) {
                    Text("Font Size")
                    Slider(value: $fontSize, in: 10...20, step: 1)
                }
            }

            Section("Connection") {
                Toggle("Auto-connect on Launch", isOn: .constant(true))
                Toggle("Reconnect on Disconnect", isOn: .constant(true))
            }
        }
        .navigationTitle("Glasses")
    }
}

struct ModelSettingsView: View {
    @AppStorage("primaryModel") private var primaryModel = "Gemma 4 E2B"
    @AppStorage("fallbackEnabled") private var fallbackEnabled = true

    var body: some View {
        List {
            Section("Primary Model") {
                Picker("Model", selection: $primaryModel) {
                    Text("Gemma 4 E2B").tag("Gemma 4 E2B")
                    Text("Local LLM").tag("Local LLM")
                    Text("Cloud API").tag("Cloud API")
                }
            }

            Section("Fallback") {
                Toggle("Enable Fallback", isOn: $fallbackEnabled)

                if fallbackEnabled {
                    Picker("Fallback Model", selection: .constant("Cloud")) {
                        Text("Cloud API").tag("Cloud")
                        Text("Simpler Local Model").tag("Simple")
                    }
                }
            }

            Section {
                Button("Test Model Connection") {
                    // Test connection to model
                }
            }
        }
        .navigationTitle("AI Model")
    }
}

struct AcknowledgmentsView: View {
    var body: some View {
        List {
            Section {
                Text("Jacked Into The Matrix")
                    .font(.headline)
                Text("A wearable instruction engine for Even Realities G2 glasses.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Third Party") {
                Text("SwiftData - Apple")
                Text("Even Realities SDK")
            }

            Section("Special Thanks") {
                Text("The Even Realities team for the G2 glasses")
                Text("The open source community")
            }
        }
        .navigationTitle("Acknowledgments")
    }
}
