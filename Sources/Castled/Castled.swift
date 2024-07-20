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
        CastledUserDefaults.appGroupId = config.appGroupId
        if !config.appGroupId.isEmpty { CastledUserDefaults.migrateDatasToSuit() }

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
            setNotificationCategories(withItems: Set<UNNotificationCategory>())
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

        CastledModuleInitManager.sharedInstance.notifiyListeners()

        // After all module initialization
        CastledNetworkMonitor.shared.startMonitoring()
        CastledLifeCycleManager.sharedInstance.start()

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
    @objc public func setPushToken(_ token: String, type: CastledPushTokenType) {
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
    @objc public func logPageViewedEvent(_ screenName: String) {
        CastledInApp.sharedInstance.logPageViewedEvent(screenName)
    }

    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(_ eventName: String, params: [String: Any]) {
        if CastledConfigsUtils.configs.enableInApp {
            CastledInApp.sharedInstance.logCustomAppEvent(eventName, params: params)
        }
        if CastledConfigsUtils.configs.enableTracking {
            CastledEventsTracker.sharedInstance.trackEvent(eventName: eventName, params: params)
        }
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
        if let application = UIApplication.getSharedApplication() as? UIApplication {
            application.applicationIconBadgeNumber = count
        }
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
            CastledUserDefaults.shared.userToken = userToken

            if userId != existingUserId {
                CastledUserDefaults.shared.userId = userId
                if CastledUserDefaults.shared.apnsToken != nil || CastledUserDefaults.shared.fcmToken != nil {
                    Castled.sharedInstance.updateTheUserIdAndToken(userId, apns: CastledUserDefaults.shared.apnsToken, fcm: CastledUserDefaults.shared.fcmToken)
                } else {
                    Castled.sharedInstance.checkAndRegisterForAPNsToken()
                }
            }
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
            if let application = UIApplication.getSharedApplication() as? UIApplication {
                application.registerForRemoteNotifications()
            }
        }
    }

    @objc public func requestPushPermission(showSettingsAlert: Bool = false) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in

                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, _ in
                        if granted {
                            self?.registerForAPNsToken()
                        } else {
                            CastledLog.castledLog("Push notification permission has not been granted yet.", logLevel: .info)
                        }
                    })
                } else {
                    if settings.authorizationStatus == .authorized {
                        self?.registerForAPNsToken()
                    } else {
                        CastledLog.castledLog("Push notification permission has not been granted yet.", logLevel: .info)
                        if showSettingsAlert {
                            self?.showSettingsAlert()
                        }
                    }
                }
            }
        }
    }

    private func showSettingsAlert() {
        DispatchQueue.main.async {
            if let application = UIApplication.getSharedApplication() as? UIApplication {
                let alertTitle = "Permission Needed"
                let alertMessage = "You have previously denied push notification permission. Please go to your settings to enable push notifications."

                let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

                let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString), let application = UIApplication.getSharedApplication() as? UIApplication {
                        if application.canOpenURL(appSettings) {
                            application.open(appSettings)
                        }
                    }
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)

                if let windowScene = application.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController
                {
                    var topController = rootViewController
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    topController.present(alertController, animated: true, completion: nil)
                }
            }
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

    func getCastledConfig() -> CastledConfigs {
        return CastledConfigsUtils.configs
    }
}
