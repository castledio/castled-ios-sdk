//
//  CastledInAppRepository.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledInAppRepository {
    static let fetchPath = "v1/inapp/\(CastledInApp.sharedInstance.instanceId)/ios/campaigns"
    static let eventsPath = "v1/inapp/\(CastledInApp.sharedInstance.instanceId)/ios/event"

    static func getFetchRequest() -> CastledNetworkRequest {
        return CastledNetworkRequest(type: "", method: .get, parameters: ["user": CastledInApp.sharedInstance.userId])
    }

    static func getEventsRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.inappRequest.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func reportInappEvents(params: [[String: Any]]) {
        if CastledInApp.sharedInstance.userId.isEmpty {
            return
        }
        let request = CastledInAppRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { _ in
        }
    }

    static func fetchInAppItems(completion: @escaping () -> Void) {
        let request = CastledInAppRepository.getFetchRequest()
        CastledNetworkLayer.shared.makeApiCall(request: request, path: fetchPath, responseModel: [CastledInAppObject].self, shouldDecodeResponse: true) { response in
            if response.success {
                CastledInAppCoreDataOperations.shared.refreshInappItems(inAppResponse: response.result ?? []) {
                    CastledInAppsDisplayController.sharedInstance.prefetchInApps()
                    completion()
                }

            } else { completion()
            }
        }
    }
}
