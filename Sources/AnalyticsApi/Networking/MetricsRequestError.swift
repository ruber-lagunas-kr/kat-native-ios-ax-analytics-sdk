import Foundation

enum MetricsRequestError: Error {
    case malformedData
    case serviceError
    case metricsConfigurationError
}
