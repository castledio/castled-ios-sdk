//
//  CastledSessionsManager.swift
//  Castled
//
//  Created by antony on 02/02/2024.
//

import Foundation
import UIKit

class CastledSessionsManager {
    static let shared = CastledSessionsManager()

    lazy var sessionId = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionId) as? String ?? ""
    private lazy var sessionStartTime = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionStartTime) as? Double ?? Date().timeIntervalSince1970
    private lazy var sessionEndTime = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledLastSessionEndTime) as? Double ?? 0
    private lazy var
        sessionDuration = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionDuration) as? Double ?? 0
    private lazy var isFirstSession = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledIsFirstSesion) ?? true
    private var currentStartTime: Double = 0
    private let sessionTrackingQueue = DispatchQueue(label: "CastledSessionsTrackingQueue", attributes: .concurrent)
    private var isSaving = false
    private init() {}

    func startCastledSession() {
        sessionTrackingQueue.async(flags: .barrier) { [self] in
            currentStartTime = Date().timeIntervalSince1970
            if !self.isInCurrentSession() {
                self.createNewSession()
                self.resetTheValuesForNewSession()
            } else {
                CastledLog.castledLog("Resuming session '\(sessionId)'", logLevel: CastledLogLevel.info)
            }
        }
    }

    private func isInCurrentSession() -> Bool {
        return sessionEndTime != 0.0 && ((Date().timeIntervalSince1970 - sessionEndTime) <= Double(CastledConfigsUtils.configs.sessionTimeOutSec))
    }

    private func createNewSession() {
        var sessionDetails = [[String: Any]]()
        if !sessionId.isEmpty {
            let dateEnded = Date(timeIntervalSince1970: sessionEndTime == 0 ? Date().timeIntervalSince1970 : sessionEndTime)
            sessionDetails.append([CastledConstants.Sessions.userId: CastledSessions.sharedInstance.userId,
                                   CastledConstants.Sessions.sessionId: sessionId,
                                   CastledConstants.Sessions.sessionType: CastledConstants.Sessions.sessionClosed,
                                   CastledConstants.Sessions.sessionLastDuration: Int(min(sessionDuration, Double(Int32.max))),
                                   CastledConstants.Sessions.sessionTimeStamp: dateEnded.string(),
                                   CastledConstants.Sessions.properties: [CastledConstants.Sessions.deviceId: CastledCommonClass.getDeviceId()]])
            CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledIsFirstSesion, false)
            isFirstSession = false
        }

        sessionId = getSessionId()
        sessionDuration = 0
        sessionStartTime = Date().timeIntervalSince1970
        currentStartTime = sessionStartTime
        sessionEndTime = sessionStartTime
        let dateStarted = Date(timeIntervalSince1970: currentStartTime)

        sessionDetails.append([CastledConstants.Sessions.userId: CastledSessions.sharedInstance.userId,
                               CastledConstants.Sessions.sessionId: sessionId,
                               CastledConstants.Sessions.sessionType: CastledConstants.Sessions.sessionStarted,
                               CastledConstants.Sessions.sessionTimeStamp: dateStarted.string(),
                               CastledConstants.Sessions.sessionisFirstSession: isFirstSession,
                               CastledConstants.Sessions.properties: [CastledConstants.Sessions.deviceId: CastledCommonClass.getDeviceId()]])
        CastledSessions.sharedInstance.reportSessionEvents(params: sessionDetails)
        CastledLog.castledLog("reportSessionEvents \(sessionDetails)", logLevel: .info)
    }

    private func resetTheValuesForNewSession() {
        let userDefaults = CastledUserDefaults.getUserDefaults()
        userDefaults.setValue(sessionId, forKey: CastledUserDefaults.kCastledSessionId)
        userDefaults.setValue(0, forKey: CastledUserDefaults.kCastledSessionDuration)
        userDefaults.setValue(currentStartTime, forKey: CastledUserDefaults.kCastledSessionStartTime)
        userDefaults.setValue(currentStartTime, forKey: CastledUserDefaults.kCastledLastSessionEndTime)
        userDefaults.synchronize()
    }

    func didEnterBackground() {
        if isSaving {
            return
        }
        isSaving = true
        let application = UIApplication.shared
        var backgroundTask: UIBackgroundTaskIdentifier?
        backgroundTask = application.beginBackgroundTask(withName: "com.castled.sessiontracking") {
            if backgroundTask != nil { backgroundTask! = .invalid }
        }
        doTheBackgroundJobs()

        if let bgTask = backgroundTask {
            application.endBackgroundTask(bgTask)
        }
        isSaving = false
    }

    func doTheBackgroundJobs() {
        sessionTrackingQueue.sync {
            sessionEndTime = Date().timeIntervalSince1970
            sessionDuration += sessionEndTime - currentStartTime
            currentStartTime = sessionEndTime
            let userDefaults = CastledUserDefaults.getUserDefaults()
            userDefaults.setValue(sessionDuration, forKey: CastledUserDefaults.kCastledSessionDuration)
            userDefaults.setValue(sessionEndTime, forKey: CastledUserDefaults.kCastledLastSessionEndTime)
            userDefaults.synchronize()
            CastledLog.castledLog("sessionId \(sessionId) lastSessionEndTime \(sessionEndTime) sessionDuration \(sessionDuration) currentStartTime \(currentStartTime)", logLevel: .info)
        }
    }

    func didEnterForeground() {
        startCastledSession()
    }

    private func getSessionId() -> String {
        return CastledCommonClass.getUniqueString()
    }

    func resetSessionDetails() {
        let userDefaults = CastledUserDefaults.getUserDefaults()
        userDefaults.removeObject(forKey: CastledUserDefaults.kCastledSessionId)
        userDefaults.removeObject(forKey: CastledUserDefaults.kCastledSessionDuration)
        userDefaults.removeObject(forKey: CastledUserDefaults.kCastledLastSessionEndTime)
        userDefaults.removeObject(forKey: CastledUserDefaults.kCastledSessionStartTime)
        userDefaults.removeObject(forKey: CastledUserDefaults.kCastledIsFirstSesion)
        userDefaults.synchronize()
        sessionId = ""
        sessionEndTime = 0.0
        sessionDuration = 0
        isFirstSession = true
    }
}
