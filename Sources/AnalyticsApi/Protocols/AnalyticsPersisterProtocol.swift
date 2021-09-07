import Foundation

protocol AnalyticsPersisterProtocol {
    var logCount: Int { get }
    func save(_ object: AnalyticsEvent, completion: @escaping AnalyticsCompletionHandler)
    func deleteLogs(withIDs logIDs: [String], completionHandler: AnalyticsCompletionHandler?)
    func updateLogs(withIDs logIDs: [String], processingstatus: Bool, completionHandler: AnalyticsCompletionHandler?)
    func fetchAllLogsAndUpdateProcessingStatusToTrue(forLogsWithProcessingStatus processingStatus: Bool?, completionHandler: @escaping AnalyticsCompletionHandlerWithLogs)
    func fetchUnprocessed(top limit: Int) -> [AnalyticsEvent]
}
