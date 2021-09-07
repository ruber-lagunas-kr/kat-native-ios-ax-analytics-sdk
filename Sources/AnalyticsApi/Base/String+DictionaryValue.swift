import Foundation

extension String {
    var dictionaryValue: [String: Any] {
        (
            try? JSONSerialization
                .jsonObject(with: Data(utf8), options: .allowFragments) as? [String: Any]
        ) ?? [String: Any]()
    }
}
