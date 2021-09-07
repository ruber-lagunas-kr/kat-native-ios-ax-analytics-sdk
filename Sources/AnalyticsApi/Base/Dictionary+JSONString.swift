import Foundation

extension Dictionary {
    func jsonString() -> String {
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8) ?? "error unwrapping json data to String"
        } catch {
            return "error converting to String"
        }
    }
}
