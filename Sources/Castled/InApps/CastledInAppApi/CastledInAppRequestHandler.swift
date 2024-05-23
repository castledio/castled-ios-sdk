//
//  CastledInAppRequestHandler.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledInAppRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        // Collecting all events into a single array
        let batchedEvents: [[String: Any]] = requests.compactMap { request in
            request.parameters?[CastledConstants.EventsReporting.events] as? [[String: Any]]
        }.flatMap { $0 }
        let newRequest = CastledInAppRepository.getEventsRequest(params: batchedEvents)
        CastledNetworkLayer.shared.makeApiCall(request: newRequest, path: CastledInAppRepository.eventsPath) { response in
            if response.success {
                onSuccess(requests)
            } else {
                onError(requests)
            }
        }
    }
}
