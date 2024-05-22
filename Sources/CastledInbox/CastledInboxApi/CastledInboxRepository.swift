//
//  CastledInboxApi.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

enum CastledInboxRepository {
    static let fetchPath = "v1/app-inbox/\(CastledInbox.sharedInstance.castledConfig.instanceId)/ios/campaigns"
    static let eventsPath = "v1/app-inbox/\(CastledInbox.sharedInstance.castledConfig.instanceId)/ios/event"

    static func getFetchRequest() -> CastledNetworkRequest {
        return CastledNetworkRequest(type: "", method: .get, parameters: ["user": CastledInbox.sharedInstance.userId])
    }

    static func getEventsRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.inboxRequest.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func reportInboxEvents(params: [[String: String]], completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        let request = CastledInboxRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { response in
            completion(response.success, response.errorMessage)
        }
    }

    static func fetchInboxItems(completion: @escaping () -> Void) {
        if CastledInbox.sharedInstance.userId.isEmpty {
            completion()
            return
        }
        let request = CastledInboxRepository.getFetchRequest()
        CastledNetworkLayer.shared.makeApiCall(request: request, path: fetchPath, responseModel: [CastledInboxItem].self, shouldDecodeResponse: true) { response in
            if response.success {
                CastledStore.refreshInboxItems(liveInboxResponse: response.result ?? [])
            } else {
                CastledLog.castledLog("Fetch inbox items failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion()
        }
    }
}
