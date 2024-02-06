//
//  Castled.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import RealmSwift
import UIKit
import UserNotifications

@objc public protocol CastledNotificationDelegate {
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any])
    @objc optional func didReceiveCastledRemoteNotification(withInfo userInfo: [AnyHashable: Any])
}

@objc public class Castled: NSObject {
    @objc public static var sharedInstance = Castled()
    var inboxUnreadCountCallback: ((Int) -> Void)?
    var instanceId = CastledConfigsUtils.appId ?? ""
    var delegate: CastledNotificationDelegate?
    var clientRootViewController: UIViewController?
    private var isInitialized = false
    // Create a dispatch queue
    let castledCommonQueue = DispatchQueue(label: "CastledCommonQueue", qos: .background)
    let castledProfileQueue = DispatchQueue(label: "CastledProfileQueue", attributes: .concurrent)
    let castledNotificationQueue = DispatchQueue(label: "CastledNotificationQueue", qos: .background)
    let castledEventsTrackingQueue = DispatchQueue(label: "CastledEventsTrackingQueue", attributes: .concurrent)

    // Create a semaphore
    private let castledSemaphore = DispatchSemaphore(value: 1)

    lazy var inboxUnreadCount: Int = {
        CastledStore.getInboxUnreadCount(realm: CastledDBManager.shared.getRealm())

    }() {
        didSet {
            inboxUnreadCountCallback?(inboxUnreadCount)
        }
    }

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
        CastledConfigsUtils.saveTheConfigs()
        Castled.sharedInstance.initialSetup()
    }

    private func initialSetup() {
        let config = CastledConfigs.sharedInstance
        CastledLog.setLogLevel(config.logLevel)
        #if !DEBUG
        CastledLog.setLogLevel(CastledLogLevel.none)
        #endif
        if config.enablePush {
            CastledSwizzler.enableSwizzlingForNotifications()
        }
        if config.enableInApp {
            UIViewController.swizzleViewDidAppear()
        }
        CastledNetworkMonitor.shared.startMonitoring()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        CastledDeviceInfo.shared.updateDeviceInfo()
        CastledUserEventsTracker.shared.setInitialLaunchEventDetails()
        setNotificationCategories(withItems: Set<UNNotificationCategory>())
        CastledLog.castledLog("SDK \(CastledCommonClass.getSDKVersion()) initialized..", logLevel: .debug)
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
    @objc public func setPushToken(_ token: String) {
        castledProfileQueue.async(flags: .barrier) {
            let oldToken = CastledUserDefaults.shared.apnsToken ?? ""
            CastledUserDefaults.shared.apnsToken = token
            CastledUserDefaults.setString(CastledUserDefaults.kCastledAPNsTokenKey, token)

            if token != oldToken {
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, false)
                if let uid = CastledUserDefaults.shared.userId {
                    Castled.sharedInstance.updateTheUserIdAndToken(uid, token)
                }
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
        CastledInApps.sharedInstance.logAppEvent(context: viewContoller, eventName: CIEventType.page_viewed.rawValue, params: ["name": String(describing: type(of: viewContoller))], showLog: false)
    }

    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(eventName: String, params: [String: Any]) {
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: eventName, params: params, showLog: false)
        CastledEventsTracker.shared.trackEvent(eventName: eventName, params: params)
    }

    @objc public func setUserAttributes(params: [String: Any]) {
        CastledEventsTracker.shared.setUserAttributes(params: params)
    }

    @objc public func logout() {
        if let userId = CastledUserDefaults.shared.userId {
            DispatchQueue.main.async {
                CastledUserDefaults.clearAllFromPreference()
                CastledDBManager.shared.clearTables()
                CastledNetworkManager.logoutUser(params: ["userId": userId,
                                                          "token": CastledUserDefaults.shared.apnsToken ?? "",
                                                          CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.logoutUser.rawValue])
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

    @objc func executeBGTasks(isFromBG: Bool = false) {
        CastledBGManager.sharedInstance.executeBackgroundTask {
            if isFromBG {
                Castled.sharedInstance.logAppOpenedEventIfAny()
            }
        }
    }

    @objc public func appBecomeActive() {
        if CastledUserDefaults.shared.userId != nil {
            Castled.sharedInstance.processAllDeliveredNotifications(shouldClear: false)
            CastledSessionsManager.shared.didEnterForeground()
            CastledUserEventsTracker.shared.setTheUserEventsFromBG()
            Castled.sharedInstance.executeBGTasks(isFromBG: true)
        }
    }

    @objc public func didEnterBackground() {
        if CastledUserDefaults.shared.userId != nil {
            CastledSessionsManager.shared.didEnterBackground()
        }
    }

    func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if CastledConfigsUtils.enableInApp == false {
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil, showLog: showLog)
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
                CastledDeviceInfo.shared.updateDeviceInfo()
                CastledUserEventsTracker.shared.updateUserEvents()

                guard let deviceToken = CastledUserDefaults.shared.apnsToken else {
                    Castled.sharedInstance.executeBGTasks()
                    return
                }
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, false)
                Castled.sharedInstance.updateTheUserIdAndToken(userId, deviceToken)
            }
        }
    }

    private func updateTheUserIdAndToken(_ userId: String, _ deviceToken: String) {
        CastledNetworkManager.api_RegisterUser(userId: userId, apnsToken: deviceToken) { _ in
            Castled.sharedInstance.executeBGTasks()
        }
    }

    @objc public func promptForPushNotification() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? UNUserNotificationCenterDelegate {
                UNUserNotificationCenter.current().delegate = appDelegate
                UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, _ in
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                })
            } else {
                CastledLog.castledLog("AppDelegate does not conform to UNUserNotificationCenterDelegate. Please confirm to UIApplicationDelegate protocol. https://docs.castled.io/developer-resources/sdk-integration/ios/push-notifications#registering-push-notification", logLevel: .error)
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
    public static func initializeForCrossPlatform() {
        CastledSwizzler.enableSwizzlingForNotifications()
    }

    public static func setDelegate(_ delegate: CastledNotificationDelegate) {
        Castled.sharedInstance.delegate = delegate
    }
}
