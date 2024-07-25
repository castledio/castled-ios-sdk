//
//  CastledInApps.swift
//  Castled
//
//  Created by antony on 12/04/2023.
//

import Foundation
import UIKit

@objc class CastledInAppsDisplayController: NSObject {
    private var isCurrentlyDisplaying = false
    private var currentDisplayingInapp: CastledInAppObject?
    private var pendingInApps = [CastledInAppObject]()
    static var sharedInstance = CastledInAppsDisplayController()
    var savedInApps = [CastledInAppObject]()
    private let castledInAppsQueue = DispatchQueue(label: "CastledInAppsQueue", attributes: .concurrent)
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
        self.castledInAppsQueue.async {
            let sourceContext = inappObject.sourceContext
            let timezone = TimeZone.current
            let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
            let epochTime = "\(Int(Date().timeIntervalSince1970))"
            var json = ["ts": "\(epochTime)",
                        "tz": "\(abbreviation)",
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

            CastledInAppRepository.reportInappEvents(params: [json])
        }
    }

    func performButtonActionFor(buttonAction: CIActionButton? = nil, slide: CIBannerPresentation? = nil, webParams: [String: Any]? = nil) {
        var clickAction = CastledConstants.PushNotification.ClickActionType.custom.rawValue
        var params: [String: Any]?
        var url: String?
        var buttonTitle = ""

        if let action = buttonAction {
            clickAction = action.clickAction.rawValue
            if let keyVals = action.keyVals {
                params = [String: Any]()
                params?[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] = keyVals
            }
            url = action.url
            buttonTitle = action.label
        } else if let slideUp = slide {
            clickAction = slideUp.clickAction.rawValue
            if let keyVals = slideUp.keyVals {
                params = [String: Any]()
                params?[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] = keyVals
            }
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
        params?[CastledConstants.PushNotification.CustomProperties.Category.Action.buttonTitle] = buttonTitle

        let clickActionType = clickAction.getCastledClickActionType()
        CastledButtonActionHandler.notificationClicked(withNotificationType: .inapp, action: clickActionType, kvPairs: params, userInfo: params ?? [String: String]())
    }

    func logAppEvent(eventName: String, params: [String: Any]?, showLog: Bool? = true) {
        guard !CastledInApp.sharedInstance.userId.isEmpty, CastledInApp.sharedInstance.currentDisplayState != .discarded else {
            // CastledLog.castledLog("Ignoring in-app evaluation as the state is ‘discarded’ Or userId is not set.", logLevel: .debug)
            return
        }

        self.castledInAppsQueue.async(flags: .barrier) { [self] in
            if self.savedInApps.isEmpty {
                self.prefetchInApps()
            }
            var satisfiedEvents = [CastledInAppObject]()
            let filteredInApps = self.savedInApps.filter { $0.trigger?.eventName == eventName }
            if !filteredInApps.isEmpty {
                let evaluator = CastledInAppTriggerEvaluator()
                for event in filteredInApps {
                    if evaluator.shouldTriggerEvent(filter: event.trigger?.eventFilter, params: params, showLog: showLog), event.notificationID != self.currentDisplayingInapp?.notificationID {
                        satisfiedEvents.append(event)
                    }
                }
            }
            if !satisfiedEvents.isEmpty, let events = findTriggeredInApps(inAppsArray: satisfiedEvents),!events.isEmpty {
                self.validateInappBeforeDisplay(events)
            }
        }
    }

    // MARK: - Display methods

    private func validateInappBeforeDisplay(_ events: [CastledInAppObject], shouldShow: Bool = false) {
        if events.isEmpty {
            return
        }
        DispatchQueue.main.async {
            var campaigns = events
            let currentTopVc = self.getTopViewController()
            self.castledInAppsQueue.async(flags: .barrier) {
                if let satisiiedIndex = events.firstIndex(where: { item in
                    self.isSatisfiedWithGlobalIntervalBtwDisplays(inAppObj: item) && self.canShowInViewController(currentTopVc)
                }) {
                    if CastledInApp.sharedInstance.currentDisplayState == .active || shouldShow {
                        self.displayInappNotification(event: campaigns[satisiiedIndex])
                        campaigns.remove(at: satisiiedIndex)
                    } else {
                        CastledLog.castledLog("Ignoring in-app display as the state is not active.", logLevel: .debug)
                    }
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
                self.currentDisplayingInapp = event
            } else {
                self.enqueInappObject([event])
                self.isCurrentlyDisplaying = false
                self.currentDisplayingInapp = nil
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
        if let application = UIApplication.getSharedApplication() as? UIApplication,
           let scene = application.connectedScenes.first as? UIWindowScene,
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
                } else if let tabBarController = currentViewController as? UITabBarController {
                    if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController {
                        if let vc = selectedNavigationController.topViewController {
                            return String(describing: type(of: vc))
                        }
                    } else if let selectedViewController = tabBarController.selectedViewController {
                        return String(describing: type(of: selectedViewController))
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

    func checkPendingNotificationsIfAny(shouldShow: Bool = false) {
        self.validateInappBeforeDisplay(self.getAllPendingItems(), shouldShow: shouldShow)
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

    func getAllPendingItems() -> [CastledInAppObject] {
        var result: [CastledInAppObject]!
        self.castledInAppsPendinItemsQueue.sync {
            result = self.pendingInApps
        }
        return result
    }

    func resetInAppAobjects() {
        self.currentDisplayingInapp = nil
        self.isCurrentlyDisplaying = false
    }
}
