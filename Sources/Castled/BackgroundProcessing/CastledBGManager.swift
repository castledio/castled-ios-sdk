//
//  CastledBGManager.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation
import BackgroundTasks

class CastledBGManager {
    
    static let sharedInstance = CastledBGManager()
    private let castledConfig = CastledConfigs.sharedInstance
    private var isRegistered = false
    private var expirationHandler: (() -> Void)?
    
    private init() {}
    
    
    internal func registerBackgroundTasks() {
        if isRegistered { return }
        if #available(iOS 13.0, *) {
            isRegistered = true
            
            BGTaskScheduler.shared.register(forTaskWithIdentifier: castledConfig.permittedBGIdentifier, using: nil) { task in
                self.handleBackgroundTask(task: task as! BGProcessingTask)
            }
            startBackgroundTask()
        }
    }
    
    internal func executeBackgroundTask(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        let dispatchSemaphore = DispatchSemaphore(value: 1)
        
        dispatchGroup.enter()
        dispatchSemaphore.wait()
        
        CastledInApps.sharedInstance.fetchInAppNotificationWithCompletion { [weak self] in
            self?.retrySendingAllFailedEvents(dispatchGroup: dispatchGroup, dispatchSemaphore: dispatchSemaphore)
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
    private func retrySendingAllFailedEvents(dispatchGroup: DispatchGroup, dispatchSemaphore: DispatchSemaphore) {
        CastledRetryHandler.shared.retrySendingAllFailedEvents(completion: {
            dispatchSemaphore.signal()
            dispatchGroup.leave()
            
        })
    }
    
    private func handleBackgroundTask(task: BGProcessingTask) {
        if castledConfig.permittedBGIdentifier.count == 0{
            return;
        }
        expirationHandler = {
            
            task.setTaskCompleted(success: false)
            self.expirationHandler = nil
        }
        task.expirationHandler = expirationHandler
        
        scheduleNextTask()
        
        if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) != nil {
            task.setTaskCompleted(success: false)
            
        }
        else
        {
            executeBackgroundTask {
                task.setTaskCompleted(success: true)
                
            }
        }
        
    }
    
    private func getNewTaskRequest() -> BGProcessingTaskRequest{
        let taskRequest = BGProcessingTaskRequest(identifier: castledConfig.permittedBGIdentifier)
        taskRequest.requiresExternalPower = true
        taskRequest.requiresNetworkConnectivity = true
        
        taskRequest.earliestBeginDate = Date(timeIntervalSinceNow:TimeInterval(max(castledConfig.inAppFetchIntervalSec, 15*60)))
        
        return taskRequest
    }
    
    private func startBackgroundTask() {
        
        if castledConfig.permittedBGIdentifier.count == 0{
            return;
        }
        
        if checkBackgroundProcessingCapability() {
            stopBackgroundTask()
            let taskRequest = getNewTaskRequest()
            
            do {
                try BGTaskScheduler.shared.submit(taskRequest)
            } catch {
                castledLog("Error: ❌❌❌ \(CastledExceptionMessages.permittedIdentifiersNotInitialised.rawValue)")
            }
        } else {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.backgroundProcessNotenabled.rawValue)")
        }
    }
    
    private func stopBackgroundTask() {
        if (self.expirationHandler != nil){
            self.expirationHandler = nil
        }
        
        if #available(iOS 13.0, *) {
            
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: castledConfig.permittedBGIdentifier)
        }
        
    }
    private func scheduleNextTask() {
        
        let taskRequest = getNewTaskRequest()
        
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            print("Could not schedule background task: \(error)")
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.permittedIdentifiersNotInitialised.rawValue)")
            
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



