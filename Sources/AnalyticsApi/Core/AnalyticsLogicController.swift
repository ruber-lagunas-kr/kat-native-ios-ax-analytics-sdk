import Foundation

typealias AnalyticsCompletionHandler = (Error?) -> Void
public typealias ClickstreamData = [String: Any]

public final class AnalyticsLogicController: AnalyticsLogicControllerProtocol {
    let queueManager: AnalyticsQueueManagerProtocol

    public convenience init(settings: ApiSettings) {
        self.init(
            queueManager: AnalyticsQueueManager(settings: settings, persister: AnalyticsPersister(settings.analyticsCacheFile))
        )
    }

    init(queueManager: AnalyticsQueueManagerProtocol) {
        self.queueManager = queueManager
    }

    public func logEvent(actionPayload: Data, labeled label: String = "") {
        let event = AnalyticsEvent.make(
            payload: actionPayload,
            timestamp: Date().timeStampInMiliseconds(),
            label: label
        )
        queueManager.save(event: event)
    }
}
