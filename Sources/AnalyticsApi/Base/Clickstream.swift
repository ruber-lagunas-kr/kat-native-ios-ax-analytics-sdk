import Foundation

public struct Clickstream {
    let session: ClickstreamSession

    public init(session: ClickstreamSession = URLSession.shared) {
        self.session = session
    }

    public static var environment = Clickstream()
}
