//
//  CastledSessionRepository.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledSessionRepository {
    static let eventsPath = "external/v1/collections/session-events/lists"

    static func getEventsRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.sessionTracking.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func reportSessionEvents(params: [[String: Any]]) {
        let request = CastledSessionRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { _ in
        }
    }
}
