//
//  CastledConstants.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

internal class CastledConstants {
    
    //Plist Key for enable/ Disable swizzling
    static let kCastledSwzzlingDisableKey          = "CastledSwizzlingDisabled"

    internal struct PushNotification {
        
        public static let customKey = "castled"
        public static let apsKey = "aps"
        
        public struct ApsProperties{
            static let category = "category"
        }
        
        public struct CustomProperties {
            public static let notificationId = "castled_notification_id"
            public static let teamId = "team_id"
            public static let sourceContext = "source_context"
            public static let mediaType = "media_type"
            public static let mediaURL = "media_url"
            public static let categoryActions = "category_actions"
            public static let keyValuePair = "key_vals"
            public struct Category {
                public static let type = "type"
                public static let name = "name"
                public static let actionComponents = "actionComponents"
                
                public struct Action {
                    public static let actionId = "actionId"
                    public static let clickAction = "clickAction"
                    public static let clickActionUrl = "clickActionUrl"
                    public static let url = "url"
                    public static let useWebView = "useWebview"
                }
            }
        }
        
         enum ClickActionType: String, Codable {
            case navigateToScreen = "NAVIGATE_TO_SCREEN"
            case deepLink         = "DEEP_LINKING"
            case richLanding      = "RICH_LANDING"
            case defaultAction    = "DEFAULT"
            case discardNotification = "DISMISS_NOTIFICATION"
            case requestPushPermission = "REQUEST_PUSH_PERMISSION"//this is for inapp
            case none                = "NONE"

        }

    }
    
    
    struct CastledPushNotificationCustomPropertyKeys{
        static let castledNotificationId =  "castled_notification_id"
        static let teamId = "team_id"
        static let sourceContext = "source_context"
        static let mediaType = "media_type"
        static let mediaURL = "media_url"
        static let categoryActions = "category_actions"
        static let defaultActionURL = "default_action_url"
        static let defaultAction = "default_action"
        static let keyValuePair =  "key_vals"
    }

    
    internal enum CastledEventTypes: String {
       // case send            = "SEND"
        case cliked          = "CLICKED"
        case discarded       = "DISCARDED"
        case received        = "RECEIVED"
//        case foreground      = "FOREGROUND"
        case viewed          = "VIEWED"
        
        
    }
    
    internal static let CastledSlugValueIdentifierKey    = "ceis"

    internal enum InAppsConfigKeys: String {
        case inAppNotificationId = "nid"
        case inAppCurrentDisplayCounter = "dc"
        case inAppLastDisplayedTime = "ldt"
    }
    
    internal enum InDisplayPriority: String, Comparable {
        case urgent = "URGENT"
        case high = "HIGH"
        case moderate = "MODERATE"
        case low = "LOW"
        case minimum = "MINIMUM"
        
        
        internal var sortOrder: Int {
            switch self {
                case .urgent:
                    return 4
                case .high:
                    return 3
                case .moderate:
                    return 2
                case .low:
                    return 1
                case .minimum:
                    return 0


            }
        }
        
        static func ==(lhs: InDisplayPriority, rhs: InDisplayPriority) -> Bool {
            return lhs.sortOrder == rhs.sortOrder
        }
        
        static func <(lhs: InDisplayPriority, rhs: InDisplayPriority) -> Bool {
            return lhs.sortOrder < rhs.sortOrder
        }
    }
}
