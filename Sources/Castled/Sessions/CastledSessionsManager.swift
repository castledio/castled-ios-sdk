//
//  CastledSessionsManager.swift
//  Castled
//
//  Created by antony on 02/02/2024.
//

import Foundation

class CastledSessionsManager {
    static let shared = CastledSessionsManager()

    lazy var sessionId = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionId) as? String ?? ""
    private lazy var sessionStartTime = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionStartTime) as? Double ?? Date().timeIntervalSince1970
    private lazy var lastSessionEndTime = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledLastSessionEndTime) as? Double ?? 0
    private lazy var
        sessionDuration = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledSessionDuration) as? Double ?? 0
    private lazy var isFirstLaunch = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledIsFirstSesion) ?? 1
    private var currentStartTime: Double = 0

    private init() {}

    func startCastledSession() {
        Castled.sharedInstance.castledCommonQueue.async {
            if !self.isInCurrentSession() {
                self.createNewSession()
            }
            self.saveTheValues()
        }
    }

    private func createNewSession() {
        var sessionDetails = [[String: Any]]()
        if !sessionId.isEmpty {
            sessionDetails.append([CastledConstants.Sessions.sessionId: sessionId,
                                   CastledConstants.Sessions.sessionType: CastledConstants.Sessions.sessionClosed,
                                   CastledConstants.Sessions.sessionLastDuration: sessionDuration,
                                   CastledConstants.Sessions.sessionEndTime: lastSessionEndTime == 0 ? Date().timeIntervalSince1970 : lastSessionEndTime,
                                   CastledConstants.Sessions.sessionStartTime: sessionStartTime,
                                   CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.sessionTracking.rawValue])
            CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledIsFirstSesion, 0)
        }

        sessionId = getSessionId()
        sessionDuration = 0
        sessionStartTime = Date().timeIntervalSince1970
        currentStartTime = sessionStartTime

        sessionDetails.append([CastledConstants.Sessions.sessionId: sessionId,
                               CastledConstants.Sessions.sessionType: CastledConstants.Sessions.sessionStarted,
                               CastledConstants.Sessions.sessionStartTime: currentStartTime,
                               CastledConstants.Sessions.sessionisFirstSession: isFirstLaunch,
                               CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.sessionTracking.rawValue])
        print("sessionDetails ------> \(sessionDetails)")
    }

    private func saveTheValues() {
        CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledSessionId, sessionId)
        CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledSessionStartTime, currentStartTime)
        CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledSessionDuration, 0)
        CastledUserDefaults.removeFor(CastledUserDefaults.kCastledLastSessionEndTime)
    }

    private func isInCurrentSession() -> Bool {
        return sessionId.isEmpty || (Date().timeIntervalSince1970 - lastSessionEndTime) <= CastledConfigsUtils.sessionTimeOutSec
    }

    func didEnterBackground() {
        if CastledUserDefaults.shared.userId == nil || !CastledConfigsUtils.enableSessionTracking {
            return
        }
        let currentTime = Date().timeIntervalSince1970
        sessionDuration += currentTime - currentStartTime
        CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledSessionDuration, sessionDuration)
        CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledLastSessionEndTime, currentTime)
    }

    func didEnterForeground() {
        if CastledUserDefaults.shared.userId == nil || !CastledConfigsUtils.enableSessionTracking {
            return
        }
        startCastledSession()
    }

    private func getSessionId() -> String {
        return UUID().uuidString
    }
}
