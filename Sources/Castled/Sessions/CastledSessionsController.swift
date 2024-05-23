//
//  CastledSessionsController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledSessionsController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledSessionsController()
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
    }

    func appDidBecomeActive() {
        if !CastledSessions.sharedInstance.userId.isEmpty {
            CastledSessionsManager.shared.didEnterForeground()
        }
    }

    @objc func appWillResignActive() {
        if !CastledSessions.sharedInstance.userId.isEmpty {
            CastledSessionsManager.shared.doTheBackgroundJobs()
        }
    }

    @objc func appDidEnterBackground() {
        if !CastledSessions.sharedInstance.userId.isEmpty {
            CastledSessionsManager.shared.didEnterBackground()
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledSessions.sharedInstance.userId = userId
        if CastledUserDefaults.shared.isAppInForeground {
            CastledSessionsManager.shared.startCastledSession()
        }
    }

    func onUserLoggedOut() {
        CastledSessions.sharedInstance.userId = ""
        CastledSessionsManager.shared.resetSessionDetails()
    }
}
