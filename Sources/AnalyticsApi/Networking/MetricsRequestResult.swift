import Foundation

public enum MetricsRequestResult {
    case success
    case error(Error)
}

extension MetricsRequestResult: Equatable {
    private var value: Int {
        switch self {
        case .success:
            return 0
        case .error:
            return 1
        }
    }

    public static func == (lhs: MetricsRequestResult, rhs: MetricsRequestResult) -> Bool {
        lhs.value == rhs.value
    }
}
