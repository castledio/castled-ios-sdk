//
//  CastledEventsTracker.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//

import UIKit

class CastledEventsTracker: NSObject {
    static let sharedInstance = CastledEventsTracker()
    var userId = ""
    private var isInitilized = false

    override private init() {}
    func initializeEventsTracking() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("Events tracking initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Events tracking already initialized..", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.userAttributes.rawValue, handler: CastledEventsUserRequestHandler.self)
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.productEventRequest.rawValue, handler: CastledEventsProductRequestHandler.self)
        isInitilized = true
        CastledEventsController.sharedInstance.initialize()
    }

    func trackEvent(eventName: String, params: [String: Any]) {
        if !isInitilized {
            CastledLog.castledLog("Events tracking failed: \(CastledExceptionMessages.trackingDisabled.rawValue)", logLevel: .error)
            return
        }
        if CastledEventsTracker.sharedInstance.userId.isEmpty {
            CastledLog.castledLog("Events tracking failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
            return
        }
        Castled.sharedInstance.castledCommonQueue.async {
            CastledEventsController.sharedInstance.trackEvent(eventName: eventName, params: params)
        }
    }

    func setUserAttributes(_ attributes: CastledUserAttributes) {
        if !isInitilized {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.trackingDisabled.rawValue)", logLevel: .error)
            return
        }
        if CastledEventsTracker.sharedInstance.userId.isEmpty {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
            return
        }
        Castled.sharedInstance.castledCommonQueue.async {
            CastledEventsController.sharedInstance.setUserAttributes(attributes)
        }
    }
}
