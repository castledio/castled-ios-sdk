//
//  CastledConstants.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

@_spi(CastledInternal)

public enum CastledConstants {
    // Plist Key for enable/ Disable swizzling

    static let kCastledPlatformValue = "ios"
    static let kCastledPlatformKey = "platform"

    public static let kCastledSwzzlingDisableKey = "CastledSwizzlingDisabled"
    static let kCastledExcludedInAppViewControllers = "CastledExcludedInppViews"
    static let kCastledSwizzledMethodPrefix = "swizzled_"
    static let kCastledFolder = "Castled"

    public enum DispatchQueues {
        static let CastledCommonQueue = "CastledCommonQueue"
        static let CastledNotificationQueue = "CastledNotificationQueue"
        static let CastledProfileQueue = "CastledProfileQueue"
    }

    public enum PushNotification {
        public static let castledKey = "castled"
        static let apsKey = "aps"
        static let badgeKey = "badge"
        static let inboxCopyEnabled = "inboxCopyEnabled"
        static let isCastledSilentPush = "csp"
        static let contentAvailable = "content-available"
        static let userId = "userId"
        static let deviceId = "deviceId"

        enum Token {
            static let apnsToken = "apnsToken"
            static let fcmToken = "fcmToken"
        }

        enum ApsProperties {
            static let category = "category"
        }

        public enum CustomProperties {
            public static let notificationId = "castled_notification_id"
            static let teamId = "team_id"
            static let sourceContext = "source_context"
            static let categoryActions = "category_actions"
            static let keyValuePair = "key_vals"
            public enum Category {
                static let type = "type"
                static let name = "name"
                static let actionComponents = "actionComponents"

                public enum Action {
                    static let actionId = "actionId"
                    static let clickAction = "clickAction"
                    static let clickActionUrl = "clickActionUrl"
                    static let url = "url"
                    static let useWebView = "useWebview"
                    public static let keyVals = "keyVals"
                    static let buttonTitle = "buttonTitle"
                    static let label = "label"
                }
            }
        }

        public enum ClickActionType: String, Codable {
            case navigateToScreen = "NAVIGATE_TO_SCREEN"
            case deepLink = "DEEP_LINKING"
            case richLanding = "RICH_LANDING"
            case defaultAction = "DEFAULT"
            case discardNotification = "DISMISS_NOTIFICATION"
            case requestPushPermission = "REQUEST_PUSH_PERMISSION" // this is for inapp
            case custom = "CUSTOM" // this is for inapp
            case none = "NONE" // this is for inapp
        }
    }

    public enum EventsReporting {
        public static let events = "events"
    }

    enum CastledEventTypes: String {
        case cliked = "CLICKED"
        case discarded = "DISCARDED"
        case received = "RECEIVED"
        case viewed = "VIEWED" // this is for inapp
    }

    enum InAppsConfigKeys: String {
        case inAppNotificationId = "nid"
        case inAppCurrentDisplayCounter = "dc"
        case inAppLastDisplayedTime = "ldt"
    }

    enum InDisplayPriority: String, Comparable {
        case urgent = "URGENT"
        case high = "HIGH"
        case moderate = "MODERATE"
        case low = "LOW"
        case minimum = "MINIMUM"
        var sortOrder: Int {
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

        static func == (lhs: InDisplayPriority, rhs: InDisplayPriority) -> Bool {
            return lhs.sortOrder == rhs.sortOrder
        }

        static func < (lhs: InDisplayPriority, rhs: InDisplayPriority) -> Bool {
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    public enum CastledNetworkRequestType: String {
        case pushRequest = "push"
        case userRegisterationRequest = "userRegn"
        case inappRequest = "inapp"
        case inboxRequest = "inbox"
        case deviceInfoRequest = "deviceInfo"
        case productEventRequest = "prodEvent"
//        case userEventRequest = "userEvent"
        case userAttributes = "userAttrs"
        case sessionTracking = "session"
        case logoutUser = "logout"
    }

    enum Sessions {
        static let sessionType = "sessionEventType"
        static let sessionStarted = "session_started"
        static let sessionClosed = "session_ended"
        static let sessionId = "sessionId"
        static let sessionLastDuration = "duration"
        static let sessionisFirstSession = "firstSession"
        static let sessionTimeStamp = "timestamp"
        static let userId = "userId"
        static let properties = "properties"
        static let deviceId = "deviceId"
    }

    enum Request {
        static let AUTH_KEY = "Auth-Key"
        static let APP_ID = "App-Id"
        static let Platform = "Platform"
    }

    enum AppGroupID {
        // Dont cleanup this code.This is to separate this key from CastledUserDefault Class
        static let kCastledAppGroupId = "_castledAppGroupId_"
    }
}
