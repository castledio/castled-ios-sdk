//
//  CastledPublicEnums.swift
//  Castled
//
//  Created by antony on 08/05/2023.
//

import Foundation

@objc public enum CastledLocation: Int, Codable {
    case US
    case AP
    case INDIA
    case TEST
    var description: String {
        switch self {
            case .US:
                return "api"
            case .AP:
                return "in"
            case .INDIA:
                return "in"
            case .TEST:
                return "test"
        }
    }
}

@objc public enum CastledClickActionType: Int {
    case deepLink
    case navigateToScreen
    case richLanding
    case requestForPush
    case dismiss
    case custom
    case none
}

@objc public enum CastledNotificationType: Int {
    case push
    case inapp
    case inbox
    case other
    public func value() -> String {
        switch self {
            case .push: return "push"
            case .inapp: return "inapp"
            case .inbox: return "inbox"
            case .other: return "other"
        }
    }
}

@objc public enum CastledPushTokenType: Int {
    case apns
    case fcm
}

@objc public enum CastledLogLevel: Int, Codable {
    case none
    case error
    case info
    case debug
}
