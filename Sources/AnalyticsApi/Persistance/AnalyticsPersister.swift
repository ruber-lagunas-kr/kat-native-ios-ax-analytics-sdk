
typealias AnalyticsCompletionHandlerWithLogs = ([AnalyticsEvent], Error?) -> Void

final class AnalyticsPersister {
    let analyticsCacheFile: AnalyticsCacheFile

    init(_ analyticsCacheFile: AnalyticsCacheFile) {
        self.analyticsCacheFile = analyticsCacheFile
    }

    private(set) lazy var inMemoryLogs: [AnalyticsEvent] = {
        guard case .success(let allLogs) = analyticsCacheFile.read() else {
            return []
        }
        return allLogs
    }()
}

extension AnalyticsPersister: AnalyticsPersisterProtocol {
    var logCount: Int {
        inMemoryLogs.count
    }

    func save(_ object: AnalyticsEvent, completion: @escaping AnalyticsCompletionHandler) {
        inMemoryLogs.append(object)
        _ = analyticsCacheFile.update(inMemoryLogs)
        completion(nil)
    }

    func deleteLogs(withIDs logIDs: [String], completionHandler: AnalyticsCompletionHandler?) {
        let filteredLogs = inMemoryLogs
            .filter { !logIDs.contains($0.analyticsLogID) }

        inMemoryLogs = filteredLogs
        _ = analyticsCacheFile.update(inMemoryLogs)

        completionHandler?(nil)
    }

    func updateLogs(withIDs logIDs: [String], processingstatus: Bool, completionHandler: AnalyticsCompletionHandler?) {
        let allLogs = inMemoryLogs

        let untouchedLogs = allLogs
            .filter { !logIDs.contains($0.analyticsLogID) }

        let updatedLogs = allLogs
            .filter { logIDs.contains($0.analyticsLogID) }
            .map { AnalyticsEvent.update(isProcessing: processingstatus, event: $0) }

        inMemoryLogs = untouchedLogs + updatedLogs
        _ = analyticsCacheFile.update(inMemoryLogs)

        completionHandler?(nil)
    }

    func fetchAllLogsAndUpdateProcessingStatusToTrue(
        forLogsWithProcessingStatus processingStatus: Bool?,
        completionHandler: @escaping AnalyticsCompletionHandlerWithLogs
    ) {
        let filteredLogs = processingStatus
            .map { status in
                inMemoryLogs.filter { $0.isProcessing == status }
            } ?? inMemoryLogs
        let logIDs = filteredLogs.map(\.analyticsLogID)

        updateLogs(withIDs: logIDs, processingstatus: true, completionHandler: nil)

        completionHandler(filteredLogs, nil)
    }

    func fetchUnprocessed(top limit: Int) -> [AnalyticsEvent] {
        Array(inMemoryLogs.prefix(limit))
    }
}
