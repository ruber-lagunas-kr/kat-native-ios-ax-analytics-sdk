@testable import AnalyticsApi
import XCTest

final class URLSessionMetricsTests: XCTestCase {
    func testSendLogsSuccess() {
        let mockResponse = HTTPURLResponse(url: URL(string: "test.kroger.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let expectedResult = MetricsRequestResult.success
        XCTAssertEqual(expectedResult, URLSession.processEventResponse(mockResponse))
    }

    func testSendLogsShouldReturnErrorFor502() {
        let mockResponse = HTTPURLResponse(url: URL(string: "test.kroger.com")!, statusCode: 502, httpVersion: nil, headerFields: nil)
        let expectedResult = MetricsRequestResult.error(MetricsRequestError.serviceError)
        XCTAssertEqual(expectedResult, URLSession.processEventResponse(mockResponse))
    }

    func testMalformedHTTPURLResponse() {
        let expectedResult = MetricsRequestResult.error(MetricsRequestError.malformedData)
        XCTAssertEqual(expectedResult, URLSession.processEventResponse(nil))
    }
}
