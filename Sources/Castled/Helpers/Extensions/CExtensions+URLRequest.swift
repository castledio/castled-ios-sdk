//
//  CExtensions+URLRequest.swift
//  Castled
//
//  Created by antony on 28/02/2024.
//

import Foundation

extension URLRequest {
    mutating func setAuthHeaders() {
        setValue(CastledUserDefaults.shared.userToken ?? "", forHTTPHeaderField: CastledConstants.Request.AUTH_KEY)
        setValue(Castled.sharedInstance.instanceId, forHTTPHeaderField: CastledConstants.Request.APP_ID)
        setValue(CastledConstants.kCastledPlatformValue, forHTTPHeaderField: CastledConstants.Request.Platform)
    }
}
