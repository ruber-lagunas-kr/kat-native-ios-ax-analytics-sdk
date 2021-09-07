import Foundation

public protocol AnalyticsLogicControllerProtocol {
    func logEvent(actionPayload: Data, labeled: String)
}
