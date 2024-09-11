//
//  InAppModel.swift
//  Castled
//
//  Created by antony on 11/04/2023.
//

import Foundation

@_spi(CastledInternal)

// MARK: - InAppObject

public struct CastledInAppObject: Codable, Equatable {
    public static func == (lhs: CastledInAppObject, rhs: CastledInAppObject) -> Bool {
        return lhs.notificationID == rhs.notificationID
    }

    let teamID, notificationID: Int
    let sourceContext, priority: String
    let message: CIMessage?
    let displayConfig: CIDisplayConfig?
    let trigger: CITrigger?
    let startTs: Int64
    let endTs: Int64
    let ttl: String

    enum CodingKeys: String, CodingKey {
        case teamID = "teamId"
        case notificationID = "notificationId"
        case sourceContext, priority, message, displayConfig, trigger, startTs, endTs, ttl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.teamID = (try? container.decodeIfPresent(Int.self, forKey: .teamID)) ?? 0
        self.notificationID = (try? container.decodeIfPresent(Int.self, forKey: .notificationID)) ?? 0
        self.priority = (try? container.decodeIfPresent(String.self, forKey: .priority)) ?? "HIGH"
        self.sourceContext = (try? container.decodeIfPresent(String.self, forKey: .sourceContext)) ?? ""
        self.message = (try? container.decodeIfPresent(CIMessage.self, forKey: .message))
        self.displayConfig = (try? container.decodeIfPresent(CIDisplayConfig.self, forKey: .displayConfig))
        self.trigger = (try? container.decodeIfPresent(CITrigger.self, forKey: .trigger))
        self.startTs = (try? container.decodeIfPresent(Int64.self, forKey: .startTs)) ?? 0
        self.endTs = (try? container.decodeIfPresent(Int64.self, forKey: .endTs)) ?? 0
        self.ttl = (try? container.decodeIfPresent(String.self, forKey: .ttl)) ?? ""
    }
}

// MARK: - DisplayConfig

struct CIDisplayConfig: Codable {
    let displayLimit, minIntervalBtwDisplays, minIntervalBtwDisplaysGlobal, autoDismissInterval: Int
}

// MARK: - Message

struct CIMessage: Codable {
    let type: CIMessageType
    let modal: CIModalPresentation?
    let fs: CIFullScreenPresentation?
    let banner: CIBannerPresentation?
}

enum CIMessageType: String, Codable {
    case modal = "MODAL"
    case banner = "BANNER"
    case fs = "FULL_SCREEN"
}

struct CIBannerPresentation: Codable {
    let type: CITemplateType
    let html: String?
    let url: String?

    let imageURL: String
    let clickAction: CastledConstants.PushNotification.ClickActionType
    let body, bgColor: String
    let fontSize: Int
    let fontColor: String
    let keyVals: [String: String]?
    let showCloseButton: Bool

    enum CodingKeys: String, CodingKey {
        case type
        case keyVals
        case imageURL = "imageUrl"
        case clickAction, url, body, bgColor, fontSize, fontColor, html, showCloseButton
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decodeIfPresent(CITemplateType.self, forKey: .type)) ?? .other
        self.html = (try? container.decodeIfPresent(String.self, forKey: .html))
        self.imageURL = (try? container.decodeIfPresent(String.self, forKey: .imageURL)) ?? ""
        self.clickAction = (try? container.decodeIfPresent(CastledConstants.PushNotification.ClickActionType.self, forKey: .clickAction)) ?? CastledConstants.PushNotification.ClickActionType.none
        self.url = (try? container.decodeIfPresent(String.self, forKey: .url)) ?? ""
        self.body = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.bgColor = (try? container.decodeIfPresent(String.self, forKey: .bgColor)) ?? ""
        self.fontSize = (try? container.decodeIfPresent(Int.self, forKey: .fontSize)) ?? 16
        self.fontColor = (try? container.decodeIfPresent(String.self, forKey: .fontColor)) ?? ""
        self.keyVals = (try? container.decodeIfPresent([String: String].self, forKey: .fontColor)) ?? [String: String]()
        self.showCloseButton = try container.decodeIfPresent(Bool.self, forKey: .showCloseButton) ?? true
    }
}

// MARK: - Modal

struct CIModalPresentation: Codable {
    let type: CITemplateType
    let imageURL: String
    let html: String?
    let url: String?
    let defaultClickAction: CastledConstants.PushNotification.ClickActionType
    let keyVals: [String: String]?
    let title, titleFontColor: String
    let titleFontSize: Int
    let titleBgColor, body, bodyFontColor: String
    let bodyFontSize: Int
    let bodyBgColor, screenOverlayColor: String
    let actionButtons: [CIActionButton]
    let showCloseButton: Bool
    enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "imageUrl"
        case defaultClickAction, url, title, titleFontColor, titleFontSize, titleBgColor, body, bodyFontColor, bodyFontSize, bodyBgColor, screenOverlayColor, actionButtons, html, keyVals, showCloseButton
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decodeIfPresent(CITemplateType.self, forKey: .type)) ?? .other
        self.html = (try? container.decodeIfPresent(String.self, forKey: .html)) ?? ""
        self.imageURL = (try? container.decodeIfPresent(String.self, forKey: .imageURL)) ?? ""
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.titleFontColor = (try? container.decodeIfPresent(String.self, forKey: .titleFontColor)) ?? ""
        self.titleFontSize = (try? container.decodeIfPresent(Int.self, forKey: .titleFontSize)) ?? 20
        self.titleBgColor = (try? container.decodeIfPresent(String.self, forKey: .titleBgColor)) ?? ""
        self.body = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.bodyFontColor = (try? container.decodeIfPresent(String.self, forKey: .bodyFontColor)) ?? ""
        self.bodyFontSize = (try? container.decodeIfPresent(Int.self, forKey: .bodyFontSize)) ?? 18
        self.bodyBgColor = (try? container.decodeIfPresent(String.self, forKey: .bodyBgColor)) ?? ""
        self.screenOverlayColor = (try? container.decodeIfPresent(String.self, forKey: .screenOverlayColor)) ?? ""
        self.actionButtons = (try? container.decodeIfPresent([CIActionButton].self, forKey: .actionButtons)) ?? []
        self.defaultClickAction = (try? container.decodeIfPresent(CastledConstants.PushNotification.ClickActionType.self, forKey: .defaultClickAction)) ?? CastledConstants.PushNotification.ClickActionType.none
        self.url = (try? container.decodeIfPresent(String.self, forKey: .url)) ?? ""
        self.showCloseButton = try container.decodeIfPresent(Bool.self, forKey: .showCloseButton) ?? true
        self.keyVals = (try? container.decodeIfPresent([String: String].self, forKey: .keyVals))
    }
}

struct CIFullScreenPresentation: Codable {
    let type: CITemplateType
    let html: String?
    let imageURL: String
    let url: String?
    let defaultClickAction: CastledConstants.PushNotification.ClickActionType
    let keyVals: [String: String]?
    let title, titleFontColor: String
    let titleFontSize: Int
    let titleBgColor, body, bodyFontColor: String
    let bodyFontSize: Int
    let bodyBgColor, screenOverlayColor: String
    let actionButtons: [CIActionButton]
    let showCloseButton: Bool

    enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "imageUrl"
        case defaultClickAction, url, title, titleFontColor, titleFontSize, titleBgColor, body, bodyFontColor, bodyFontSize, bodyBgColor, screenOverlayColor, actionButtons, html, keyVals, showCloseButton
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decodeIfPresent(CITemplateType.self, forKey: .type)) ?? .other
        self.html = (try? container.decodeIfPresent(String.self, forKey: .html)) ?? ""
        self.imageURL = (try? container.decodeIfPresent(String.self, forKey: .imageURL)) ?? ""
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.titleFontColor = (try? container.decodeIfPresent(String.self, forKey: .titleFontColor)) ?? ""
        self.titleFontSize = (try? container.decodeIfPresent(Int.self, forKey: .titleFontSize)) ?? 20
        self.titleBgColor = (try? container.decodeIfPresent(String.self, forKey: .titleBgColor)) ?? ""
        self.body = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.bodyFontColor = (try? container.decodeIfPresent(String.self, forKey: .bodyFontColor)) ?? ""
        self.bodyFontSize = (try? container.decodeIfPresent(Int.self, forKey: .bodyFontSize)) ?? 18
        self.bodyBgColor = (try? container.decodeIfPresent(String.self, forKey: .bodyBgColor)) ?? ""
        self.screenOverlayColor = (try? container.decodeIfPresent(String.self, forKey: .screenOverlayColor)) ?? ""
        self.actionButtons = (try? container.decodeIfPresent([CIActionButton].self, forKey: .actionButtons)) ?? []

        self.defaultClickAction = (try? container.decodeIfPresent(CastledConstants.PushNotification.ClickActionType.self, forKey: .defaultClickAction)) ?? CastledConstants.PushNotification.ClickActionType.none
        self.url = (try? container.decodeIfPresent(String.self, forKey: .url)) ?? ""
        self.keyVals = (try? container.decodeIfPresent([String: String].self, forKey: .keyVals))
        self.showCloseButton = try container.decodeIfPresent(Bool.self, forKey: .showCloseButton) ?? true
    }
}

// MARK: - ActionButton

struct CIActionButton: Codable {
    let clickAction: CastledConstants.PushNotification.ClickActionType
    let label, url, buttonColor: String
    let fontColor, borderColor: String
    let keyVals: [String: String]?
}

// MARK: - KeyVals

struct CIKeyVals: Codable {
    let product: String
}

// MARK: - Trigger

struct CITrigger: Codable {
    let type, eventID: String
    let eventName: String
    let eventFilter: CIEventFilter?

    enum CodingKeys: String, CodingKey {
        case type
        case eventID = "eventId"
        case eventName, eventFilter
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        self.eventID = (try? container.decodeIfPresent(String.self, forKey: .eventID)) ?? ""
        self.eventName = (try? container.decodeIfPresent(String.self, forKey: .eventName)) ?? ""
        self.eventFilter = (try? container.decodeIfPresent(CIEventFilter.self, forKey: .eventFilter))
    }
}

enum CITemplateType: String, Codable {
    case default_template = "DEFAULT"
    case image_buttons = "IMG_AND_BUTTONS"
    case text_buttons = "TEXT_AND_BUTTONS"
    case img_text_buttons = "IMG_TEXT_AND_BUTTONS"
    case image_only = "IMG_ONLY"
    case custom_html = "CUSTOM_HTML"
    case other = "OTHER"
}

enum CIEventType: String, Codable {
    case page_viewed
    case app_opened
}

// MARK: - EventFilter

struct CIEventFilter: Codable {
    let type: String
    let joinType: CITriggerJoinType
    let filters: [CIEventFilters]?
}

// MARK: - CIEventTrigger

struct CIEventFilters: Codable {
    let type, name: String
    let operation: CITriggerOperation
}

enum CITriggerJoinType: String, Codable {
    case and = "AND"
    case or = "OR"
}

// MARK: - Operation

struct CITriggerOperation: Codable {
    let type: CIOperationType
    let propertyType: CITriggerPropertyType
    let value: String
}

enum CITriggerPropertyType: String, Codable {
    case string
    case date
    case number
    case timestamp
    case zoned_timestamp
    case bool
}

enum CIOperationType: String, Codable {
    case EQ
    case NEQ
    case GT
    case LT
    case GTE
    case LTE
    case BETWEEN
    case CONTAINS
    case NOTCONTAINS = "NOT_CONTAINS"
}

// MARK: - Encode/decode helpers

// @objcMembers class JSONNull: NSObject, Codable {
//    static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    override init() {}
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
// }
