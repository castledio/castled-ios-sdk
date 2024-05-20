//
//  CastledInboxRequestHandler.swift
//  CastledInbox
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

class CastledInboxRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        // Collecting all events into a single array
        let batchedEvents: [[String: Any]] = requests.compactMap { request in
            request.parameters?[CastledConstants.EventsReporting.events] as? [[String: Any]]
        }.flatMap { $0 }
        let newRequest = CastledInboxRepository.getEventsRequest(params: batchedEvents)
        CastledNetworkLayer.shared.makeApiCall(request: newRequest, path: CastledInboxRepository.eventsPath) { response in
            if response.success {
                onSuccess(requests)
            } else {
                onError(requests)
            }
        }
    }
}
