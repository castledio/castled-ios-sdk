//
//  CastledPublicEnums.swift
//  Castled
//
//  Created by antony on 08/05/2023.
//

import Foundation
@objc public enum CastledLocation: Int {
    case US
    case AP
    case INDIA
    case TEST
    
    internal var description: String {
        switch self {
        case .US:
            return "app"
        case .AP:
            return "in"
        case .INDIA:
            return "in"
        case .TEST:
            return "test"
            
        }
    }
    
}
@objc public enum CastledPushActionType: Int {
    case deepLink
    case navigateToScreen
    case richLanding
    case other
}
