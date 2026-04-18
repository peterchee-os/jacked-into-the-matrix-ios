import Foundation
import UIKit

/// Launches Even Hub with script content via URL scheme
/// This is the recommended way to display content on G2 glasses from a native app
final class EvenHubLauncher {
    
    /// Even Hub URL scheme
    static let evenHubScheme = "evenhub://"
    
    /// Check if Even Hub is installed
    static var isEvenHubInstalled: Bool {
        guard let url = URL(string: evenHubScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Launch Even Hub with a script
    /// This opens the Even Hub app with our content displayed
    static func launchWithScript(_ script: Script, stepIndex: Int = 0) {
        // Build the URL with script data
        let urlString = buildEvenHubURL(script: script, stepIndex: stepIndex)
        
        guard let url = URL(string: urlString) else {
            print("Failed to build Even Hub URL")
            return
        }
        
        if isEvenHubInstalled {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("Launched Even Hub with script: \(script.title)")
                } else {
                    print("Failed to launch Even Hub")
                }
            }
        } else {
            print("Even Hub not installed")
            // Could show alert to user to install Even Hub
        }
    }
    
    /// Build Even Hub compatible URL
    /// Format: evenhub://display?title=...&text=...&step=...&total=...
    private static func buildEvenHubURL(script: Script, stepIndex: Int) -> String {
        var components = URLComponents()
        components.scheme = "evenhub"
        components.host = "display"
        
        let sortedSteps = script.steps.sorted(by: { $0.orderIndex < $1.orderIndex })
        guard let currentStep = sortedSteps[safe: stepIndex] else {
            return evenHubScheme
        }
        
        // Build query items
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "title", value: script.title),
            URLQueryItem(name: "step", value: "\(stepIndex + 1)"),
            URLQueryItem(name: "total", value: "\(script.steps.count)"),
            URLQueryItem(name: "text", value: currentStep.text)
        ]
        
        if let warning = currentStep.warning {
            queryItems.append(URLQueryItem(name: "warning", value: warning))
        }
        
        if let tip = currentStep.tip {
            queryItems.append(URLQueryItem(name: "tip", value: tip))
        }
        
        components.queryItems = queryItems
        
        return components.string ?? evenHubScheme
    }
}
