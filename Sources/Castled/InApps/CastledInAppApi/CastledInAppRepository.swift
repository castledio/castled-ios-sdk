//
//  CastledInAppRepository.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledInAppRepository {
    static let fetchPath = "v1/inapp/\(CastledInApp.sharedInstance.castledConfig.instanceId)/ios/campaigns"
    static let eventsPath = "v1/inapp/\(CastledInApp.sharedInstance.castledConfig.instanceId)/ios/event"

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
        let request = CastledInAppRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { _ in
        }
    }

    static func fetchInAppItems(completion: @escaping () -> Void) {
        let request = CastledInAppRepository.getFetchRequest()
        CastledNetworkLayer.shared.makeApiCall(request: request, path: fetchPath, responseModel: [CastledInAppObject].self, shouldDecodeResponse: true) { response in
            if response.success {
                DispatchQueue.global().async {
                    let encoder = JSONEncoder()
                    if let data = try? encoder.encode(response.result) {
                        CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledInAppsList, data)
                        CastledInAppsDisplayController.sharedInstance.prefetchInApps()
                    }
                    completion()
                }
            } else { completion()
            }

            print("Inapp Response:", response.result?.count ?? 0)
            print("after result \(Thread.current)")
        }
    }
}
