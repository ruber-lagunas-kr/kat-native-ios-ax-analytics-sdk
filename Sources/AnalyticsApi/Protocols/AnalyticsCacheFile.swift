public protocol AnalyticsCacheFile {
    func read() -> Result<[AnalyticsEvent], Swift.Error>
    func update(_ events: [AnalyticsEvent]) -> Swift.Error?
}
