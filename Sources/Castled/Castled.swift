//
//  Castled.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UserNotifications
import UIKit

@objc public protocol CastledNotificationDelegate {

    @objc optional func registerForPush()
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    @objc optional func castled_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    @objc optional func castled_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    @objc optional func castled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any])
}

@objc public class Castled: NSObject {
    @objc public static var sharedInstance: Castled?
    private var shouldClearDeliveredNotifications = true
    internal var inboxItemsArray = [CastledInboxItem]()
    internal var inboxUnreadCountCallback: ((Int) -> Void)?
    internal var inboxUnreadCount: Int = 0 {
        didSet {
            // Call the callback when the unreadCount changes
            inboxUnreadCountCallback?(inboxUnreadCount)
        }
    }
    var instanceId: String
    let delegate: CastledNotificationDelegate
    var clientRootViewController: UIViewController?
    // Create a dispatch queue
    private let castledDispatchQueue = DispatchQueue(label: "CastledQueue", qos: .background)
    internal let castledNotificationQueue = DispatchQueue(label: "CastledNotificationQueue", qos: .background)
    // Create a semaphore
    private let castledSemaphore = DispatchSemaphore(value: 1)

    /**
     Static method for conguring the Castled framework.
     */
    @objc static public func initialize(withConfig config: CastledConfigs, delegate: CastledNotificationDelegate, andNotificationCategories categories: Set<UNNotificationCategory>? = Set<UNNotificationCategory>()) {
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = Castled.init(instanceId: config.instanceId, delegate: delegate, categories: categories ?? Set<UNNotificationCategory>())
        }
    }

    private init(instanceId: String, delegate: CastledNotificationDelegate, categories: Set<UNNotificationCategory>) {
        if instanceId.isEmpty {
            fatalError("'instanceId' has not been initialized. Call CastledConfigs.initialize(instanceId:) with a valid instanceId.")
        }
        self.instanceId  = instanceId
        self.delegate    = delegate
        super.init()
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = self
        }
        CastledSwizzler.enableSwizzlingForNotifications()
        setNotificationCategories(withItems: categories)
        let config = CastledConfigs.sharedInstance
        if config.enablePush == true || CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledEnablePushNotificationKey) == true {
            registerForPushNotifications()
        }
        initialSetup()
    }
    private func initialSetup() {
        UIViewController.swizzleViewDidAppear()
        CastledBGManager.sharedInstance.registerBackgroundTasks()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    /**
     Function that allows users to set the badge on the app icon manually.
     */
    public func setBadge(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    /**
     InApps : Function that allows to display page view inapp
     */
    @objc public func logPageViewedEventIfAny(context: UIViewController) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        } else if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.userNotRegistered.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: CIEventType.page_viewed.rawValue, params: ["name": String(describing: type(of: context))], showLog: false)
    }
    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(context: UIViewController, eventName: String, params: [String: Any]) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: eventName, params: params, showLog: false)
    }
    @objc internal func executeBGTaskWithDelay() {
        CastledBGManager.sharedInstance.executeBackgroundTask {
            Castled.sharedInstance?.getInboxItems(completion: { _, _, _ in
            })
        }
    }
    @objc internal func appBecomeActive() {
        Castled.sharedInstance?.processAllDeliveredNotifications(shouldClear: false)
        if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) != nil {
            Castled.sharedInstance?.logAppOpenedEventIfAny()
            perform(#selector(executeBGTaskWithDelay), with: nil, afterDelay: 2.0)
        }
    }
    private func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if CastledConfigs.sharedInstance.enableInApp == false {
            return
        }
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil, showLog: showLog)
    }
}
