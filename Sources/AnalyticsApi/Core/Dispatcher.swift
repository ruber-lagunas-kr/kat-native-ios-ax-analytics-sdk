import Foundation

protocol Dispatcher {
    func after(deadline: DispatchTime, execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: Dispatcher {
    func after(deadline: DispatchTime, execute work: @escaping @convention(block) () -> Void) {
        asyncAfter(deadline: deadline, execute: work)
    }
}
