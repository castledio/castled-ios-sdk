//
//  CastledGeoFencerRepository.swift
//  CastledGeoFencer
//
//  Created by antony on 08/08/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

class CastledGeoFencerRepository: NSObject {
    static let eventsTrackingPath = "external/v1/collections/events/lists?apiSource=app&pf=ios"

    static func getEventsTrackingRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.geoFencingRequest.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func reportEventsTracking(eventName: String, params: [[String: Any]]) {
        let request = CastledGeoFencerRepository.getEventsTrackingRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsTrackingPath, withRetry: true) { response in
            if response.success {
                CastledLog.castledLog("Log event '\(eventName)' success!! ", logLevel: CastledLogLevel.debug)
            } else {
                CastledLog.castledLog("Log event '\(eventName)' failed!! : \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
        }
    }

    static func reportRegionEntry(eventName: String, params: [[String: Any]]) {
        //  userid check before api calls
        if CastledGeoFencer.sharedInstance.userId.isEmpty {
            return
        }
        let request = CastledGeoFencerRepository.getEventsTrackingRequest(params: params)

        CastledLog.castledLog("Log region entry '\(eventName)' \(params)!! ", logLevel: CastledLogLevel.debug)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsTrackingPath, withRetry: true) { response in
            if response.success {
                CastledLog.castledLog("Log event '\(eventName)' success!! ", logLevel: CastledLogLevel.debug)
            } else {
                CastledLog.castledLog("Log event '\(eventName)' failed!! : \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
        }
    }
}
