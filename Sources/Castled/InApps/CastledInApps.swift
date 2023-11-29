//
//  CastledInApps.swift
//  Castled
//
//  Created by antony on 12/04/2023.
//

import Foundation
import UIKit

@objc class CastledInApps: NSObject {
    var isCurrentlyDisplaying = false
    private var pendingInApps = [CastledInAppObject]()
    static var sharedInstance = CastledInApps()
    var savedInApps = [CastledInAppObject]()
    private let castledInAppsQueue = DispatchQueue(label: "CastledInAppsQueue", qos: .background)
    private let castledInAppsPendinItemsQueue = DispatchQueue(label: "CastledInAppsPendingItemsQueue", attributes: .concurrent)

    override private init() {
        super.init()
    }

    func prefetchInApps() {
        if let savedItems = CastledUserDefaults.getDataFor(CastledUserDefaults.kCastledInAppsList) {
            let decoder = JSONDecoder()
            if let loadedInApps = try? decoder.decode([CastledInAppObject].self, from: savedItems) {
                self.savedInApps.removeAll()
                self.savedInApps.append(contentsOf: loadedInApps)
            }
        }
    }

    func reportInAppEvent(inappObject: CastledInAppObject, eventType: String, actionType: String?, btnLabel: String?, actionUri: String?) {
        DispatchQueue.global().async {
            let teamId = "\(inappObject.teamID)"
            let sourceContext = inappObject.sourceContext
            let timezone = TimeZone.current
            let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
            let epochTime = "\(Int(Date().timeIntervalSince1970))"
            var json = ["ts": "\(epochTime)",
                        "tz": "\(abbreviation)",
                        "teamId": teamId,
                        "eventType": eventType,
                        "sourceContext": sourceContext] as [String: String]
            if let value = btnLabel {
                json["btnLabel"] = value
            }
            if let value = actionType {
                json["actionType"] = value
            }
            if let value = actionUri {
                json["actionUri"] = value
            }
            json[CastledConstants.CastledNetworkRequestTypeKey] = CastledConstants.CastledNetworkRequestType.inappRequest.rawValue
            Castled.reportInAppEvents(params: [json], completion: { (response: CastledResponse<[String: String]>) in
                if response.success {
                    // CastledLog.castledLog(response.result as Any)
                } else {
                    // CastledLog.castledLog("Error in updating inapp event ")
                }
            })
        }
    }

    /**
     Button action handling
     */

    private func getDeepLinkUrlFrom(url: String, parameters: [String: String]?) -> URL? {
        // Define the base URL for your deep link
        guard let baseURL = URL(string: url) else {
            CastledLog.castledLog("Error:❌❌❌ Invalid Deeplink URL provided", logLevel: CastledLogLevel.error)
            return nil
        }
        var queryString = ""
        // Create a dictionary of query parameters
        if let params = parameters {
            // Convert the query parameters to a query string
            queryString = params.map { key, value in
                "\(key)=\(value)"
            }.joined(separator: "&")
        }
        // Construct the final deep link URL with query parameters
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.query = queryString

        if let deepLinkURL = components.url {
            // deepLinkURL now contains the complete deep link URL with query parameters
            return deepLinkURL
        } else {
            CastledLog.castledLog("Error:❌❌❌ Invalid Deeplink URL provided", logLevel: CastledLogLevel.error)
        }
        return nil
    }

    private func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func performButtonActionFor(buttonAction: CIActionButton? = nil, slide: CIBannerPresentation? = nil, webParams: [String: Any]? = nil) {
        var clickAction = CastledConstants.PushNotification.ClickActionType.custom.rawValue
        var params: [String: Any]?
        var url: String?

        if let action = buttonAction {
            clickAction = action.clickAction.rawValue
            params = action.keyVals ?? [String: String]()
            url = action.url
        } else if let slideUp = slide {
            clickAction = slideUp.clickAction.rawValue
            params = slideUp.keyVals ?? [String: String]()
            url = slideUp.url
        } else if let webP = webParams {
            params = webP
            url = params?[CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl] as? String ?? ""
            clickAction = params?[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String ?? ""
        } else {
            return
        }
        params?[CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl] = url ?? ""
        params?[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] = clickAction
        switch clickAction {
            case CastledConstants.PushNotification.ClickActionType.deepLink.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .deepLink, kvPairs: params, userInfo: params ?? [String: String]())
            case CastledConstants.PushNotification.ClickActionType.richLanding.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .richLanding, kvPairs: params, userInfo: params ?? [String: String]())
            case CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .navigateToScreen, kvPairs: params, userInfo: params ?? [String: String]())
            case CastledConstants.PushNotification.ClickActionType.requestPushPermission.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .requestForPush, kvPairs: params, userInfo: params ?? [String: String]())
            case CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .dismiss, kvPairs: params, userInfo: params ?? [String: String]())
            case CastledConstants.PushNotification.ClickActionType.custom.rawValue:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .custom, kvPairs: params, userInfo: params ?? [String: String]())
            default:
                Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: .inapp, action: .custom, kvPairs: params, userInfo: params ?? [String: String]())
        }
    }

    func logAppEvent(context: UIViewController?, eventName: String, params: [String: Any]?, showLog: Bool? = true) {
        guard let _ = CastledUserDefaults.shared.userId,!isCurrentlyDisplaying else {
            return
        }
        if CastledConfigs.sharedInstance.enableInApp == false {
            CastledLog.castledLog("Display Inapp: \(CastledExceptionMessages.inAppDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        self.castledInAppsQueue.async { [self] in
            if self.savedInApps.isEmpty {
                self.prefetchInApps()
            }
            var satisfiedEvents = [CastledInAppObject]()
            let filteredInApps = self.savedInApps.filter { $0.trigger?.eventName == eventName }
            if !filteredInApps.isEmpty {
                let evaluator = CastledInAppTriggerEvaluator()
                for event in filteredInApps {
                    if evaluator.shouldTriggerEvent(filter: event.trigger?.eventFilter, params: params, showLog: showLog) {
                        satisfiedEvents.append(event)
                    }
                }
            }
            if let events = findTriggeredInApps(inAppsArray: satisfiedEvents),!events.isEmpty {
                self.validateInappBeforeDisplay(events)
            }
        }
    }

    // MARK: - Display methods

    private func validateInappBeforeDisplay(_ events: [CastledInAppObject]) {
        DispatchQueue.main.async {
            var campaigns = events
            let currentTopVc = self.getTopViewController()
            self.castledInAppsQueue.async {
                if let satisiiedIndex = events.firstIndex(where: { item in
                    self.isSatisfiedWithGlobalIntervalBtwDisplays(inAppObj: item) && self.canShowInViewController(currentTopVc)
                }) {
                    self.displayInappNotification(event: campaigns[satisiiedIndex])
                    campaigns.remove(at: satisiiedIndex)
                }
                self.enqueInappObject(campaigns)
            }
        }
    }

    private func displayInappNotification(event: CastledInAppObject) {
        if self.isCurrentlyDisplaying {
            self.enqueInappObject([event])
            return
        }
        self.isCurrentlyDisplaying = true

        DispatchQueue.main.async {
            let inAppDisplaySettings = InAppDisplayConfig()
            inAppDisplaySettings.populateConfigurationsFrom(inAppObject: event)

            let castle = CastledCommonClass.instantiateFromNib(vc: CastledInAppDisplayViewController.self)
            castle.view.isHidden = false // added this to call viewdidload. it was not getting called after initialising from xib https://stackoverflow.com/questions/913627/uiviewcontroller-viewdidload-not-being-called
            //  castle.loadView()

            if castle.showInAppViewControllerFromNotification(inAppObj: event, inAppDisplaySettings: inAppDisplaySettings) {
                self.saveInappDisplayStatus(event: event)
                self.removeFromPendingItems(event)
            } else {
                self.isCurrentlyDisplaying = false
            }
        }
    }

    private func saveInappDisplayStatus(event: CastledInAppObject) {
        let currentTime = Date().timeIntervalSince1970
        var savedInApptriggers = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSavedInappConfigs) as? [[String: String]]) ?? [[String: String]]()
        if let index = savedInApptriggers.firstIndex(where: { String(event.notificationID) == $0[CastledConstants.InAppsConfigKeys.inAppNotificationId.rawValue] }) {
            var newValues = savedInApptriggers[index]
            var counter = Int(newValues[CastledConstants.InAppsConfigKeys.inAppCurrentDisplayCounter.rawValue] ?? "0") ?? 0
            counter += 1
            newValues[CastledConstants.InAppsConfigKeys.inAppCurrentDisplayCounter.rawValue] = "\(counter)"
            newValues[CastledConstants.InAppsConfigKeys.inAppLastDisplayedTime.rawValue] = "\(currentTime)"
            savedInApptriggers[index] = newValues
        } else {
            savedInApptriggers.append([CastledConstants.InAppsConfigKeys.inAppLastDisplayedTime.rawValue: "\(currentTime)",
                                       CastledConstants.InAppsConfigKeys.inAppCurrentDisplayCounter.rawValue: "1",
                                       CastledConstants.InAppsConfigKeys.inAppNotificationId.rawValue: String(event.notificationID)])
        }
        CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSavedInappConfigs, savedInApptriggers)
        CastledUserDefaults.setString(CastledUserDefaults.kCastledLastInappDisplayedTime, "\(currentTime)")
    }

    // MARK: - Trgigger Evaluation

    private func findTriggeredInApps(inAppsArray: [CastledInAppObject]) -> [CastledInAppObject]? {
        //         return inAppsArray.last
        //        let count = 1
        //        if inAppsArray.count>count{
        //            return inAppsArray[count]
        //        }
        let savedInApptriggers = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSavedInappConfigs) as? [[String: String]]) ?? [[String: String]]()
        let currentTime = Date().timeIntervalSince1970
        let filteredArray = inAppsArray.filter { inAppObj in
            let parentId = inAppObj.notificationID
            // Check if the savedInApptriggers contains the id
            if savedInApptriggers.contains(where: { Int($0[CastledConstants.InAppsConfigKeys.inAppNotificationId.rawValue] ?? "-1") == parentId }) {
                guard let savedValues = savedInApptriggers.first(where: { Int($0[CastledConstants.InAppsConfigKeys.inAppNotificationId.rawValue] ?? "") == parentId }),
                      let currentCounter = Int(savedValues[CastledConstants.InAppsConfigKeys.inAppCurrentDisplayCounter.rawValue]!),
                      let lastDiplayTime = Double(savedValues[CastledConstants.InAppsConfigKeys.inAppLastDisplayedTime.rawValue]!)
                else { return false }
                return currentCounter < inAppObj.displayConfig?.displayLimit ?? 0 &&
                    (currentTime - lastDiplayTime) > CGFloat(inAppObj.displayConfig?.minIntervalBtwDisplays ?? 0)
            } else {
                return true
            }
        }

        if !filteredArray.isEmpty {
            let event = filteredArray.sorted { lhs, rhs -> Bool in
                let lhsPriority = CastledConstants.InDisplayPriority(rawValue: lhs.priority)
                let rhsPriority = CastledConstants.InDisplayPriority(rawValue: rhs.priority)
                return lhsPriority?.sortOrder ?? 0 > rhsPriority?.sortOrder ?? 0
            } // first
            return event
        }
        return nil
    }

    private func isSatisfiedWithGlobalIntervalBtwDisplays(inAppObj: CastledInAppObject) -> Bool {
        let lastGlobalDisplayedTime = Double(CastledUserDefaults.getString(CastledUserDefaults.kCastledLastInappDisplayedTime) ?? "-100000000000") ?? -100000000000
        let currentTime = Date().timeIntervalSince1970
        return (currentTime - lastGlobalDisplayedTime) > CGFloat(inAppObj.displayConfig?.minIntervalBtwDisplaysGlobal ?? 0)
    }

    private func getTopViewController() -> String? {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow })
        {
            if let topViewController = window.rootViewController {
                var currentViewController = topViewController
                while let presentedViewController = currentViewController.presentedViewController {
                    currentViewController = presentedViewController
                }
                if let navigationController = currentViewController as? UINavigationController {
                    if let vc = navigationController.topViewController {
                        return String(describing: type(of: vc))
                    }

                } else {
                    return String(describing: type(of: currentViewController))
                }
            }
        }
        return nil
    }

    private func canShowInViewController(_ topViewController: String?) -> Bool {
        if let topVC = topViewController, let excludedVCs = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledExcludedInAppViewControllers) as? [String],!excludedVCs.isEmpty {
            return !excludedVCs.contains(topVC)
        }
        return true
    }

    func checkPendingNotificationsIfAny() {
        self.validateInappBeforeDisplay(self.getAllPendingItems())
    }

    private func enqueInappObject(_ inApps: [CastledInAppObject]) {
        self.castledInAppsPendinItemsQueue.async(flags: .barrier) {
            self.pendingInApps.mergeElements(newElements: inApps)
        }
    }

    private func removeFromPendingItems(_ inApp: CastledInAppObject) {
        self.castledInAppsPendinItemsQueue.async(flags: .barrier) {
            self.pendingInApps.removeAll { $0.notificationID == inApp.notificationID }
        }
    }

    private func getAllPendingItems() -> [CastledInAppObject] {
        var result: [CastledInAppObject]!
        self.castledInAppsPendinItemsQueue.sync {
            result = self.pendingInApps
        }
        return result
    }
}
