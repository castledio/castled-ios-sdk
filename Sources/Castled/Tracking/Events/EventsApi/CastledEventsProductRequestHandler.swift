//
//  CastledEventsRequestHandler.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledEventsProductRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        // Product event tracking
        let batchedEvents: [[String: Any]] = requests.compactMap { request in
            request.parameters?[CastledConstants.EventsReporting.events] as? [[String: Any]]
        }.flatMap { $0 }
        let newRequest = CastledEventsRepository.getEventsTrackingRequest(params: batchedEvents)
        CastledNetworkLayer.shared.makeApiCall(request: newRequest, path: CastledEventsRepository.eventsTrackingPath) { response in
            if response.success {
                onSuccess(requests)
            } else {
                onError(requests)
            }
        }
    }
}
