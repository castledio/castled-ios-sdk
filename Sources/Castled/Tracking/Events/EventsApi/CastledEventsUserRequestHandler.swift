//
//  CastledEventsUSerRequestHandler.swift
//  Castled
//
//  Created by antony on 22/05/2024.
//

import Foundation

class CastledEventsUserRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        // User attributes tracking
        let castledGroup = DispatchGroup()
        var processedRequests = [CastledNetworkRequest]()
        requests.forEach { request in
            let newRequest = request
            castledGroup.enter()
            CastledNetworkLayer.shared.makeApiCall(request: newRequest, path: CastledEventsRepository.userAttributesPath) { response in
                if response.success {
                    processedRequests.append(request)
                    castledGroup.leave()
                } else {
                    castledGroup.leave()
                }
            }
        }
        castledGroup.notify(queue: .main) {
            if processedRequests.isEmpty {
                onError(requests)
            } else {
                onSuccess(processedRequests)
            }
        }
    }
}
