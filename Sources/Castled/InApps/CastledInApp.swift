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
    let castledConfig = Castled.sharedInstance.getCastledConfig()
    private var isInitilized = false

    override private init() {}

    @objc public func initializeInApp() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("In-app initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("In-app module already initialized.. \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.info)
            return
        }
        isInitilized = true
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.inappRequest.rawValue] = CastledInAppRequestHandler.self
        CastledInAppController.sharedInstance.initialize()
        UIViewController.swizzleViewDidAppear()
        CastledLog.castledLog("In-app module initialized..", logLevel: CastledLogLevel.info)
    }

    @objc public func logAppPageViewedEvent(_ viewContoller: UIViewController) {
        if !isInitilized {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.inAppDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInAppsDisplayController.sharedInstance.logAppEvent(context: viewContoller, eventName: CIEventType.page_viewed.rawValue, params: ["name": String(describing: type(of: viewContoller))], showLog: false)
    }

    @objc public func logCustomAppEvent(_ eventName: String, params: [String: Any]) {
        if !isInitilized {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.inAppDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInAppsDisplayController.sharedInstance.logAppEvent(context: nil, eventName: eventName, params: params, showLog: false)
    }

    func logAppOpenedEventIfAny(showLog: Bool? = false) {
        if !isInitilized {
            CastledLog.castledLog("In-app operation failed: \(CastledExceptionMessages.inAppDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInAppsDisplayController.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil, showLog: showLog)
    }
}
