import Foundation

public protocol UserAgent {
    var applicationName: String { get }
    var applicationVersion: String { get }
}

public extension UserAgent {
    var stringValue: String {
        "\(applicationName)/\(applicationVersion)/iOS"
    }
}
