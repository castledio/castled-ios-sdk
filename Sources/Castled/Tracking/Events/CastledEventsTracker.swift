//
//  CastledEventsTracker.swift
//  Castled
//
//  Created by antony on 02/11/2023.
//

import UIKit

class CastledEventsTracker: NSObject {
    static let shared = CastledEventsTracker()
    override private init() {}
    func trackEvent(eventName: String, params: [String: Any]) {
        if !CastledConfigsUtils.enableTracking {
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            return
        }
        Castled.sharedInstance.castledEventsTrackingQueue.async {
            // converting to [String:String], otherwise it will crash for the dates and other non supported non serialized items
            let stringDict = params.castledSerializedDictionary()
            let trackParams: [String: Any] = ["type": "track",
                                              "event": eventName,
                                              "userId": userId,
                                              "properties": stringDict,
                                              "timestamp": Date().string(),
                                              CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.productEventRequest.rawValue]
            CastledNetworkManager.reportCustomEvents(params: [trackParams]) { response in
                if response.success {
                    CastledLog.castledLog("Log event '\(eventName)' success!! ", logLevel: CastledLogLevel.debug)
                }
            }
        }
    }

    func setUserAttributes(_ attributes: CastledUserAttributes) {
        if !CastledConfigsUtils.enableTracking {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.trackingDisabled.rawValue)", logLevel: .error)
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
            return
        }
        Castled.sharedInstance.castledEventsTrackingQueue.async {
            // converting to [String:String], otherwise it will crash for the dates and other non supported non serialized items
            let stringDict = attributes.getAttributes().castledSerializedDictionary()
            let trackParams: [String: Any] = [
                "userId": userId,
                "traits": stringDict,
                "timestamp": Date().string(),
                CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.userAttributes.rawValue,
            ]
            CastledNetworkManager.reportUserAttributes(params: trackParams) { _ in
            }
        }
    }
}
