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
    @objc internal func setDeviceToken(deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        CastledLog.castledLog("APNs token \(deviceTokenString)", logLevel: CastledLogLevel.debug)
        Castled.sharedInstance.setPushToken(deviceTokenString, type: .apns)
    }

    @objc func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        if let application = UIApplication.getSharedApplication() as? UIApplication {
            Castled.sharedInstance.didReceiveRemoteNotification(inApplication: application, withInfo: userInfo, isCastledSilentPush: Castled.sharedInstance.isCastledSilentPush(fromInfo: userInfo)) { _ in
            }
        }
    }

    internal func didReceiveRemoteNotification(inApplication application: UIApplication?, withInfo userInfo: [AnyHashable: Any], isCastledSilentPush: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let application = application, !isCastledSilentPush else {
            completionHandler(.noData)
            return
        }
        DispatchQueue.main.async {
            var backgroundTask: UIBackgroundTaskIdentifier?
            backgroundTask = application.beginBackgroundTask(withName: CastledCommonClass.getUUIDString()) {
                endBackgroundTask()
            }
            func endBackgroundTask() {
                if var backgroundTaskN = backgroundTask, backgroundTask != .invalid {
                    application.endBackgroundTask(backgroundTaskN)
                    backgroundTaskN = .invalid
                }
            }
            guard let customCasledDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo),
                  let notificationId = customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String,
                  let defaultActionDetails: [String: Any] = CastledCommonClass.getDefaultActionDetails(dict: userInfo, index: 0),
                  let defaultAction = defaultActionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String
            else {
                // not from castled/ already reported
                endBackgroundTask()
                completionHandler(.noData)
                return
            }
            let isVisible = Castled.sharedInstance.isVisibleNotification(userInfo)
            var actionUri = ""
            var actionType = ""

            var event = CastledConstants.CastledEventTypes.received.rawValue
            if isVisible, application.applicationState == .inactive {
                // application.applicationState == .inactive :  The app is transitioning between states (e.g., the user is tapping on a notification, and the app is about to become active).
                event = CastledConstants.CastledEventTypes.cliked.rawValue
                actionType = defaultAction
                actionUri = CastledButtonActionUtils.getClickActionUrlFrom(kvPairs: defaultActionDetails) ?? ""
                CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: defaultAction.getCastledClickActionType(), kvPairs: defaultActionDetails, userInfo: userInfo)
                CastledBadgeManager.shared.clearApplicationBadge()
            } else {
                CastledBadgeManager.shared.updateApplicationBadgeAfterNotification(userInfo)
            }
            let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
            let params = Castled.sharedInstance.getPushPayload(event: event, sourceContext: sourceContext, actionType: actionType, actionUri: actionUri, deliveredDate: Date(), notificationId: notificationId)

            if !params.isEmpty {
                // no need to report if already reported/ send test/ not from castled
                CastledPushNotification.sharedInstance.reportPushEvents(params: params) { success in
                    endBackgroundTask()
                    completionHandler(success ? .newData : .failed)
                }
            } else {
                // not from castled, send test/ already reported
                endBackgroundTask()
                completionHandler(.noData)
            }
        }
    }

    private func isVisibleNotification(_ notification: [AnyHashable: Any]) -> Bool {
        guard let aps = notification["aps"] as? [String: Any] else {
            return false
        }

        let alert = aps["alert"]

        if let alertDict = alert as? [String: Any] {
            return !alertDict.isEmpty
        }

        // if only body is specified
        if let alertString = alert as? String {
            return !alertString.isEmpty
        }

        return false
    }

    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
        let isCastledSilentPush = Castled.sharedInstance.isCastledSilentPush(fromInfo: notification.request.content.userInfo)
        Castled.sharedInstance.castledUserNotificationCenter(center, willPresent: notification, isCastledSilentPush: isCastledSilentPush)
    }

    internal func castledUserNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, isCastledSilentPush: Bool) {
        if !isCastledSilentPush {
            processCastledPushEvents(userInfo: notification.request.content.userInfo, deliveredDate: notification.date)
            Castled.sharedInstance.delegate?.didReceiveCastledRemoteNotification?(withInfo: notification.request.content.userInfo)
            CastledBadgeManager.shared.updateApplicationBadgeAfterNotification(notification.request.content.userInfo)
        }
    }

    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        handleNotificationAction(response: response)
    }

    /**
     This method checks the `userInfo` dictionary of a push notification to determine if it is from the Castled server.
     */
    @objc func isPushFromCastled(userInfo: [AnyHashable: Any]) -> Bool {
        return CastledPushNotification.sharedInstance.isPushFromCastled(userInfo: userInfo)
    }

    // MARK: - Helper methods

    internal func handleNotificationAction(response: UNNotificationResponse) {
        // Returning the same options we've requested
        var pushActionType = CastledClickActionType.none
        var clickedParams: [AnyHashable: Any]?
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            if let defaultActionDetails: [String: Any] = CastledCommonClass.getDefaultActionDetails(dict: userInfo, index: CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledClickedNotiContentIndx) as? Int ?? 0),
               let defaultAction = defaultActionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String
            {
                // Any change here should handle in the background delegate also
                pushActionType = defaultAction.getCastledClickActionType()
                CastledUserDefaults.removeFor(CastledUserDefaults.kCastledClickedNotiContentIndx)
                clickedParams = defaultActionDetails
                processCastledPushEvents(userInfo: userInfo, isOpened: true, actionType: defaultAction, actionUri: CastledButtonActionUtils.getClickActionUrlFrom(kvPairs: clickedParams), deliveredDate: response.notification.date)

            } else {
                // not from castled
                return
            }
        } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            pushActionType = CastledClickActionType.dismiss
            processCastledPushEvents(userInfo: userInfo, isDismissed: true, actionType: CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue, deliveredDate: response.notification.date)
        } else {
            if let actionDetails: [String: Any] = CastledCommonClass.getActionDetails(dict: userInfo, actionType: response.actionIdentifier),
               let clickAction = actionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String
            {
                // Any change here should handle in the background delegate also
                pushActionType = clickAction.getCastledClickActionType()
                clickedParams = actionDetails
                processCastledPushEvents(userInfo: userInfo, isOpened: true, actionLabel: response.actionIdentifier, actionType: clickAction, actionUri: CastledButtonActionUtils.getClickActionUrlFrom(kvPairs: clickedParams), deliveredDate: response.notification.date)

            } else {
                // not from castled
                return
            }
        }
        CastledButtonActionHandler.notificationClicked(withNotificationType: .push, action: pushActionType, kvPairs: clickedParams, userInfo: userInfo)
        CastledBadgeManager.shared.clearApplicationBadge()
    }

    internal func processCastledPushEvents(userInfo: [AnyHashable: Any], isOpened: Bool? = false, isDismissed: Bool? = false, actionLabel: String? = "", actionType: String? = "", actionUri: String? = "", deliveredDate: Date = Date()) {
        castledNotificationQueue.async {
            if let customCasledDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo), 
                let notificationId = customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String {
                let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String
                var event = CastledConstants.CastledEventTypes.received.rawValue
                if isOpened == true {
                    event = CastledConstants.CastledEventTypes.cliked.rawValue
                } else if isDismissed == true {
                    event = CastledConstants.CastledEventTypes.discarded.rawValue
                } else {
                    event = CastledConstants.CastledEventTypes.received.rawValue
                }

                let params = Castled.sharedInstance.getPushPayload(event: event, sourceContext: sourceContext ?? "", actionLabel: actionLabel, actionType: actionType, actionUri: actionUri ?? "", deliveredDate: deliveredDate, notificationId: notificationId)
                if !params.isEmpty {
                    CastledPushNotification.sharedInstance.reportPushEvents(params: params) { _ in
                    }
                }
            }
        }
    }

    internal func processAllDeliveredNotifications(shouldClear: Bool) {
        castledNotificationQueue.async {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getDeliveredNotifications { receivedNotifications in
                    var castledPushEvents = [[String: String]]()
                    var castledNotifications = 0
                    for notification in receivedNotifications {
                        let content = notification.request.content
                        if let customCasledDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: content.userInfo),
                           let notificationId = customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String
                        {
                            let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
                            let params = Castled.sharedInstance.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, sourceContext: sourceContext, deliveredDate: notification.date, notificationId: notificationId)
                            castledPushEvents.append(contentsOf: params)
                            castledNotifications += 1
                        }
                    }
                    if !castledPushEvents.isEmpty {
                        CastledPushNotification.sharedInstance.reportPushEvents(params: castledPushEvents) { _ in
                        }
                    }
                    if castledNotifications == 0 {
                        CastledBadgeManager.shared.clearApplicationBadge()
                    }
                }
            }
        }
    }

    private func getPushPayload(event: String, sourceContext: String, actionLabel: String? = "", actionType: String? = "", actionUri: String = "", deliveredDate: Date, notificationId : String) -> [[String: String]] {
        if sourceContext.isEmpty {
            return []
        }
        var payload = [[String: String]]()
        var date = deliveredDate
        if event == CastledConstants.CastledEventTypes.received.rawValue {
            var deliveredPushIds = CastledUserDefaults.shared.getDeliveredPushIds()
            if deliveredPushIds.contains(where: { $0 == notificationId || $0 == sourceContext })  {
                return payload
            } else {
                deliveredPushIds.append(notificationId)
                if deliveredPushIds.count > 25 {
                    deliveredPushIds.removeFirst()
                }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledDeliveredPushIds, deliveredPushIds)
            }
        } else if event == CastledConstants.CastledEventTypes.cliked.rawValue {
            payload.append(contentsOf: Castled.sharedInstance.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, sourceContext: sourceContext, deliveredDate: deliveredDate, notificationId: notificationId))
            var clickedPushIds = CastledUserDefaults.shared.getClickedPushIds()

            if clickedPushIds.contains(where: { $0 == notificationId || $0 == sourceContext }) {
                return payload
            } else {
                clickedPushIds.append(notificationId)
                if clickedPushIds.count > 25 {
                    clickedPushIds.removeFirst()
                }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledClickedPushIds, clickedPushIds)
            }
            date = Date()
        }
        let timezone = TimeZone.current
        let abbreviation = timezone.abbreviation(for: date) ?? "GMT"
        var params = ["eventType": event, "ts": "\(Int(date.timeIntervalSince1970))", "tz": abbreviation, "sourceContext": sourceContext] as [String: String]
        if actionLabel?.count ?? 0 > 0 {
            params["actionLabel"] = actionLabel
        }
        if actionType?.count ?? 0 > 0 {
            params["actionType"] = actionType
        }
        if !actionUri.isEmpty {
            params["actionUri"] = actionUri
        }
        payload.append(params)
        return payload
    }

    internal func getCastledCategory() -> UNNotificationCategory {
        let castledCategory = UNNotificationCategory(identifier: "CASTLED_PUSH_TEMPLATE", actions: [], intentIdentifiers: [], options: .customDismissAction)
        return castledCategory
    }

    internal func isCastledSilentPush(fromInfo userInfo: [AnyHashable: Any]) -> Bool {
        guard let aps = userInfo[CastledConstants.PushNotification.apsKey] as? [String: AnyObject],
              aps[CastledConstants.PushNotification.contentAvailable] as? Int == 1,
              let customCasledDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo),
              let silent = customCasledDict[CastledConstants.PushNotification.isCastledSilentPush] as? Int,
              silent == 1
        else {
            return false
        }

        return true
    }
}
