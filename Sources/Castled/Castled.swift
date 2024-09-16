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
    lazy var instanceId = CastledConfigsUtils.appId ?? ""
    var delegate: CastledNotificationDelegate?

    private var isInitialized = false

    lazy var castledCommonQueue = DispatchQueue(label: CastledConstants.DispatchQueues.CastledCommonQueue, qos: .background)
    lazy var castledNotificationQueue = DispatchQueue(label: CastledConstants.DispatchQueues.CastledNotificationQueue, qos: .userInteractive)
    lazy var castledProfileQueue = DispatchQueue(label: CastledConstants.DispatchQueues.CastledProfileQueue, qos: .userInitiated, attributes: .concurrent)

    override private init() {}

    /**
     This method initilize the Castled SDK using the specified configuration object and optionally assigns a delegate for handling notifications. The configuration (`CastledConfigs`) provides necessary setup parameters, while the delegate (`CastledNotificationDelegate`) can be used to handle notification events and interactions.
         */
    @objc public static func initialize(withConfig config: CastledConfigs, andDelegate delegate: CastledNotificationDelegate?) {
        if config.instanceId.isEmpty {
            fatalError(CastledExceptionMessages.appIdNotInitialized.rawValue)
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
        CastledLog.castledLog("SDK \(CastledCommonClass.getSDKVersion()) initialized..", logLevel: .debug)
        CastledCoreDataStack.shared.initialize()
        if config.enablePush {
            if config.appGroupId.isEmpty {
                CastledLog.castledLog(CastledExceptionMessages.appGrouIdEmpty.rawValue, logLevel: .warning)
            }
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

    func isCastledInitialized() -> Bool {
        return isInitialized
    }

    // MARK: - PUSH

    /**
      This method updates the system with the provided user ID. An optional `userToken` can also be provided, which serves as a secure identifier for the user. The `userToken` is useful for additional security and verification purposes but is not required.
     */
    @objc public func setUserId(_ userId: String, userToken: String? = nil) {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledErrorHandler.throwCastledFatalError(errorMessage: "\(CastledExceptionMessages.notInitialised.rawValue) before \(#function)")
            return
        }
        Castled.sharedInstance.saveUserId(userId, userToken)
    }

    /**
     This method updates the Castled with the current push notification token associated with the device. The `token` parameter is used to send push notifications to the specific device, while the `type` parameter specifies the type of push notification token being set, either Firebase Cloud Messaging (FCM) or Apple Push Notification Service (APNs)
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

    @objc public func setLaunchOptions(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledErrorHandler.throwCastledFatalError(errorMessage: "\(CastledExceptionMessages.notInitialised.rawValue) before \(#function)")
            return
        }

        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
           notification["aps"] as? [String: AnyObject] != nil
        {
            Castled.sharedInstance.processCastledPushEvents(userInfo: notification, isOpened: true)
        }
        //  CastledBGManager.sharedInstance.registerBackgroundTasks()
    }

    /**
     This method sets the categories that define the types of notifications your app can handle. Each category may include actions and options that affect how notifications are presented and interacted with.
     */
    @objc public func setNotificationCategories(withItems items: Set<UNNotificationCategory>) {
        var categorySet = items
        categorySet.formUnion(getCastledCategories())
        UNUserNotificationCenter.current().setNotificationCategories([])
        UNUserNotificationCenter.current().setNotificationCategories(categorySet)
    }

    /**
     This method prompts the user to grant or deny permission for push notifications. If the user has previously denied permission, and `showSettingsAlert` is set to `true`, it will present an alert directing the user to the app settings to enable notifications
     */
    @objc public func requestPushPermission(showSettingsAlert: Bool = false) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in

                if settings.authorizationStatus == .notDetermined {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.sound, .badge, .alert], completionHandler: { granted, _ in
                        if granted {
                            self?.registerForAPNsToken()
                        } else {
                            CastledLog.castledLog(CastledExceptionMessages.pushPermissionNotGranted.rawValue, logLevel: .info)
                        }
                    })
                } else {
                    if settings.authorizationStatus == .authorized {
                        self?.registerForAPNsToken()
                    } else {
                        CastledLog.castledLog(CastledExceptionMessages.pushPermissionNotGranted.rawValue, logLevel: .info)
                        if showSettingsAlert {
                            self?.showSettingsAlert()
                        }
                    }
                }
            }
        }
    }

    // MARK: - INAPP

    /**
     InApps : Function that allows to display page viewed inapp
     */
    @objc public func logPageViewedEvent(_ screenName: String) {
        CastledInApp.sharedInstance.logPageViewedEvent(screenName)
    }

    /**
     Function that allows to display custom inapp/ used for event tracking
      */
    @objc public func logCustomAppEvent(_ eventName: String, params: [String: Any]) {
        if CastledConfigsUtils.configs.enableInApp {
            CastledInApp.sharedInstance.logCustomAppEvent(eventName, params: params)
        }
        if CastledConfigsUtils.configs.enableTracking {
            CastledEventsTracker.sharedInstance.trackEvent(eventName: eventName, params: params)
        }
    }

    /**
     InApps : Displays an in-app notification if one is available. This method ensures that the notification is shown only once and will not trigger any further notifications.
     */
    @objc func displayInAppNotificationIfAny() {
        CastledInApp.sharedInstance.displayInAppNotificationIfAny()
    }

    /**
     Pauses the display of in-app notifications. Notifications will be on hold until `resumeInApp` is called
     */
    @objc public func pauseInApp() {
        CastledInApp.sharedInstance.pauseInApp()
    }

    /**
       Stops the evaluation and display of in-app notifications. Notifications will not be shown or processed until `resumeInApp` is called
     */
    @objc public func stopInApp() {
        CastledInApp.sharedInstance.stopInApp()
    }

    /**
       Resumes the evaluation and display of in-app notifications. This method reactivates the process of showing and evaluating notifications
     */
    @objc public func resumeInApp() {
        CastledInApp.sharedInstance.resumeInApp()
    }

    func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if CastledConfigsUtils.configs.enableInApp == false {
            return
        }
        CastledInApp.sharedInstance.logAppOpenedEventIfAny(showLog: showLog)
    }

    // MARK: - USER ATTRIBUTES

    /**
     Sets the specified attributes for the user
     */
    @objc public func setUserAttributes(_ attributes: CastledUserAttributes) {
        CastledEventsTracker.sharedInstance.setUserAttributes(attributes)
    }

    /**
     This method is used to log out the user from Castled. It typically involves clearing user-related data, invalidating sessions, and resetting any state associated with the current user
     */

    @objc public func logout() {
        if let userId = CastledUserDefaults.shared.userId {
            DispatchQueue.main.async {
                CastledCoreDataOperations.shared.deleteAllData()
                CastledUserDefaults.clearAllFromPreference()
                CastledLog.castledLog("\(userId) has been logged out successfully.", logLevel: .info)
            }
        }
    }

    // MARK: PRIVATE METHODS

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
                      CastledConstants.PushNotification.Token.fcmToken: fcmToken,
                      CastledConstants.PushNotification.deviceId: CastledDeviceInfoUtils.getDeviceId()]
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

    private func showSettingsAlert() {
        DispatchQueue.main.async {
            if let application = UIApplication.getSharedApplication() as? UIApplication {
                let alertTitle = "Permission Needed"
                let alertMessage = CastledExceptionMessages.pushPreviouslyDenied.rawValue

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
}
