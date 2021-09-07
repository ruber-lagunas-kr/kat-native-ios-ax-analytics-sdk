//
//  AnalyticsQueueManagerTests.swift
//
//
//  Created by Jason Dees on 10/19/20.
//

@testable import AnalyticsApi
import XCTest

private class MockAnalyticsPersister: AnalyticsPersisterProtocol {
    var unprocessedLogs: [AnalyticsEvent] = []
    var fetchUnprocessedWasCalled = false
    func fetchUnprocessed(top _: Int) -> [AnalyticsEvent] {
        fetchUnprocessedWasCalled = true
        return unprocessedLogs
    }

    var event: AnalyticsEvent?
    var eventIDs: [String]?
    var processingStatus: Bool?
    var logCount = 0
    var deleteWasCalled = false
    func save(_: AnalyticsEvent, completion: @escaping AnalyticsCompletionHandler) {
        logCount += 1
        completion(nil)
    }

    func deleteLogs(withIDs logIDs: [String], completionHandler: AnalyticsCompletionHandler?) {
        eventIDs = logIDs
        completionHandler?(nil)
        deleteWasCalled = true
    }

    func updateLogs(withIDs logIDs: [String], processingstatus: Bool, completionHandler: AnalyticsCompletionHandler?) {
        eventIDs = logIDs
        processingStatus = processingstatus
        completionHandler?(nil)
    }

    func fetchAllLogsAndUpdateProcessingStatusToTrue(forLogsWithProcessingStatus processingStatus: Bool?, completionHandler: @escaping AnalyticsCompletionHandlerWithLogs) {
        self.processingStatus = processingStatus
        completionHandler([], nil)
    }
}

private class MockAnalyticsCommunicator: AnalyticsCommunicatorProtocol {
    var haveError = false
    var sendLogsTaskExecuted: (() -> Void)?

    var sentAnalyticsLogs: [AnalyticsEvent] = []
    var sentUrl: URL?
    var sentHeaders: [AnalyticsRequestHeader]?

    func sendLogs(analyticsLogs: [AnalyticsEvent], url: URL, headers: [AnalyticsRequestHeader], completionHandler: AnalyticsCompletionHandler?) {
        sentAnalyticsLogs = analyticsLogs
        sentUrl = url
        sentHeaders = headers

        sendLogsTaskExecuted?()

        completionHandler?(haveError ? MetricsRequestError.serviceError : nil)
    }
}

private struct FakeAnalyticsCacheFile: AnalyticsCacheFile {
    func read() -> Result<[AnalyticsEvent], Error> {
        .success([])
    }

    func update(_: [AnalyticsEvent]) -> Error? {
        nil
    }
}

private final class MockSettings: ApiSettings {
    var url = URL(string: "http://fake.com")!
    var maxRetries: Int = 18
    var userAgent: UserAgent = MockUserAgent()
    var preferredBatchSize: Int = 1
    var withTimeInterval: Double?
    var requestHeaders: [AnalyticsRequestHeader] = []
    var labelRequests: Bool = true
    var analyticsCacheFile: AnalyticsCacheFile = FakeAnalyticsCacheFile()
}

private class MockScheduler: SchedulerProtocol {
    var scheduleExpectation: XCTestExpectation?
    func schedule(interval _: Double, action: @escaping () -> Void) {
        action()
        scheduleExpectation?.fulfill()
    }

    var executeExpectation: XCTestExpectation?
    func execute(retry _: Int, closure: @escaping () -> Void) {
        closure()
        executeExpectation?.fulfill()
    }
}

// MARK: - AnalyticsQueueManagerTests

final class AnalyticsQueueManagerTests: XCTestCase {
    private var settings: MockSettings!
    private var persister: MockAnalyticsPersister!
    private var communicator: MockAnalyticsCommunicator!
    private var scheduler: MockScheduler!
    private var queueManager: AnalyticsQueueManager!

    override func setUp() {
        settings = MockSettings()
        persister = MockAnalyticsPersister()
        communicator = MockAnalyticsCommunicator()
        scheduler = MockScheduler()
        queueManager = AnalyticsQueueManager(
            settings: settings,
            persister: persister,
            communicator: communicator,
            scheduler: scheduler
        )
    }

    override func tearDown() {
        persister = nil
        communicator = nil
        settings = nil
        scheduler = nil
        queueManager = nil
        super.tearDown()
    }

    private func makeAnalyticsEvent(
        toEncode: [String: String],
        timestamp: Int64 = Date().timeStampInMiliseconds()
    ) throws -> AnalyticsEvent {
        let data = try JSONEncoder().encode(toEncode)
        let event = AnalyticsEvent(
            analyticsLogID: "",
            isProcessing: false,
            payload: data,
            timestamp: timestamp,
            label: "LABELA"
        )
        return event
    }
}

// MARK: - Test Cases

extension AnalyticsQueueManagerTests {
    func testSaveCallsIntoPersisterSave() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        XCTAssertEqual(persister.logCount, 0)
        queueManager.save(event: analyticsEvent)
        XCTAssertEqual(persister.logCount, 1)
    }

    func testSaveDoesNotCallSchedulerWhenSettingsTimeIntervalIsNil() throws {
        scheduler.scheduleExpectation = createExpectation(description: name, callCheck: .notCalled)

        // given
        let fakeEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        // when
        settings.preferredBatchSize = 2
        XCTAssertGreaterThan(settings.preferredBatchSize, 1)
        settings.withTimeInterval = nil
        // then
        queueManager.save(event: fakeEvent)

        wait(for: [scheduler.scheduleExpectation!], timeout: 1)
    }

    func testSaveCallsSchedulerWhenSettingsHasTimeIntervalSet() throws {
        scheduler.scheduleExpectation = createExpectation(description: name, callCheck: .called())

        // given
        let fakeEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        // when
        settings.preferredBatchSize = 2
        XCTAssertGreaterThan(settings.preferredBatchSize, 1)
        settings.withTimeInterval = 5
        // then
        queueManager.save(event: fakeEvent)

        wait(for: [scheduler.scheduleExpectation!], timeout: 1)
    }

    func testSchedulerGetsCalledOnManagerQueueInitWhenExistingLogs() {
        scheduler.scheduleExpectation = createExpectation(description: name, callCheck: .called(1))

        settings.withTimeInterval = 5
        settings.preferredBatchSize = 3
        XCTAssertGreaterThan(settings.preferredBatchSize, 1)
        persister.logCount = 2
        XCTAssertLessThan(persister.logCount, settings.preferredBatchSize)
        XCTAssertGreaterThan(persister.logCount, 0)

        queueManager = AnalyticsQueueManager(
            settings: settings,
            persister: persister,
            communicator: communicator,
            scheduler: scheduler
        )

        wait(for: [scheduler.scheduleExpectation!], timeout: 1)
    }

    func testWhenBatchLimitIsReachFetchUnprocessedLogsIsCalled() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        XCTAssertEqual(persister.logCount, 0)
        communicator.sendLogsTaskExecuted = {
            self.persister.logCount = 0
        }
        queueManager.save(event: analyticsEvent)
        XCTAssertTrue(persister.fetchUnprocessedWasCalled)
    }

    func testSendEventsPassesProperValuesToCommunicator() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        XCTAssertEqual(persister.logCount, 0)
        communicator.sendLogsTaskExecuted = {
            self.persister.logCount = 0
        }
        settings.labelRequests = false
        queueManager.save(event: analyticsEvent)
        XCTAssertEqual(settings.url, communicator.sentUrl)
        XCTAssertEqual(settings.requestHeaders.count, communicator.sentHeaders?.count)
        XCTAssertEqual(analyticsEvent.payload, communicator.sentAnalyticsLogs[0].payload)
    }

    func testSendEventsPassesEventLabelInUrlToCommunicator() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        XCTAssertEqual(persister.logCount, 0)
        communicator.sendLogsTaskExecuted = {
            self.persister.logCount = 0
        }
        queueManager.save(event: analyticsEvent)
        let url = URL(string: "\(settings.url.absoluteString)?\(analyticsEvent.label)")
        XCTAssertEqual(url, communicator.sentUrl)
        XCTAssertEqual(settings.requestHeaders.count, communicator.sentHeaders?.count)
        XCTAssertEqual(analyticsEvent.payload, communicator.sentAnalyticsLogs[0].payload)
    }

    func testSendEventsDeletesLogsOnCommunicatorSuccess() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        XCTAssertEqual(persister.logCount, 0)
        communicator.sendLogsTaskExecuted = {
            self.persister.logCount = 0
        }
        queueManager.save(event: analyticsEvent)
        XCTAssertTrue(persister.deleteWasCalled)
    }

    func testSendEventsIncrementsFailureConterOnCommunicatorFailure() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        communicator.haveError = true
        communicator.sendLogsTaskExecuted = {
            XCTAssertFalse(self.persister.deleteWasCalled)
            self.communicator.sendLogsTaskExecuted = {
                XCTAssertEqual(1, self.queueManager.failureCounter)
                self.communicator.haveError = false
                self.persister.logCount = 0
            }
        }
        XCTAssertEqual(persister.logCount, 0)
        queueManager.save(event: analyticsEvent)
    }

    func testSendEventsTriesAgainAfterCommunicatorFailure() throws {
        let expectedTimesCalled = 2
        var timesCalled = 0

        scheduler.executeExpectation = createExpectation(
            description: "'scheduler.execute' called \(expectedTimesCalled) times",
            callCheck: .called(expectedTimesCalled)
        )

        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]

        communicator.haveError = true
        communicator.sendLogsTaskExecuted = { // First retry
            if expectedTimesCalled == timesCalled {
                self.communicator.haveError = false
                self.persister.logCount = 0
                return
            }
            timesCalled += 1
        }
        XCTAssertEqual(persister.logCount, 0)

        queueManager.save(event: analyticsEvent)
        XCTAssertTrue(persister.deleteWasCalled)
        XCTAssertEqual(0, queueManager.failureCounter)

        wait(for: [scheduler.executeExpectation!], timeout: 1)
    }

    func testManagerCallsDeleteAfterFailureCounterReachesLimit() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        communicator.haveError = true
        var timesCalled = 0
        let expectedTimesCalled = 1
        communicator.sendLogsTaskExecuted = {
            if expectedTimesCalled == timesCalled {
                self.communicator.haveError = false
                self.persister.logCount = 0
                return
            }
            timesCalled += 1
        }
        settings.preferredBatchSize = 1
        settings.maxRetries = 1

        queueManager.save(event: analyticsEvent)
        XCTAssertTrue(persister.deleteWasCalled)
    }

    func testSendEventWillNotExecuteWhileIsProcessingIsTrue() throws {
        let analyticsEvent = try makeAnalyticsEvent(toEncode: ["Fake": "Fake"])
        persister.unprocessedLogs = [analyticsEvent]
        communicator.haveError = true
        var timesCalled = 0
        let expectedTimesCalled = 1
        communicator.sendLogsTaskExecuted = {
            // Cannot trigger WHILE another send is being triggered
            XCTAssertFalse(self.queueManager.sendEvents())
            if expectedTimesCalled == timesCalled {
                self.persister.logCount = 0
                return
            }
            timesCalled += 1
        }
        settings.preferredBatchSize = 1
        settings.maxRetries = 1

        // Can trigger once
        XCTAssertTrue(queueManager.sendEvents())
        // Can trigger once previous event is done
        XCTAssertTrue(queueManager.sendEvents())
    }
}
