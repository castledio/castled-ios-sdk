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
        if !CastledConfigs.sharedInstance.enableTracking {
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            return
        }
        // converting to [String:String], otherwise it will crash for the dates and other non supported non serialized items
        let stringDict = params.compactMapValues { "\($0)" }
        let trackParams: [String: Any] = ["type": "track",
                                          "event": eventName,
                                          "userId": userId,
                                          "properties": stringDict,
                                          "timestamp": Date().string(),
                                          CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.productEventRequest.rawValue]
        Castled.reportCustomEvents(params: [trackParams]) { _ in
        }
    }

    func setUserAttributes(params: [String: Any]) {
        if !CastledConfigs.sharedInstance.enableTracking {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.trackingDisabled.rawValue)", logLevel: .error)
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Set userAttributes failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
            return
        }
        // converting to [String:String], otherwise it will crash for the dates and other non supported non serialized items
        let stringDict = params.compactMapValues { "\($0)" }
        let trackParams: [String: Any] = [
            "userId": userId,
            "traits": stringDict,
            "timestamp": Date().string(),
            CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.userProfileRequest.rawValue,
        ]
        Castled.reportUserAttributes(params: trackParams) { _ in
        }
    }
}
