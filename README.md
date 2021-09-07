## Analytics Api

This is the communication library for the Analytics SDK. `Data` are submitted to an instance of an `AnalyticsLogicController` which then saves the request using Bedrock as a sort of queue to send the request the Clickstream service. 

### How to Use It

Instantiate `AnalyticsLogicController` with an instance of `ApiSettings`. Using the instance of `AnalyticsLogicController`, call the `logEvent` func that takes a JSON `Data` representation of a scenario and associated data.

### The Guts

1. `AnalyticsLogicController.logEvent` is called
* The environment is determined from `ApiSettings`. It has no concept of test or prod, only a url and a route to send requests to
2. Calls `AnalyticsQueueManager.save`
3. Calls `AnalyticsPersister.save`, which saves it to the disk
4. `AnalyticsQueueManager` checks to see if batch limit is reached, the `preferredBatchSize` setting from the `ApiSettings`.
* If limit is reach, send `preferredBatchSize` events
* If limit is not reached, do nothing
5. `AnalyticsQueueManager` may have a timer set up, based on `withTimeInterval` setting. On trigger, it sends events, if any, at a max of `preferredBatchSize` at a time
6. If a request fails, `AnalyticsQueueManager` waits 2 to the `failedCounter` seconds, an exponential back off algorithm, before trying again.
7. When the `failedCounter` reaches `ApiSettings.maxRetries`, the events trying to be sent are thrown away.
8. Cycle starts again with `AnalyticsQueueManager`

