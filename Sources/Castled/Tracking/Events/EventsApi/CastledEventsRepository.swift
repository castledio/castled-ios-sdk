//
//  CastledEventsRepository.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledEventsRepository {
    static let eventsTrackingPath = "external/v1/collections/events/lists?apiSource=app&pf=ios"
    static let userAttributesPath = "external/v1/collections/users?apiSource=app&pf=ios"

    static func getEventsTrackingRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.productEventRequest.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func getUserAttibutesRequest(params: [String: Any]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.userAttributes.rawValue,
            method: .post,
            parameters: params)
    }

    static func reportUserAttributes(params: [String: Any]) {
        let request = CastledEventsRepository.getUserAttibutesRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: userAttributesPath, withRetry: true) { response in
            if !response.success {
                CastledLog.castledLog("Set user attributes failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } else {
                CastledLog.castledLog("Set user attributes success", logLevel: CastledLogLevel.debug)
            }
        }
    }

    static func reportEventsTracking(eventName: String, params: [[String: Any]]) {
        let request = CastledEventsRepository.getEventsTrackingRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsTrackingPath, withRetry: true) { response in
            if response.success {
                CastledLog.castledLog("Log event '\(eventName)' success!! ", logLevel: CastledLogLevel.debug)
            } else {
                CastledLog.castledLog("Log event '\(eventName)' failed!! : \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
        }
    }
}
