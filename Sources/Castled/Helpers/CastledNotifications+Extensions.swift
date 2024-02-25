//
//  CastledNotifications+Extensions.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UIKit
import UserNotifications

public extension Castled {
    // MARK: - Notification Delegates Swizzled methods

    @objc internal func swizzled_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Castled.sharedInstance.setDeviceToken(deviceToken: deviceToken)
        if responds(to: #selector(swizzled_application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
            self.swizzled_application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    @objc internal func swizzled_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CastledLog.castledLog("Failed to register: \(error)", logLevel: CastledLogLevel.error)
        if responds(to: #selector(swizzled_application(_:didFailToRegisterForRemoteNotificationsWithError:))) {
            swizzled_application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    @objc internal func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                                        willPresentNotification notification: UNNotification,
                                                        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        Castled.sharedInstance.userNotificationCenter(center, willPresent: notification)
        if responds(to: #selector(swizzled_userNotificationCenter(_:willPresentNotification:withCompletionHandler:))) {
            swizzled_userNotificationCenter(center, willPresentNotification: notification) { options in
                completionHandler(options)
            }
        } else {
            completionHandler([[.alert, .badge, .sound]])
        }
    }

    @objc internal func swizzled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Castled.sharedInstance.didReceiveRemoteNotification(inApplication: application, withInfo: userInfo, fetchCompletionHandler: { [self] _ in
            if self.responds(to: #selector(swizzled_application(_:didReceiveRemoteNotification:fetchCompletionHandler:))) {
                self.swizzled_application(application, didReceiveRemoteNotification: userInfo) { result in
                    completionHandler(result)
                }
            } else {
                completionHandler(.newData)
                return
            }
        })
    }

    @objc internal func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                                        didReceiveNotificationResponse response: UNNotificationResponse,
                                                        withCompletionHandler completionHandler: @escaping () -> Void)
    {
        Castled.sharedInstance.handleNotificationAction(response: response)
        if responds(to: #selector(swizzled_userNotificationCenter(_:didReceiveNotificationResponse:withCompletionHandler:))) {
            swizzled_userNotificationCenter(center, didReceiveNotificationResponse: response) {
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    @objc internal func swizzled_application(_ application: UIApplication, openURL url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if responds(to: #selector(swizzled_application(_:openURL:options:))) {
            return swizzled_application(application, openURL: url, options: options)
        }
        return true
    }

    @objc internal func setDeviceToken(deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        CastledLog.castledLog("deviceTokenString  \(deviceTokenString)", logLevel: CastledLogLevel.debug)
        Castled.sharedInstance.setPushToken(deviceTokenString)
    }

    @objc func didReceiveRemoteNotification(inApplication application: UIApplication, withInfo userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let application = UIApplication.shared
        var backgroundTask: UIBackgroundTaskIdentifier?
        backgroundTask = application.beginBackgroundTask(withName: "com.castled.bgpush") {
            application.endBackgroundTask(backgroundTask!)
            backgroundTask = .invalid
        }
        CastledBadgeManager.shared.updateApplicationBadgeAfterNotification(userInfo)
        if let customCasledDict = userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary {
            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
                let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
                let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String ?? ""
                let params = Castled.sharedInstance.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, teamID: teamID, sourceContext: sourceContext)
                if !params.isEmpty {
                    CastledNetworkManager.reportPushEvents(params: params) { response in
                        completionHandler(response.success ? .newData : .failed)
                        application.endBackgroundTask(backgroundTask!)
                    }
                } else {
                    // probabily  send test
                    completionHandler(.noData)
                    application.endBackgroundTask(backgroundTask!)
                }

            } else {
                completionHandler(.noData)
                application.endBackgroundTask(backgroundTask!)
            }
        } else {
            // not from castled
            completionHandler(.noData)
            application.endBackgroundTask(backgroundTask!)
        }
    }

    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
        processCastledPushEvents(userInfo: notification.request.content.userInfo)
        Castled.sharedInstance.delegate?.didReceiveCastledRemoteNotification?(withInfo: notification.request.content.userInfo)
        CastledBadgeManager.shared.updateApplicationBadgeAfterNotification(notification.request.content.userInfo)
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        handleNotificationAction(response: response)
    }

    // MARK: - Helper methods

    internal func handleNotificationAction(response: UNNotificationResponse) {
        // Returning the same options we've requested
        var pushActionType = CastledClickActionType.none
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let defaultActionDetails: [String: Any] = CastledCommonClass.getDefaultActionDetails(dict: userInfo, index: CastledUserDefaults.userDefaultsSuit.value(forKey: CastledUserDefaults.kCastledClickedNotiContentIndx) as? Int ?? 0),
               let defaultAction = defaultActionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String
            {
                switch defaultAction {
                    case CastledConstants.PushNotification.ClickActionType.deepLink.rawValue:
                        pushActionType = CastledClickActionType.deepLink
                    case CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue:
                        pushActionType = CastledClickActionType.navigateToScreen
                    case CastledConstants.PushNotification.ClickActionType.richLanding.rawValue:
                        pushActionType = CastledClickActionType.richLanding
                    case CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue:
                        pushActionType = CastledClickActionType.dismiss
                    default:
                        break
                }
                CastledUserDefaults.removeFor(CastledUserDefaults.kCastledClickedNotiContentIndx, ud: CastledUserDefaults.userDefaultsSuit)
                CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: pushActionType, kvPairs: defaultActionDetails, userInfo: userInfo)
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: defaultActionDetails, userInfo: userInfo)
            } else {
                // handle other actions
                CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
            }
            processCastledPushEvents(userInfo: userInfo, isOpened: true)
        } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .push, action: .dismiss, kvPairs: nil, userInfo: userInfo)
            processCastledPushEvents(userInfo: userInfo, isDismissed: true, actionType: CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue)
        } else {
            if let actionDetails: [String: Any] = CastledCommonClass.getActionDetails(dict: userInfo, actionType: response.actionIdentifier),
               let clickAction = actionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String
            {
                switch clickAction {
                    case CastledConstants.PushNotification.ClickActionType.deepLink.rawValue:
                        pushActionType = CastledClickActionType.deepLink
                        processCastledPushEvents(userInfo: userInfo, isOpened: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.deepLink.rawValue)
                    case CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue:
                        pushActionType = CastledClickActionType.navigateToScreen
                        processCastledPushEvents(userInfo: userInfo, isOpened: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue)
                    case CastledConstants.PushNotification.ClickActionType.richLanding.rawValue:
                        pushActionType = CastledClickActionType.richLanding
                        processCastledPushEvents(userInfo: userInfo, isOpened: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.richLanding.rawValue)
                    case CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue:
                        pushActionType = CastledClickActionType.dismiss
                        processCastledPushEvents(userInfo: userInfo, isDismissed: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue)
                    default:
                        break
                }
                CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: pushActionType, kvPairs: actionDetails, userInfo: userInfo)
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: actionDetails, userInfo: userInfo)
            } else {
                CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
            }
        }
        CastledBadgeManager.shared.clearApplicationBadge()
    }

    internal func processCastledPushEvents(userInfo: [AnyHashable: Any], isOpened: Bool? = false, isDismissed: Bool? = false, actionLabel: String? = "", actionType: String? = "") {
        castledNotificationQueue.async {
            if let customCasledDict = userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary {
                //  CastledLog.castledLog("Castled PushEvents \(customCasledDict)")
                if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
                    let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String
                    let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String
                    var event = CastledConstants.CastledEventTypes.received.rawValue
                    if isOpened == true {
                        event = CastledConstants.CastledEventTypes.cliked.rawValue
                    } else if isDismissed == true {
                        event = CastledConstants.CastledEventTypes.discarded.rawValue
                    } else {
                        event = CastledConstants.CastledEventTypes.received.rawValue
                    }

                    let params = Castled.sharedInstance.getPushPayload(event: event, teamID: teamID ?? "", sourceContext: sourceContext ?? "", actionLabel: actionLabel, actionType: actionType)
                    if !params.isEmpty {
                        CastledNetworkManager.reportPushEvents(params: params) { _ in
                        }
                    }
                }
            }
        }
    }

    internal func processAllDeliveredNotifications(shouldClear: Bool) {
        if CastledConfigsUtils.configs.enablePush == false {
            return
        }
        castledNotificationQueue.async {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getDeliveredNotifications { receivedNotifications in
                    var castledPushEvents = [[String: String]]()
                    var castledNotifications = 0
                    for notification in receivedNotifications {
                        let content = notification.request.content
                        if let customCasledDict = content.userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary {
                            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
                                let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
                                let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String ?? ""
                                let params = Castled.sharedInstance.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, teamID: teamID, sourceContext: sourceContext)
                                castledPushEvents.append(contentsOf: params)
                            }
                            castledNotifications += 1
                        }
                    }
                    if !castledPushEvents.isEmpty {
                        CastledNetworkManager.reportPushEvents(params: castledPushEvents) { _ in
                        }
                    }
                    if castledNotifications == 0 {
                        CastledBadgeManager.shared.clearApplicationBadge()
                    }
                }
            }
        }
    }

    private func getPushPayload(event: String, teamID: String, sourceContext: String, actionLabel: String? = "", actionType: String? = "") -> [[String: String]] {
        if sourceContext.isEmpty {
            return []
        }
        var payload = [[String: String]]()
        if event == CastledConstants.CastledEventTypes.received.rawValue {
            if CastledUserDefaults.shared.deliveredPushIds.contains(sourceContext) {
                return payload
            } else {
                CastledUserDefaults.shared.deliveredPushIds.append(sourceContext)
                if CastledUserDefaults.shared.deliveredPushIds.count > 20 {
                    CastledUserDefaults.shared.deliveredPushIds.removeFirst()
                }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledDeliveredPushIds, CastledUserDefaults.shared.deliveredPushIds)
            }
        } else if event == CastledConstants.CastledEventTypes.cliked.rawValue {
            payload.append(contentsOf: Castled.sharedInstance.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, teamID: teamID, sourceContext: sourceContext))
            if CastledUserDefaults.shared.clickedPushIds.contains(sourceContext) {
                return payload
            } else {
                CastledUserDefaults.shared.clickedPushIds.append(sourceContext)
                if CastledUserDefaults.shared.clickedPushIds.count > 20 {
                    CastledUserDefaults.shared.clickedPushIds.removeFirst()
                }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledClickedPushIds, CastledUserDefaults.shared.clickedPushIds)
            }
        }
        let timezone = TimeZone.current
        let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
        var params = ["eventType": event, "appInBg": String(false), "ts": "\(Int(Date().timeIntervalSince1970))", "tz": abbreviation, "teamId": teamID, "sourceContext": sourceContext] as [String: String]
        if actionLabel?.count ?? 0 > 0 {
            params["actionLabel"] = actionLabel
        }
        if actionType?.count ?? 0 > 0 {
            params["actionType"] = actionType
        }
        params[CastledConstants.CastledNetworkRequestTypeKey] = CastledConstants.CastledNetworkRequestType.pushRequest.rawValue
        payload.append(params)
        return payload
    }

    internal func getCastledCategory() -> UNNotificationCategory {
        let castledCategory = UNNotificationCategory(identifier: "CASTLED_PUSH_TEMPLATE", actions: [], intentIdentifiers: [], options: .customDismissAction)
        return castledCategory
    }
}
