import Foundation

protocol AnalyticsService {
    func track(_ event: String, properties: [String: String])
}

final class ConsoleAnalyticsService: AnalyticsService {
    func track(_ event: String, properties: [String : String] = [:]) {
        print("[analytics]", event, properties)
    }
}
