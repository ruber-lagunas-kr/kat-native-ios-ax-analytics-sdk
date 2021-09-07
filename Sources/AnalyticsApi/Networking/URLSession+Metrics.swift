import Foundation

extension URLSession: ClickstreamSession {
    public func sendEvents(request: URLRequest, completion: @escaping (MetricsRequestResult) -> Void) {
        dataTask(with: request) { _, response, error in
            if let ioError = error as NSError? {
                URLSession.forceResultOnMainThread(.error(ioError), completion: completion)
                return
            }
            URLSession.forceResultOnMainThread(
                URLSession.processEventResponse(response as? HTTPURLResponse),
                completion: completion
            )
        }.resume()
    }

    internal static func processEventResponse(_ response: HTTPURLResponse?) -> MetricsRequestResult {
        switch response?.statusCode ?? -1 {
        case -1:
            return .error(MetricsRequestError.malformedData)
        case 200 ..< 501:
            return .success
        default:
            return .error(MetricsRequestError.serviceError)
        }
    }

    private static func forceResultOnMainThread(_ result: MetricsRequestResult, completion: @escaping (MetricsRequestResult) -> Void) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}
