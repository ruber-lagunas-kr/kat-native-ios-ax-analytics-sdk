//
//  Scheduler.swift
//
//
//  Created by Jason Dees on 10/21/20.
//

import Foundation

protocol SchedulerProtocol {
    func execute(retry: Int, closure: @escaping () -> Void)
    func schedule(interval: Double, action: @escaping () -> Void)
}

final class Scheduler: SchedulerProtocol {
    let queue: Dispatcher

    init(queue: Dispatcher = DispatchQueue.main) {
        self.queue = queue
    }

    func execute(retry: Int, closure: @escaping () -> Void) {
        let jitter: Int = .random(in: 0 ... 500)
        let millisecondsDelay = Int(pow(2.0, Double(retry))) * 1000 + jitter
        queue.after(deadline: .now() + .milliseconds(millisecondsDelay), execute: closure)
    }

    func schedule(interval: Double, action: @escaping () -> Void) {
        queue.after(deadline: .now() + interval, execute: action)
    }
}
