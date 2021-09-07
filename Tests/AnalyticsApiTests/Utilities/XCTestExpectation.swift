import XCTest

enum ExpectationCheck {
    case called(_ count: Int = 1)
    case notCalled
}

func createExpectation(
    description: String,
    callCheck: ExpectationCheck
) -> XCTestExpectation {
    let expectation = XCTestExpectation(description: description)

    switch callCheck {
    case .called(let count):
        expectation.expectedFulfillmentCount = count
    case .notCalled:
        expectation.isInverted = true
    }

    return expectation
}
