//
//  CastledBGManager.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import BackgroundTasks
import Foundation

class CastledBGManager {
    static let sharedInstance = CastledBGManager()
    private var isRegistered = false
    private var isExecuting = false

    private var expirationHandler: (() -> Void)?

    private init() {}

    /*   private func registerBackgroundTasks() {
         if isRegistered { return }
         if #available(iOS 13.0, *) {
             isRegistered = true
             BGTaskScheduler.shared.register(forTaskWithIdentifier: CastledConfigsUtils.configs.permittedBGIdentifier, using: nil) { task in
                 self.handleBackgroundTask(task: task as! BGProcessingTask)
             }
             startBackgroundTask()
         }
     }*/

    func executeBackgroundTask(completion: @escaping () -> Void) {
        if isExecuting {
            return
        }
        isExecuting = true
        CastledRetryHandler.shared.retrySendingAllFailedEvents(completion: { [weak self] in
            self?.isExecuting = false
        })
    }

    private func handleBackgroundTask(task: BGProcessingTask) {
        if CastledConfigsUtils.configs.permittedBGIdentifier.isEmpty {
            return
        }
        expirationHandler = {
            task.setTaskCompleted(success: false)
            self.expirationHandler = nil
        }
        task.expirationHandler = expirationHandler
        scheduleNextTask()
        if CastledUserDefaults.shared.userId == nil || Castled.sharedInstance.instanceId.isEmpty {
            task.setTaskCompleted(success: false)

        } else {
            executeBackgroundTask {
                task.setTaskCompleted(success: true)
            }
        }
    }

    private func getNewTaskRequest() -> BGProcessingTaskRequest {
        let taskRequest = BGProcessingTaskRequest(identifier: CastledConfigsUtils.configs.permittedBGIdentifier)
        taskRequest.requiresExternalPower = true
        taskRequest.requiresNetworkConnectivity = true
        taskRequest.earliestBeginDate = Date(timeIntervalSinceNow: TimeInterval(max(CastledConfigsUtils.configs.inAppFetchIntervalSec, 15 * 60)))
        return taskRequest
    }

    private func startBackgroundTask() {
        if CastledConfigsUtils.configs.permittedBGIdentifier.isEmpty {
            return
        }
        if checkBackgroundProcessingCapability() {
            stopBackgroundTask()
            let taskRequest = getNewTaskRequest()

            do {
                try BGTaskScheduler.shared.submit(taskRequest)
            } catch {
                CastledLog.castledLog("\(CastledExceptionMessages.permittedIdentifiersNotInitialised.rawValue)", logLevel: CastledLogLevel.debug)
            }
        } else {
            CastledLog.castledLog("\(CastledExceptionMessages.backgroundProcessNotenabled.rawValue)", logLevel: CastledLogLevel.debug)
        }
    }

    private func stopBackgroundTask() {
        if expirationHandler != nil {
            expirationHandler = nil
        }
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: CastledConfigsUtils.configs.permittedBGIdentifier)
        }
    }

    private func scheduleNextTask() {
        let taskRequest = getNewTaskRequest()
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            CastledLog.castledLog("\(CastledExceptionMessages.permittedIdentifiersNotInitialised.rawValue)", logLevel: CastledLogLevel.debug)
        }
    }

    private func checkBackgroundProcessingCapability() -> Bool {
        if #available(iOS 13.0, *) {
            let backgroundModes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
            return backgroundModes?.contains("processing") ?? false
        }
        return false
    }
}
