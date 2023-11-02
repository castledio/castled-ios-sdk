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
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    @objc optional func castled_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    @objc optional func castled_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    @objc optional func castled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any])
}

@objc public class Castled: NSObject {
    @objc public static var sharedInstance: Castled?
    var inboxUnreadCountCallback: ((Int) -> Void)?
    var instanceId: String
    let delegate: CastledNotificationDelegate
    var clientRootViewController: UIViewController?
    // Create a dispatch queue
    let castledDispatchQueue = DispatchQueue(label: "CastledQueue", qos: .background)
    let castledNotificationQueue = DispatchQueue(label: "CastledNotificationQueue", qos: .background)
    // Create a semaphore
    private let castledSemaphore = DispatchSemaphore(value: 1)

    lazy var inboxUnreadCount: Int = {
        CastledStore.getInboxUnreadCount(realm: CastledDBManager.shared.getRealm())

    }() {
        didSet {
            inboxUnreadCountCallback?(inboxUnreadCount)
        }
    }

    /**
     Static method for conguring the Castled framework.
     */
    @objc public static func initialize(withConfig config: CastledConfigs, delegate: CastledNotificationDelegate, andNotificationCategories categories: Set<UNNotificationCategory>? = nil) {
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = Castled(instanceId: config.instanceId, delegate: delegate, categories: categories)
        }
    }

    private init(instanceId: String, delegate: CastledNotificationDelegate, categories: Set<UNNotificationCategory>?) {
        if instanceId.isEmpty {
            fatalError("'instanceId' has not been initialized. Call CastledConfigs.initialize(instanceId:) with a valid instanceId.")
        }
        self.instanceId = instanceId
        self.delegate = delegate
        super.init()
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = self
        }
        initialSetup(categories: categories)
    }

    /**
     Function that allows users to set the userId and  userToken.
     */
    @objc public func setUserId(_ userId: String, userToken: String? = nil) {
        Castled.sharedInstance?.saveUserId(userId, userToken)
    }

    /**
     Function that allows users to set the PushNotifiication token.
     */
    @objc public func setPushToken(_ token: String) {
        let oldToken = CastledUserDefaults.shared.apnsToken ?? ""
        CastledUserDefaults.shared.apnsToken = token
        CastledUserDefaults.setString(CastledUserDefaults.kCastledAPNsTokenKey, token)

        if oldToken != token || CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) == false {
            CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, false)

            if let uid = CastledUserDefaults.shared.userId {
                Castled.sharedInstance?.updateTheUserIdAndToken(uid, token)
            }
        }
    }

    /**
     InApps : Function that allows to display page view inapp
     */
    @objc public func logAppPageViewedEvent(_ viewContoller: UIViewController) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Log page viewed \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        guard let _ = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Log page viewed \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: viewContoller, eventName: CIEventType.page_viewed.rawValue, params: ["name": String(describing: type(of: viewContoller))], showLog: false)
    }

    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(_ viewController: UIViewController, eventName: String, params: [String: Any]) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Log inApp event failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: viewController, eventName: eventName, params: params, showLog: false)
        CastledEventsTracker.shared.trackEvent(eventName: eventName, params: params)
    }

    @objc public func setUserAttributes(params: [String: Any]) {
        CastledEventsTracker.shared.setUserAttributes(params: params)
    }

    private func initialSetup(categories: Set<UNNotificationCategory>?) {
        let config = CastledConfigs.sharedInstance
        CastledLog.setLogLevel(config.logLevel)
        #if !DEBUG
            CastledLog.setLogLevel(CastledLogLevel.none)
        #endif
        if config.enablePush || CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledEnablePushNotificationKey) == true {
            CastledSwizzler.enableSwizzlingForNotifications()
            setNotificationCategories(withItems: categories ?? Set<UNNotificationCategory>())
            registerForPushNotifications()
        }
        if config.enableInApp {
            UIViewController.swizzleViewDidAppear()
        }
        CastledBGManager.sharedInstance.registerBackgroundTasks()
        CastledNetworkMonitor.shared.startMonitoring()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        CastledDeviceInfo.shared.updateDeviceInfo()
        CastledLog.castledLog("SDK initialized..", logLevel: .debug)
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

    @objc func appBecomeActive() {
        Castled.sharedInstance?.processAllDeliveredNotifications(shouldClear: false)
        if CastledUserDefaults.shared.userId != nil {
            Castled.sharedInstance?.logAppOpenedEventIfAny()
            Castled.sharedInstance?.executeBGTasks()
        }
    }

    private func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if CastledConfigs.sharedInstance.enableInApp == false {
            return
        }
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Log app opened event \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil, showLog: showLog)
    }

    /**
     Funtion which alllows to register the User & Token with Castled.
     */
    private func saveUserId(_ userId: String, _ userToken: String? = nil) {
        CastledUserDefaults.setString(CastledUserDefaults.kCastledUserIdKey, userId)
        if let secureUserId = userToken {
            CastledUserDefaults.setString(CastledUserDefaults.kCastledUserTokenKey, secureUserId)
        }
        CastledUserDefaults.shared.userId = userId
        CastledUserDefaults.shared.userToken = userToken
        CastledDeviceInfo.shared.updateDeviceInfo()

        guard let deviceToken = CastledUserDefaults.shared.apnsToken else {
            Castled.sharedInstance?.executeBGTasks()
            return
        }
        Castled.sharedInstance?.updateTheUserIdAndToken(userId, deviceToken)
    }

    func updateTheUserIdAndToken(_ userId: String, _ deviceToken: String) {
        if CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) == false {
            Castled.sharedInstance?.api_RegisterUser(userId: userId, apnsToken: deviceToken) { _ in
                Castled.sharedInstance?.executeBGTasks()
            }
        }
    }
}
