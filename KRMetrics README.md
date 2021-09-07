## How to Use

### Installing
You can install AnalyticsApi in your project via Swift Package Manager.  Installing AnalyticsApi requires connection to Kroger's network since the repository is hosted internally. Add the following `https://gitlab.kroger.com/JD26163/ios-analytics-api.git` to your Package.swift. 

### Initializing and Configuration
It is recommened that at an early point in your application lifecycle to configure the AnalyticsApi SDK to handle the consumption of events. Here are some things that are needed to configure. A good approach might be to configure a delegate class to handle these needs for you and make it a dependency upon your application delegate.

#### Delegates
The AnalyticsApi utilizes a delegate pattern in order to provide essential configuration needs. When configuring KRMetrics you will pass the Clickstream Delegate into the `KRMetrics.configureMetrics(with: )` function. 

#### Sending Events
Events can be sent from the client applciation via `KRMetrics.logEvent(variables:)`.


## How KRMetrics works

1. `KRMetricsLogicController.logEvent` is called, with `MetricsSetup` being set as `KRMetricsLogicController`'s `ClickstreamDelegate`
* This clickstream delegate determines what the environment is, the userAgent, the preferredBatch size, metadata. This is `MetricsSetup`
2. Func injects metadata and some other stuff into it
3. Calls `KRMetricsDataController.save` with a completion handler `KRMetricsLogicController.persistenceCompletion`
4. `KRMetricsDataController.save` calls `KRMetricsPersister.save` and passes the event and the completion handler down to the func call
5. `KRMetricsPersister.save` appends the event to an in-memory log and saves that log to disk with Bedrock
6. Passed completion handler is triggered from `KRMetricsLogicController.persistenceCompletion`
7. `KRMetricsLogicController.persistenceCompletion` creates  `KRMetricsCountBasedScheduler` and calls `KRMetricsCountBasedScheduler.notify`
8. `KRMetricsCountBasedScheduler.notify` triggers `KRMetricsSchedulerDelegate.executeTask` when the threshold/batchsize is reached (1 currently). This func is implemented on `KRMetricsLogicController`
9. `KRMetricsLogicController.executeTask` calls `KRMetricsLogicController.sendLogs`
10. `KRMetricsLogicController.sendLogs` calls `KRMetricsDataController.fetchAllLogsAndUpdateProcessingStatusToTrue` with a closure as a completion handler
* Closure builds url, user agent and sends to `KRMetricsLogsBatcher.sendEventsToCommunicator` with the those parameters and a nil completion handler
11. `KRMetricsDataController.fetchAllLogsAndUpdateProcessingStatusToTrue` gathers processed or unprocessed logs and passes them to the completion handler closure
12. `KRMetricsLogsBatcher.sendEventsToCommunicator` takes the gathered url, user agent and logs, splits the logs into a size of batch size, which is 10 in this case. For each 10 logs, it sends them to `KRMetricsCommunicator.sendLogs` with the url, user agent and completion handler closure. If there is no error it deletes the logs. If there is an error it marks the logs as not processed.
13. `KRMetricsCommunicator.sendLogs` takes the `KRMetricsEvent`s turns it ino an array of actions that gets serialized into JSON data. Creates a `URLRequest` with `MetricsRequestBuilder` and attaches the json data to the created request. The request is sent via a `URLSession.shared` variable that is set at `Clickstream.session`. The completion handler is called.
