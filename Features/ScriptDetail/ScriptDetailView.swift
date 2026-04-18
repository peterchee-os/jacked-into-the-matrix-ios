import SwiftUI

struct ScriptDetailView: View {
    let script: Script

    var body: some View {
        List {
            Section("Summary") {
                Text(script.summary)
            }

            Section("Steps") {
                ForEach(script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })) { step in
                    VStack(alignment: .leading, spacing: 6) {
                        if let title = step.title {
                            Text(title).font(.headline)
                        }
                        Text(step.text)
                        if let tip = step.tip {
                            Text("Tip: \(tip)").font(.caption)
                        }
                        if let warning = step.warning {
                            Text("Warning: \(warning)").font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle(script.title)
    }
}
