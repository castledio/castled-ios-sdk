//
//  CastledPushNotificationLogoutRequestHandler.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

class CastledPushNotificationLogoutRequestHandler: CastledNetworkRequestHandler {
    static func handleRequest(requests: [CastledNetworkRequest], onSuccess: @escaping ([CastledNetworkRequest]) -> Void, onError: @escaping ([CastledNetworkRequest]) -> Void) {
        let castledGroup = DispatchGroup()
        var processedRequests = [CastledNetworkRequest]()
        for request in requests {
            castledGroup.enter()
            if let userId = request.parameters?[CastledConstants.PushNotification.userId] as? String,
               userId == CastledPushNotification.sharedInstance.userId
            {
                // adding this condition to prevent retrying for a previous user who logged in with the same user ID.
                processedRequests.append(request)
                castledGroup.leave()
                continue
            }

            let newRequest = request
            CastledNetworkLayer.shared.makeApiCall(request: newRequest, path: CastledPushNotificationRepository.logoutPath) { response in
                if response.success {
                    processedRequests.append(request)
                }
                castledGroup.leave()
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
