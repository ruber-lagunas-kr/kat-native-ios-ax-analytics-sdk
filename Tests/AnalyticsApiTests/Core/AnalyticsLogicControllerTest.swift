@testable import AnalyticsApi
import XCTest

private class MockQueueManager: AnalyticsQueueManagerProtocol {
    func sendEvents() -> Bool {
        false
    }

    var saveSpec: XCTestExpectation?
    func save(event _: AnalyticsEvent) {
        saveSpec?.fulfill()
    }
}

final class AnalyticsLogicControllerTest: XCTestCase {
    var analyticsLogicController: AnalyticsLogicController!
    private var mockQueueManager: MockQueueManager!

    let timestamp = Date()
    func payload() throws -> Data {
        try JSONEncoder().encode(["key": "value"])
    }

    override func setUp() {
        super.setUp()
        mockQueueManager = MockQueueManager()
        analyticsLogicController = AnalyticsLogicController(queueManager: mockQueueManager)
    }

    override func tearDown() {
        analyticsLogicController = nil
        mockQueueManager = nil
        super.tearDown()
    }

    func testLogEventSavesDataToDataController() {
        let spec = expectation(description: "save")
        mockQueueManager.saveSpec = spec
        do {
            analyticsLogicController.logEvent(actionPayload: try payload())
        } catch {}
        wait(for: [spec], timeout: 1)
    }
}
