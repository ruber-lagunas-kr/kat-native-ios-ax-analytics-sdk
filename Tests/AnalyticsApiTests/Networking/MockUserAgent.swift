@testable import AnalyticsApi
import Foundation

struct MockUserAgent: UserAgent {
    var applicationName: String = "test"
    var applicationVersion: String = "test1.0"
}
