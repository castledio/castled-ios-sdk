//
//  CastledInboxApi.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

enum CastledInboxApi {
    static func getFetchRequest() -> CastledNetworkRequest {
        return CastledNetworkRequest(type: "", path: "v1/app-inbox/\(CastledInbox.sharedInstance.castledConfig.instanceId)/ios/campaigns", method: .get, parameters: ["user": CastledInbox.sharedInstance.userId])
    }
}
