//
//  SchedulerTests.swift
//
//
//  Created by Jason Dees on 10/21/20.
//

@testable import AnalyticsApi
import XCTest

private final class DispatcherSpy: Dispatcher {
    var expectation: XCTestExpectation?

    func after(deadline _: DispatchTime, execute work: @escaping @convention(block) () -> Void) {
        work()
        expectation?.fulfill()
    }
}

final class SchedulerTests: XCTestCase {
    private var queue: DispatcherSpy!
    private var scheduler: Scheduler!

    override func setUp() {
        super.setUp()
        queue = DispatcherSpy()
        scheduler = Scheduler(queue: queue)
    }

    override func tearDown() {
        queue = nil
        scheduler = nil
        super.tearDown()
    }

    func testExecuteRunsClosure() {
        queue.expectation = createExpectation(description: "'execute' runs closure", callCheck: .called(1))
        scheduler.execute(retry: 0, closure: {})
        wait(for: [queue.expectation!], timeout: 1)
    }

    func testScheduleExecutesAction() {
        queue.expectation = createExpectation(description: "'schedule' runs action", callCheck: .called(1))
        scheduler.schedule(interval: 1, action: {})
        wait(for: [queue.expectation!], timeout: 1)
    }
}
