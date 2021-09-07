@testable import AnalyticsApi
import XCTest

final class RequestConstructorTests: XCTestCase {
    fileprivate enum FakeRequestHeaders: AnalyticsRequestHeader {
        case accept
        case acceptEncoding
        case acceptLanguage
        case adobeTraceLogging
        case contentType
        case correlationId(UUID)
        case userAgent

        var key: String {
            switch self {
            case .accept:
                return "Accept"
            case .acceptEncoding:
                return "Accept-Encoding"
            case .acceptLanguage:
                return "Accept-Language"
            case .adobeTraceLogging:
                return "X-AdobeTraceLogging"
            case .contentType:
                return "Content-Type"
            case .correlationId:
                return "X-correlation-Id"
            case .userAgent:
                return "User-Agent"
            }
        }

        var value: String {
            switch self {
            case .accept:
                return "application/json"
            case .acceptEncoding:
                return "br, gzip, deflate"
            case .acceptLanguage:
                return "en-US;q=1"
            case .adobeTraceLogging:
                return ""
            case .contentType:
                return "application/json"
            case .correlationId(let identifier):
                return identifier.uuidString
            case .userAgent:
                return MockUserAgent().stringValue
            }
        }
    }

    func testEventPostHeaders() {
        let testURL = URL(string: "www.kroger.com")!
        let requiredHeaders: [FakeRequestHeaders] = [
            .accept,
            .acceptEncoding,
            .adobeTraceLogging,
            .acceptLanguage,
            .contentType,
            .userAgent,
            .correlationId(UUID()),
        ]
        let eventsPostRequest = RequestBuilder.eventsPost(url: testURL, headers: requiredHeaders).urlRequest
        requiredHeaders.forEach { header in
            XCTAssertTrue(
                (eventsPostRequest.allHTTPHeaderFields ?? [:]).keys.contains(header.key),
                "Missing \(header.key)"
            )
        }
        XCTAssertEqual("POST", eventsPostRequest.httpMethod)
        XCTAssertNotNil(eventsPostRequest.value(forHTTPHeaderField: FakeRequestHeaders.userAgent.key))
        XCTAssertNotNil(eventsPostRequest.value(forHTTPHeaderField: FakeRequestHeaders.correlationId(UUID()).key))
    }
}
