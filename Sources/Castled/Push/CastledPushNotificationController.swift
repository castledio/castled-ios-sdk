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

    func appDidBecomeActive() {
        if !CastledPushNotification.sharedInstance.userId.isEmpty {
            Castled.sharedInstance.processAllDeliveredNotifications(shouldClear: false)
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledPushNotification.sharedInstance.userId = userId
    }

    func onUserLoggedOut() {
        if CastledPushNotification.sharedInstance.userId.isEmpty {
            return
        }
        let params = [CastledConstants.PushNotification.userId: CastledPushNotification.sharedInstance.userId,
                      CastledConstants.PushNotification.Token.apnsToken: CastledUserDefaults.shared.apnsToken,
                      CastledConstants.PushNotification.Token.fcmToken: CastledUserDefaults.shared.fcmToken,
                      CastledConstants.Sessions.sessionId: CastledSessionsManager.shared.sessionId]
        CastledPushNotification.sharedInstance.logoutUser(params: params.compactMapValues { $0 } as [String: Any])
        CastledPushNotification.sharedInstance.userId = ""
    }
}
