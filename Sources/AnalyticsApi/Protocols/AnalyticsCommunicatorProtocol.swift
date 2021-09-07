import Foundation

protocol AnalyticsCommunicatorProtocol: AnyObject {
    func sendLogs(
        analyticsLogs: [AnalyticsEvent],
        url: URL, headers: [AnalyticsRequestHeader],
        completionHandler: AnalyticsCompletionHandler?
    )
}
