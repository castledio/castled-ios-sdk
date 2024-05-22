//
//  CastledEventsController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledEventsController: NSObject, CastledPreferenceStoreListener {
    static var sharedInstance = CastledEventsController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledEventsTracker.sharedInstance.userId = userId
    }

    func onUserLoggedOut() {
        CastledEventsTracker.sharedInstance.userId = ""
    }

    func trackEvent(eventName: String, params: [String: Any]) {
        if CastledEventsTracker.sharedInstance.userId.isEmpty {
            return
        }
        let stringDict = params.serializedDictionary()
        var trackParams: [String: Any] = ["type": "track",
                                          "event": eventName,
                                          "userId": CastledEventsTracker.sharedInstance.userId,
                                          "properties": stringDict,
                                          "timestamp": Date().string()]
        if CastledConfigsUtils.configs.enableSessionTracking {
            trackParams[CastledConstants.Sessions.sessionId] = CastledSessionsManager.shared.sessionId
        }
        CastledEventsRepository.reportEventsTracking(eventName: eventName, params: [trackParams])
    }

    func setUserAttributes(_ attributes: CastledUserAttributes) {
        if CastledEventsTracker.sharedInstance.userId.isEmpty {
            return
        }
        let stringDict = attributes.getAttributes().serializedDictionary()
        var trackParams: [String: Any] = [
            "userId": CastledEventsTracker.sharedInstance.userId,
            "traits": stringDict,
            "timestamp": Date().string()
        ]
        if CastledConfigsUtils.configs.enableSessionTracking {
            trackParams[CastledConstants.Sessions.sessionId] = CastledSessionsManager.shared.sessionId
        }
        CastledEventsRepository.reportUserAttributes(params: trackParams)
    }
}
