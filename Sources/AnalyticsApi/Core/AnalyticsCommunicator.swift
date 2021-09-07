import Foundation

final class AnalyticsCommunicator: AnalyticsCommunicatorProtocol {
    func sendLogs(
        analyticsLogs: [AnalyticsEvent],
        url: URL, headers: [AnalyticsRequestHeader],
        completionHandler: AnalyticsCompletionHandler? = nil
    ) {
        let analyticsLogsData = ["actions": analyticsLogs.map(\.payloadString.dictionaryValue)]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: analyticsLogsData, options: [])

            var request: URLRequest
            request = RequestBuilder.eventsPost(url: url, headers: headers).urlRequest
            request.httpBody = jsonData

            Clickstream.environment.session.sendEvents(request: request) { result in
                switch result {
                case .error(let error):
                    completionHandler?(error)
                case .success:
                    completionHandler?(nil)
                }
            }
        } catch {
            completionHandler?(MetricsRequestError.malformedData)
        }
    }
}
