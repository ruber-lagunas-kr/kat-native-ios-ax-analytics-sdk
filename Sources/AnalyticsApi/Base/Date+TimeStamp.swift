import Foundation

extension Date {
    func timeStampInMiliseconds() -> Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }
}
