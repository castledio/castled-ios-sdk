//
//  CastledConstants.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

public class CastledConstants {
    
    //Plist Key for enable/ Disable swizzling
    static let kCastledSwzzlingDisableKey          = "CastledSwizzlingDisabled"
    
    
    public static let kCastledPushActionTypeNavigate       = "NAVIGATE_TO_SCREEN"
    public static let kCastledPushActionTypeDeeplink       = "DEEP_LINKING"
    public static let kCastledPushActionTypeDiscardNotifications      = "DISMISS_NOTIFICATION"
    public static let kCastledPushActionTypeRichLanding      = "RICH_LANDING"
    
    public struct PushNotification {
        
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
            public static let defaultActionURL = "default_action_url"
            public static let defaultAction = "default_action"
            public static let keyValuePair = "key_vals"
            public struct Category {
                public static let type = "type"
                public static let name = "name"
                public static let actionComponents = "actionComponents"
                
                public struct Action {
                    public static let actionId = "actionId"
                    public static let clickAction = "clickAction"
                    public static let url = "url"
                    public static let useWebView = "useWebview"
                }
            }
        }
        
        enum ActionType: String {
            case navigateToScreen = "NAVIGATE_TO_SCREEN"
            case deepLink = "DEEP_LINKING"
            case discardNotification = "DISMISS_NOTIFICATION"
            case richLanding = "RICH_LANDING"
            case defaultAction = "DEFAULT"
        }
        
        enum EventTypes: String {
            case send = "SEND"
            case clicked = "CLICKED"
            case discarded = "DISCARDED"
            case received = "RECEIVED"
            case foreground = "FOREGROUND"
            case viewed = "VIEWED"
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
    
    enum PushNotificationActionType : String{
        case navigateToScreen = "NAVIGATE_TO_SCREEN"
        case deepLink = "DEEP_LINKING"
        case discardNotification = "DISMISS_NOTIFICATION"
        case richLanding = "RICH_LANDING"
        case defaultAction = "DEFAULT"
    }
    
    
    
    internal enum  CastledEventTypes: String {
        case send            = "SEND"
        case cliked          = "CLICKED"
        case discarded       = "DISCARDED"
        case received        = "RECEIVED"
        case foreground      = "FOREGROUND"
        case viewed          = "VIEWED"
        
        
    }
    
    internal static let CastledSlugValueIdentifierKey    = "ceis"
    
    internal enum  CastledSlugValueEventIdentifier: String {
        case push            = "push"
        case inapp           = "inapp"
    }
    
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
