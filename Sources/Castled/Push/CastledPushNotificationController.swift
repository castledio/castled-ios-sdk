//
//  CastledPushNotificationController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledPushNotificationController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledPushNotificationController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initializePush() {
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
    }

    func appBecomeActive() {
        if !CastledPushNotification.sharedInstance.userId.isEmpty {
            Castled.sharedInstance.processAllDeliveredNotifications(shouldClear: false)
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledPushNotification.sharedInstance.userId = userId
    }

    func onUserLoggedOut() {}
}
