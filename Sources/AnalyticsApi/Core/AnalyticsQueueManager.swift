//
//  AnalyticsQueueManager.swift
//  AnalyticsApi
//
//  Created by Dees, Jason on 10/19/2020.
//
import Foundation

protocol AnalyticsQueueManagerProtocol {
    func save(event: AnalyticsEvent)
    func sendEvents() -> Bool
}

final class AnalyticsQueueManager {
    let settings: ApiSettings
    let persister: AnalyticsPersisterProtocol
    let communicator: AnalyticsCommunicatorProtocol
    let scheduler: SchedulerProtocol

    private(set) var failureCounter: Int = 0
    private(set) var isProcessing = false
    private(set) var isSchedulerDoingWork = false

    lazy var persistenceCompletion: AnalyticsCompletionHandler = { error in
        guard error == nil else {
            return
        }
        self.sendEventsCheck()
    }

    init(
        settings: ApiSettings,
        persister: AnalyticsPersisterProtocol,
        communicator: AnalyticsCommunicatorProtocol = AnalyticsCommunicator(),
        scheduler: SchedulerProtocol = Scheduler()
    ) {
        self.settings = settings
        self.persister = persister
        self.communicator = communicator
        self.scheduler = scheduler
        sendEventsCheck()
    }

    func sendEventsCheck() {
        if persister.logCount >= settings.preferredBatchSize && failureCounter == 0 {
            _ = sendEvents()
        } else if let timeInterval = settings.withTimeInterval, persister.logCount > 0, !isSchedulerDoingWork {
            isSchedulerDoingWork = true
            scheduler.schedule(interval: timeInterval) {
                self.isSchedulerDoingWork = false
                _ = self.sendEvents()
            }
        }
    }

    func handleResponse(with error: Error?, eventIds: [String]) {
        isProcessing = false
        if error == nil { // delete events
            successfulResponse(with: eventIds)
        } else if settings.maxRetries > failureCounter { // mark events as not processing
            failedResponse(with: eventIds)
        } else { // Delete bad events, start process again
            retryLimitReachedResponse(with: eventIds)
        }
    }

    func successfulResponse(with eventIds: [String]) {
        failureCounter = 0
        persister.deleteLogs(withIDs: eventIds, completionHandler: nil)
    }

    func failedResponse(with eventIds: [String]) {
        persister.updateLogs(withIDs: eventIds, processingstatus: false, completionHandler: nil)
        failureCounter += 1

        guard !isSchedulerDoingWork else {
            return
        }

        isSchedulerDoingWork = true
        scheduler.execute(retry: failureCounter) {
            self.isSchedulerDoingWork = false
            _ = self.sendEvents()
        }
    }

    func retryLimitReachedResponse(with eventIds: [String]) {
        // This is the same as a successfulResponse but I want to keep it separate.
        // It's conceptually different, done for different reasons
        failureCounter = 0
        persister.deleteLogs(withIDs: eventIds, completionHandler: nil)
    }
}

// MARK: - AnalyticsQueueManagerProtocol

extension AnalyticsQueueManager: AnalyticsQueueManagerProtocol {
    public func save(event: AnalyticsEvent) {
        persister.save(event, completion: persistenceCompletion)
    }

    func sendEvents() -> Bool {
        if isProcessing {
            return false
        }

        let events = persister.fetchUnprocessed(top: settings.preferredBatchSize)

        if !events.isEmpty {
            let eventIds = events.map(\.analyticsLogID)
            persister.updateLogs(withIDs: eventIds, processingstatus: true, completionHandler: nil)
            isProcessing = true
            let unprocessEvents = events.filter { $0.isProcessing == false }

            if !unprocessEvents.isEmpty {
                var url = settings.url
                if settings.labelRequests {
                    url = URL(string: "\(url.absoluteString)?\(events[0].label)")!
                }

                communicator.sendLogs(
                    analyticsLogs: events.filter { $0.isProcessing == false },
                    url: url,
                    headers: settings.requestHeaders,
                    completionHandler: { [weak self] error in
                        guard let self = self else { return }
                        self.handleResponse(with: error, eventIds: eventIds)
                    }
                )
            } else {
                handleResponse(with: nil, eventIds: eventIds)
            }
            return true
        }
        return false
    }
}
