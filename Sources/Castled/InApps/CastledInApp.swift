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
    lazy var castledConfig = CastledShared.sharedInstance.getCastledConfig()
    private var isInitilized = false

    override private init() {}

    @objc func initializeInApp() {
        if !castledConfig.enableInApp {
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
        if !castledConfig.enableInApp {
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
}
