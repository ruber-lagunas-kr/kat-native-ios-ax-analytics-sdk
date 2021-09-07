@testable import AnalyticsApi
import XCTest

final class UserAgentTests: XCTestCase {
    func testUserAgentStringValue() {
        let expectedValue = "test/test1.0/iOS"

        XCTAssertEqual(expectedValue, MockUserAgent().stringValue)
    }
}
