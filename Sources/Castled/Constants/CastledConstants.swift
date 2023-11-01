//
//  CastledConstants.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

class CastledConstants {
    // Plist Key for enable/ Disable swizzling

    static let kCastledSwzzlingDisableKey = "CastledSwizzlingDisabled"
    enum PushNotification {
        static let customKey = "castled"
        static let apsKey = "aps"
        enum ApsProperties {
            static let category = "category"
        }

        enum CustomProperties {
            static let notificationId = "castled_notification_id"
            static let teamId = "team_id"
            static let sourceContext = "source_context"
            static let mediaType = "media_type"
            static let mediaURL = "media_url"
            static let categoryActions = "category_actions"
            static let keyValuePair = "key_vals"
            enum Category {
                static let type = "type"
                static let name = "name"
                static let actionComponents = "actionComponents"

                enum Action {
                    static let actionId = "actionId"
                    static let clickAction = "clickAction"
                    static let clickActionUrl = "clickActionUrl"
                    static let url = "url"
                    static let useWebView = "useWebview"
                }
            }
        }

        enum ClickActionType: String, Codable {
            case navigateToScreen = "NAVIGATE_TO_SCREEN"
            case deepLink = "DEEP_LINKING"
            case richLanding = "RICH_LANDING"
            case defaultAction = "DEFAULT"
            case discardNotification = "DISMISS_NOTIFICATION"
            case requestPushPermission = "REQUEST_PUSH_PERMISSION" // this is for inapp
            case custom = "CUSTOM" // this is for inapp

            init(stringValue: String) {
                if let actionType = ClickActionType(rawValue: stringValue) {
                    self = actionType
                } else {
                    self = .custom
                }
            }

            func getCastledClickActionType() -> CastledClickActionType {
                switch self {
                    case .navigateToScreen:
                        return CastledClickActionType.navigateToScreen
                    case .deepLink:
                        return CastledClickActionType.deepLink
                    case .richLanding:
                        return CastledClickActionType.navigateToScreen
                    case .discardNotification:
                        return CastledClickActionType.dismiss
                    case .requestPushPermission:
                        return CastledClickActionType.requestForPush
                    default:
                        return CastledClickActionType.custom
                }
            }
        }
    }

    enum CastledPushCustomPropertyKeys {
        static let castledNotificationId = "castled_notification_id"
        static let teamId = "team_id"
        static let sourceContext = "source_context"
        static let mediaType = "media_type"
        static let mediaURL = "media_url"
        static let categoryActions = "category_actions"
        static let defaultActionURL = "default_action_url"
        static let defaultAction = "default_action"
        static let keyValuePair = "key_vals"
    }

    enum CastledEventTypes: String {
        case cliked = "CLICKED"
        case discarded = "DISCARDED"
        case received = "RECEIVED"
        case viewed = "VIEWED"
    }

    static let CastledNetworkRequestTypeKey = "castled_request_type"
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

    enum CastledNetworkRequestType: String {
        case pushRequest = "push"
        case inappRequest = "inapp"
        case inboxRequest = "inbox"
        case deviceInfoRequest = "deviceInfo"
    }
}
