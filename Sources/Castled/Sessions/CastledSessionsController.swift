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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    func appBecomeActive() {
        if !CastledSessions.sharedInstance.userId.isEmpty {
            CastledSessionsManager.shared.didEnterForeground()
        }
    }

    @objc public func didEnterBackground() {
        if !CastledSessions.sharedInstance.userId.isEmpty {
            CastledSessionsManager.shared.didEnterBackground()
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledSessions.sharedInstance.userId = userId
        CastledSessionsManager.shared.startCastledSession()
    }

    func onUserLoggedOut() {
        CastledSessionsManager.shared.resetSessionDetails()
    }
}
