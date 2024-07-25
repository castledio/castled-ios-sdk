//
//  CastledInApp.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

@objc class CastledInApp: NSObject {
    @objc static var sharedInstance = CastledInApp()
    var userId = ""
    var enableInApp: Bool { CastledShared.sharedInstance.getCastledConfig().enableInApp }
    var instanceId: String { CastledShared.sharedInstance.getCastledConfig().instanceId }
    var currentDisplayState = CastledInappDiplayState.active
    private var isInitilized = false

    override private init() {}

    @objc func initializeInApp() {
        if !enableInApp {
            return
        }
        else if isInitilized {
            CastledLog.castledLog("In-app module already initialized..", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.inappRequest.rawValue, handler: CastledInAppRequestHandler.self)
        isInitilized = true
        CastledInAppController.sharedInstance.initialize()
        UIViewController.swizzleViewDidAppear()
        CastledLog.castledLog("In-app module initialized..", logLevel: CastledLogLevel.info)
    }

    @objc public func logPageViewedEvent(_ screenName: String?) {
        guard let screen = screenName, isValidated() else {
            return
        }

        CastledInAppsDisplayController.sharedInstance.logAppEvent(eventName: CIEventType.page_viewed.rawValue, params: ["name": screen], showLog: false)
    }

    @objc public func logCustomAppEvent(_ eventName: String, params: [String: Any]) {
        if !isValidated() {
            return
        }
        CastledInAppsDisplayController.sharedInstance.logAppEvent(eventName: eventName, params: params, showLog: false)
    }

    func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if !isValidated() {
            return
        }
        CastledInAppsDisplayController.sharedInstance.logAppEvent(eventName: CIEventType.app_opened.rawValue, params: nil, showLog: showLog)
    }

    private func isValidated() -> Bool {
        if !enableInApp {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.inAppDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
        else if userId.isEmpty {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
        else if !isInitilized {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
        return true
    }

    func displayInAppNotificationIfAny() {
        if !isValidated() {
            return
        }
        CastledInAppsDisplayController.sharedInstance.checkPendingNotificationsIfAny(shouldShow: true)
    }

    func suspendInAppNotifications() {
        CastledInApp.sharedInstance.currentDisplayState = .suspended
        CastledLog.castledLog("In-app state changed to ‘suspended’; no more in-app notifications will be displayed until ‘resumeInAppNotifications’ is called.", logLevel: CastledLogLevel.debug)
    }

    func discardInAppNotifications() {
        CastledInApp.sharedInstance.currentDisplayState = .discarded
        CastledLog.castledLog("In-app state changed to ‘discarded’; no more in-app notifications will be evaluated/displayed until ‘resumeInAppNotifications’ is called.", logLevel: CastledLogLevel.debug)
    }

    func resumeInAppNotifications() {
        CastledInApp.sharedInstance.currentDisplayState = .active
        CastledLog.castledLog("In-app state changed to ‘active’.", logLevel: CastledLogLevel.debug)
        if !isValidated() {
            return
        }
        CastledInAppsDisplayController.sharedInstance.checkPendingNotificationsIfAny()
    }
}
