import Foundation

public protocol ClickstreamSession {
    func sendEvents(request: URLRequest, completion: @escaping (MetricsRequestResult) -> Void)
}
