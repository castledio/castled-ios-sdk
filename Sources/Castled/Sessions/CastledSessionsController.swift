//
//  CastledSessionsController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledSessionsController: NSObject, CastledPreferenceStoreListener {
    static var sharedInstance = CastledSessionsController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    private func refreshSession() {
        if !CastledSessions.sharedInstance.userId.isEmpty, !isMakingApiCall {
            isMakingApiCall = true
            CastledInAppRepository.fetchInAppItems {
                self.isMakingApiCall = false
            }
        }
    }

    @objc public func appBecomeActive() {
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
