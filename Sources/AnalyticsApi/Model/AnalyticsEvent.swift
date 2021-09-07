import Foundation

public struct AnalyticsEvent: Codable {
    let analyticsLogID: String
    let isProcessing: Bool
    let timestamp: Int64
    let payload: Data
    let label: String
    var payloadString: String {
        String(data: payload, encoding: .utf8) ?? "[]"
    }

    init(analyticsLogID: String = UUID().uuidString, isProcessing: Bool, payload: Data, timestamp: Int64, label: String) {
        self.analyticsLogID = analyticsLogID
        self.isProcessing = isProcessing
        self.timestamp = timestamp
        self.payload = payload
        self.label = label
    }
}

extension AnalyticsEvent {
    static func make(
        payload: Data,
        timestamp: Int64,
        label: String,
        logID: String = UUID().uuidString
    ) -> AnalyticsEvent {
        AnalyticsEvent(
            analyticsLogID: logID,
            isProcessing: false,
            payload: payload,
            timestamp: timestamp,
            label: label
        )
    }
}

extension AnalyticsEvent {
    static func update(isProcessing: Bool, event: AnalyticsEvent) -> AnalyticsEvent {
        AnalyticsEvent(
            analyticsLogID: event.analyticsLogID,
            isProcessing: isProcessing,
            payload: event.payload,
            timestamp: event.timestamp,
            label: event.label
        )
    }
}
