//
//  Castled.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UIKit
import UserNotifications

@objc public protocol CastledNotificationDelegate {
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any])
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, buttonAction: CastledButtonAction, userInfo: [AnyHashable: Any])
    @objc optional func didReceiveCastledRemoteNotification(withInfo userInfo: [AnyHashable: Any])
}

@objc public class Castled: NSObject {
    @objc public static var sharedInstance = Castled()

    var instanceId = CastledConfigsUtils.appId ?? ""
    var delegate: CastledNotificationDelegate?
    var clientRootViewController: UIViewController?
    private var isInitialized = false
    // Create a dispatch queue
    let castledCommonQueue = DispatchQueue(label: "CastledCommonQueue", qos: .background)
    let castledNotificationQueue = DispatchQueue(label: "CastledNotificationQueue", qos: .userInteractive)
    let castledProfileQueue = DispatchQueue(label: "CastledProfileQueue", qos: .userInitiated, attributes: .concurrent)

    // Create a semaphore
    private let castledSemaphore = DispatchSemaphore(value: 1)

    override private init() {}

    /**
     Static method for conguring the Castled framework.
     */
    @objc public static func initialize(withConfig config: CastledConfigs, andDelegate delegate: CastledNotificationDelegate?) {
        if config.instanceId.isEmpty {
            fatalError("'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id.")
        }
        Castled.sharedInstance.instanceId = config.instanceId
        Castled.sharedInstance.isInitialized = true
        if let castledDelegate = delegate {
            Castled.sharedInstance.delegate = castledDelegate
        }
        CastledConfigsUtils.saveTheConfigs(config: config)
        Castled.sharedInstance.initialSetup()
    }

    private func initialSetup() {
        let config = CastledConfigs.sharedInstance
        CastledLog.setLogLevel(config.logLevel)
        #if !DEBUG
        CastledLog.setLogLevel(CastledLogLevel.none)
        #endif
        CastledLog.castledLog("SDK \(CastledCommonClass.getSDKVersion()) initialized..", logLevel: .debug)

        if config.enablePush {
            CastledPushNotification.sharedInstance.initializePush()
        }
        if config.enableInApp {
            CastledInApp.sharedInstance.initializeInApp()
        }
        if config.enableSessionTracking {
            CastledSessions.sharedInstance.initializeSessions()
        }
        if config.enableTracking {
            CastledEventsTracker.sharedInstance.initializeEventsTracking()
        }
        CastledDeviceInfo.sharedInstance.initializeDeviceInfo()

        CastledNetworkMonitor.shared.startMonitoring()
        CastledLifeCycleManager.sharedInstance.start()

//        CastledUserEventsTracker.shared.setInitialLaunchEventDetails()
        setNotificationCategories(withItems: Set<UNNotificationCategory>())
        checkAndRegisterForAPNsToken()
    }

    @objc public func isCastledInitialized() -> Bool {
        return isInitialized
    }

    /**
     Function that allows users to set the userId and  userToken.
     */
    @objc public func setUserId(_ userId: String, userToken: String? = nil) {
        if !Castled.sharedInstance.isCastledInitialized() {
            fatalError("'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id.")
        }
        Castled.sharedInstance.saveUserId(userId, userToken)
    }

    /**
     Function that allows users to set the PushNotifiication token.
     */
    @objc public func setPushToken(_ token: String, _ type: CastledPushTokenType = .apns) {
        castledProfileQueue.async(flags: .barrier) {
            if type == .apns {
                let oldToken = CastledUserDefaults.shared.apnsToken ?? ""
                if token == oldToken {
                    return
                }
                CastledUserDefaults.shared.apnsToken = token
                CastledUserDefaults.setString(CastledUserDefaults.kCastledAPNsTokenKey, token)
            } else {
                let oldToken = CastledUserDefaults.shared.fcmToken ?? ""
                if token == oldToken {
                    return
                }
                CastledUserDefaults.shared.fcmToken = token
                CastledUserDefaults.setString(CastledUserDefaults.kCastledFCMTokenKey, token)
            }
            if let uid = CastledUserDefaults.shared.userId {
                Castled.sharedInstance.updateTheUserIdAndToken(uid, apns: CastledUserDefaults.shared.apnsToken, fcm: CastledUserDefaults.shared.fcmToken)
                CastledDeviceInfo.sharedInstance.updateDeviceInfo()
            }
        }
    }

    /**
     InApps : Function that allows to display page view inapp
     */
    @objc public func logAppPageViewedEvent(_ viewContoller: UIViewController) {
        guard let _ = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Log page viewed \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInApp.sharedInstance.logAppPageViewedEvent(viewContoller)
    }

    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(_ eventName: String, params: [String: Any]) {
        CastledInApp.sharedInstance.logCustomAppEvent(eventName, params: params)
        CastledEventsTracker.sharedInstance.trackEvent(eventName: eventName, params: params)
    }

    @objc public func setUserAttributes(_ attributes: CastledUserAttributes) {
        CastledEventsTracker.sharedInstance.setUserAttributes(attributes)
    }

    @objc public func logout() {
        if let userId = CastledUserDefaults.shared.userId {
            DispatchQueue.main.async {
                CastledUserDefaults.clearAllFromPreference()
                CastledLog.castledLog("\(userId) has been logged out successfully.", logLevel: .info)
            }
        }
    }

    @objc public func setLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if !Castled.sharedInstance.isCastledInitialized() {
            fatalError("'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id.")
        }

        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
           notification["aps"] as? [String: AnyObject] != nil
        {
            Castled.sharedInstance.processCastledPushEvents(userInfo: notification, isOpened: true)
        }
        //  CastledBGManager.sharedInstance.registerBackgroundTasks()
    }

    @objc public func setNotificationCategories(withItems items: Set<UNNotificationCategory>) {
        if !Castled.sharedInstance.isCastledInitialized() {
            fatalError("'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id.")
        }
        var categorySet = items
        categorySet.insert(getCastledCategory())
        UNUserNotificationCenter.current().setNotificationCategories([])
        UNUserNotificationCenter.current().setNotificationCategories(categorySet)
    }

    /**
     Function that allows users to set the badge on the app icon manually.
     */
    func setBadge(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }

    @objc func executeBGTasks() {
        CastledBGManager.sharedInstance.executeBackgroundTask {}
    }

    func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if CastledConfigsUtils.configs.enableInApp == false {
            return
        }
        CastledInApp.sharedInstance.logAppOpenedEventIfAny(showLog: showLog)
    }

    /**
     Funtion which alllows to register the User & Token with Castled.
     */
    private func saveUserId(_ userId: String, _ userToken: String? = nil) {
        castledProfileQueue.async(flags: .barrier) {
            let existingUserId = CastledUserDefaults.shared.userId
            CastledUserDefaults.setString(CastledUserDefaults.kCastledUserIdKey, userId)
            if let secureUserId = userToken {
                CastledUserDefaults.setString(CastledUserDefaults.kCastledUserTokenKey, secureUserId)
            }

            CastledUserDefaults.shared.userId = userId
            CastledUserDefaults.shared.userToken = userToken

            if userId != existingUserId {
                if CastledUserDefaults.shared.apnsToken != nil || CastledUserDefaults.shared.fcmToken != nil {
                    Castled.sharedInstance.updateTheUserIdAndToken(userId, apns: CastledUserDefaults.shared.apnsToken, fcm: CastledUserDefaults.shared.fcmToken)
                } else {
                    Castled.sharedInstance.checkAndRegisterForAPNsToken()
                }
                self.didSetUserId()
            }
        }
    }

    private func didSetUserId() {
        DispatchQueue.main.async {
            Castled.sharedInstance.executeBGTasks()
        }
    }

    private func updateTheUserIdAndToken(_ userId: String, apns apnsToken: String?, fcm fcmToken: String?) {
        let params = [CastledConstants.PushNotification.userId: userId,
                      CastledConstants.PushNotification.Token.apnsToken: apnsToken,
                      CastledConstants.PushNotification.Token.fcmToken: fcmToken]
        CastledPushNotification.sharedInstance.registerUser(params: params.compactMapValues { $0 } as [String: Any])
    }

    private func checkAndRegisterForAPNsToken() {
        if CastledConfigs.sharedInstance.enablePush, CastledUserDefaults.shared.apnsToken == nil {
            Castled.sharedInstance.registerForAPNsToken()
        }
    }

    private func registerForAPNsToken() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    @objc public func requestPushPermission() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { [self] granted, _ in
                if granted {
                    registerForAPNsToken()
                } else { CastledLog.castledLog("Push notification permission has not been granted yet.", logLevel: .info)
                }
            })
        }
    }

    // MARK: - REACT AND OTHER SDK SUPPORT

    /**
     Supporting method for react and other SDKs
     */
    public func logMessage(_ message: String, _ logLevel: CastledLogLevel) {
        CastledLog.castledLog(message, logLevel: logLevel)
    }

    /**
     Supporting method for react and other SDKs
     */
    public static func setDelegate(_ delegate: CastledNotificationDelegate) {
        Castled.sharedInstance.delegate = delegate
    }

    public func getCastledConfig() -> CastledConfigs {
        return CastledConfigsUtils.configs
    }
}
