import Foundation
import WebKit
import Combine

/// Hybrid approach: Native iOS app with WebView for Even G2 communication
/// The WebView loads a minimal bridge page that uses the Even SDK
final class EvenWebViewManager: NSObject, EvenSessionManaging, ObservableObject {
    @Published private(set) var state: EvenSessionState = .disconnected
    
    // MARK: - Properties
    
    private var webView: WKWebView?
    private var bridgeReady = false
    private var pendingCommands: [String] = []
    
    // Input handlers
    var onNextStep: (() -> Void)?
    var onPreviousStep: (() -> Void)?
    var onScrollUp: (() -> Void)?
    var onScrollDown: (() -> Void)?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupWebView()
    }
    
    // MARK: - EvenSessionManaging
    
    func connect() async {
        guard state == .disconnected else { return }
        
        state = .connecting
        
        // Load the bridge HTML
        await loadBridgePage()
        
        // Wait for bridge to be ready
        await waitForBridgeReady()
        
        // Auto-connect to glasses
        await executeJS("window.evenBridge.connect()")
        
        state = .connected(deviceName: "Even G2")
    }
    
    func disconnect() async {
        await executeJS("window.evenBridge.disconnect()")
        state = .disconnected
    }
    
    func send(payload: G2DisplayPayload) async throws {
        guard case .connected = state else {
            throw EvenSessionError.notConnected
        }
        
        guard bridgeReady else {
            throw EvenWebViewError.bridgeNotReady
        }
        
        // Format payload for Even SDK
        let jsPayload = formatPayloadForJS(payload)
        
        // Send to glasses via WebView bridge
        let result = await executeJS("window.evenBridge.displayText(\(jsPayload))")
        
        if result.contains("error") {
            throw EvenSessionError.transmissionFailed
        }
    }
    
    func clearDisplay() async throws {
        guard case .connected = state else {
            throw EvenSessionError.notConnected
        }
        
        await executeJS("window.evenBridge.clearDisplay()")
    }
    
    // MARK: - WebView Setup
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable JavaScript bridge
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "evenAppMessage")
        userContentController.add(self, name: "evenAppLog")
        config.userContentController = userContentController
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.isHidden = true // Hidden WebView - we only use it for the bridge
    }
    
    @MainActor
    private func loadBridgePage() async {
        guard let webView = webView else { return }
        
        let bridgeHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Even G2 Bridge</title>
            <script src="https://unpkg.com/@evenrealities/even_hub_sdk@latest/dist/index.umd.js"></script>
        </head>
        <body>
            <script>
                // Initialize bridge
                const { waitForEvenAppBridge } = window.EvenHubSDK;
                
                waitForEvenAppBridge().then(bridge => {
                    window.evenBridge = bridge;
                    
                    // Notify native app that bridge is ready
                    window.webkit.messageHandlers.evenAppMessage.postMessage({
                        type: 'bridgeReady'
                    });
                    
                    // Listen for input events from glasses
                    window._listenEvenAppMessage = (message) => {
                        window.webkit.messageHandlers.evenAppMessage.postMessage({
                            type: 'inputEvent',
                            data: message
                        });
                    };
                    
                    // Auto-connect
                    bridge.connect().then(() => {
                        window.webkit.messageHandlers.evenAppMessage.postMessage({
                            type: 'connected'
                        });
                    }).catch(err => {
                        window.webkit.messageHandlers.evenAppMessage.postMessage({
                            type: 'error',
                            data: err.message
                        });
                    });
                });
                
                // Logging bridge
                window.evenAppLog = function(msg) {
                    window.webkit.messageHandlers.evenAppLog.postMessage(msg);
                };
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(bridgeHTML, baseURL: nil)
        
        // Wait for page to load
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                continuation.resume()
            }
        }
    }
    
    private func waitForBridgeReady() async {
        // Wait up to 10 seconds for bridge to be ready
        for _ in 0..<100 {
            if bridgeReady {
                return
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
    }
    
    @MainActor
    private func executeJS(_ script: String) async -> String {
        guard let webView = webView else { return "error: no webview" }
        
        return await withCheckedContinuation { continuation in
            webView.evaluateJavaScript(script) { result, error in
                if let error = error {
                    continuation.resume(returning: "error: \(error.localizedDescription)")
                } else if let result = result as? String {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(returning: "success")
                }
            }
        }
    }
    
    private func formatPayloadForJS(_ payload: G2DisplayPayload) -> String {
        // Format as JavaScript object
        let secondaryText = payload.secondaryText?.replacingOccurrences(of: "\"", with: "\\\"") ?? ""
        
        return """
        {
            title: "\(payload.scriptTitle.replacingOccurrences(of: "\"", with: "\\\""))",
            step: \(payload.stepIndex),
            total: \(payload.totalSteps),
            text: "\(payload.primaryText.replacingOccurrences(of: "\"", with: "\\\""))",
            secondary: "\(secondaryText)",
            mode: "\(payload.mode.rawValue)"
        }
        """
    }
    
    private func handleInputEvent(_ event: [String: Any]) {
        guard let type = event["type"] as? String else { return }
        
        switch type {
        case "BUTTON_SINGLE":
            onNextStep?()
        case "BUTTON_DOUBLE":
            onPreviousStep?()
        case "SWIPE_UP":
            onScrollUp?()
        case "SWIPE_DOWN":
            onScrollDown?()
        default:
            break
        }
    }
}

// MARK: - WKScriptMessageHandler

extension EvenWebViewManager: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "evenAppMessage":
            guard let body = message.body as? [String: Any] else { return }
            
            if let type = body["type"] as? String {
                switch type {
                case "bridgeReady":
                    bridgeReady = true
                case "connected":
                    state = .connected(deviceName: "Even G2")
                case "error":
                    if let errorMsg = body["data"] as? String {
                        state = .failed(reason: errorMsg)
                    }
                case "inputEvent":
                    if let data = body["data"] as? [String: Any] {
                        handleInputEvent(data)
                    }
                default:
                    break
                }
            }
            
        case "evenAppLog":
            if EvenG2Configuration.verboseLogging {
                print("Even WebView: \(message.body)")
            }
            
        default:
            break
        }
    }
}

// MARK: - Additional Errors

enum EvenWebViewError: Error {
    case bridgeNotReady
}
