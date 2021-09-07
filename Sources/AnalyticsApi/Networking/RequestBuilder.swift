import Foundation

enum RequestBuilder {
    case eventsPost(url: URL, headers: [AnalyticsRequestHeader])
}

extension RequestBuilder {
    var urlRequest: URLRequest {
        switch self {
        case .eventsPost(let url, let headers):
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            addHeadersFor(&request, headers: headers)
            return request
        }
    }

    private func addHeadersFor(_ request: inout URLRequest, headers: [AnalyticsRequestHeader]) {
        headers.forEach { header in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
    }
}
