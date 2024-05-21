//
//  CastledEventsRequestHandler.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledEventsRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        // two types are ther user attributes andd product event
        if let requestType = requests.first?.type as? String {
            if requestType == CastledConstants.CastledNetworkRequestType.userAttributes.rawValue {
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

            } else {
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
    }
}
