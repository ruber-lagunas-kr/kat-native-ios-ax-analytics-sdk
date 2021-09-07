import Foundation

public protocol ApiSettings: AnyObject {
    /// The URL for where event HTTP requests get sent
    var url: URL { get }
    /// Maximum number of retries a series of events will get retried before being deleted so other events can be processed.
    var maxRetries: Int { get }
    /// A string attached as a header to each HTTP request sent
    var userAgent: UserAgent { get }
    /// How many events can be queued up before being sent to the server. Can be used in conjuction with `withTimeInterval`
    var preferredBatchSize: Int { get }
    /// Optional value to determine how long between requests being sent. Should be used in conjuction with `preferredBatchSize`
    var withTimeInterval: Double? { get }
    /// A list of request headers that should be appended to each request
    var requestHeaders: [AnalyticsRequestHeader] { get }
    /// Takes the `labeled` field from the AnalyticsLogicController and appends it to the URL
    var labelRequests: Bool { get }
    /// The reference file used for persistence
    var analyticsCacheFile: AnalyticsCacheFile { get }
}
