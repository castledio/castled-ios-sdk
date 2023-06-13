//
//  InAppModel.swift
//  Castled
//
//  Created by antony on 11/04/2023.
//

import Foundation
// MARK: - InAppObject
internal struct CastledInAppObject: Codable {
    internal let teamID, notificationID: Int
    internal let sourceContext, priority: String
    internal let message: CIMessage?
    internal let displayConfig: CIDisplayConfig?
    internal let trigger: CITrigger?
    internal let startTs: Int64
    internal let endTs: Int64
    internal let ttl: String
    
    enum CodingKeys: String, CodingKey {
        case teamID = "teamId"
        case notificationID = "notificationId"
        case sourceContext, priority, message, displayConfig, trigger, startTs, endTs, ttl
    }
    
    internal init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        self.teamID     = (try? container.decodeIfPresent(Int.self, forKey: .teamID)) ?? 0
        self.notificationID     = (try? container.decodeIfPresent(Int.self, forKey: .notificationID)) ?? 0
        self.priority     = (try? container.decodeIfPresent(String.self, forKey: .priority)) ?? "HIGH"
        self.sourceContext     = (try? container.decodeIfPresent(String.self, forKey: .sourceContext)) ?? ""
        self.message     = (try? container.decodeIfPresent(CIMessage.self, forKey: .message))
        self.displayConfig     = (try? container.decodeIfPresent(CIDisplayConfig.self, forKey: .displayConfig))
        self.trigger     = (try? container.decodeIfPresent(CITrigger.self, forKey: .trigger))
        self.startTs     = (try? container.decodeIfPresent(Int64.self, forKey: .startTs)) ?? 0
        self.endTs     = (try? container.decodeIfPresent(Int64.self, forKey: .endTs)) ?? 0
        self.ttl     = (try? container.decodeIfPresent(String.self, forKey: .ttl)) ?? ""
    }
}

// MARK: - DisplayConfig
internal struct CIDisplayConfig: Codable {
    internal let displayLimit, minIntervalBtwDisplays, minIntervalBtwDisplaysGlobal, autoDismissInterval: Int
}

// MARK: - Message
internal struct CIMessage: Codable {
    internal let type: CIMessageType
    internal let modal: CIModalPresentation?
    internal let fs   : CIFullScreenPresentation?
    internal let banner   : CIBannerPresentation?
    
}

internal enum  CIMessageType: String, Codable {
    case modal   = "MODAL"
    case banner  =  "BANNER"
    case fs      = "FULL_SCREEN"
    
}

internal struct CIBannerPresentation: Codable {
    internal let type: String
    internal let imageURL: String
    internal let clickAction : CIButtonActionsType
    internal let  url, body, bgColor: String
    internal let fontSize: Int
    internal let fontColor: String
    internal let keyVals: [String : String]?
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case keyVals
        case imageURL = "imageUrl"
        case clickAction, url, body, bgColor, fontSize, fontColor
    }
}

// MARK: - Modal
internal struct CIModalPresentation: Codable {
    internal let type: String
    internal let imageURL: String
    internal let defaultClickAction: String
    internal let url: String
    internal let title, titleFontColor: String
    internal let titleFontSize: Int
    internal let titleBgColor, body, bodyFontColor: String
    internal let bodyFontSize: Int
    internal let bodyBgColor, screenOverlayColor: String
    internal let actionButtons: [CIActionButton]
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "imageUrl"
        case defaultClickAction, url, title, titleFontColor, titleFontSize, titleBgColor, body, bodyFontColor, bodyFontSize, bodyBgColor, screenOverlayColor, actionButtons
    }
    
    internal init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        self.type     = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        self.imageURL     = (try? container.decodeIfPresent(String.self, forKey: .imageURL)) ?? ""
        self.defaultClickAction     = (try? container.decodeIfPresent(String.self, forKey: .defaultClickAction)) ?? ""
        self.title     = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.titleFontColor     = (try? container.decodeIfPresent(String.self, forKey: .titleFontColor)) ?? ""
        self.titleFontSize     = (try? container.decodeIfPresent(Int.self, forKey: .titleFontSize)) ?? 20
        self.url     = (try? container.decodeIfPresent(String.self, forKey: .url)) ?? ""
        self.titleBgColor     = (try? container.decodeIfPresent(String.self, forKey: .titleBgColor)) ?? ""
        self.body     = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.bodyFontColor     = (try? container.decodeIfPresent(String.self, forKey: .bodyFontColor)) ?? ""
        self.bodyFontSize     = (try? container.decodeIfPresent(Int.self, forKey: .bodyFontSize)) ?? 18
        self.bodyBgColor     = (try? container.decodeIfPresent(String.self, forKey: .bodyBgColor)) ?? ""
        self.screenOverlayColor     = (try? container.decodeIfPresent(String.self, forKey: .screenOverlayColor)) ?? ""
        self.actionButtons     = (try? container.decodeIfPresent([CIActionButton].self, forKey: .actionButtons)) ?? []
        
        
    }
}

internal struct CIFullScreenPresentation: Codable {
    internal let type: String
    internal let imageURL: String
    internal let defaultClickAction: String
    internal let url: String
    internal let title, titleFontColor: String
    internal let titleFontSize: Int
    internal let titleBgColor, body, bodyFontColor: String
    internal let bodyFontSize: Int
    internal let bodyBgColor, screenOverlayColor: String
    internal let actionButtons: [CIActionButton]
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case imageURL = "imageUrl"
        case defaultClickAction, url, title, titleFontColor, titleFontSize, titleBgColor, body, bodyFontColor, bodyFontSize, bodyBgColor, screenOverlayColor, actionButtons
    }
    
    internal init(from decoder: Decoder) throws {
        let container       = try decoder.container(keyedBy: CodingKeys.self)
        self.type     = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        self.imageURL     = (try? container.decodeIfPresent(String.self, forKey: .imageURL)) ?? ""
        self.defaultClickAction     = (try? container.decodeIfPresent(String.self, forKey: .defaultClickAction)) ?? ""
        self.title     = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.titleFontColor     = (try? container.decodeIfPresent(String.self, forKey: .titleFontColor)) ?? ""
        self.titleFontSize     = (try? container.decodeIfPresent(Int.self, forKey: .titleFontSize)) ?? 20
        self.url     = (try? container.decodeIfPresent(String.self, forKey: .url)) ?? ""
        self.titleBgColor     = (try? container.decodeIfPresent(String.self, forKey: .titleBgColor)) ?? ""
        self.body     = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.bodyFontColor     = (try? container.decodeIfPresent(String.self, forKey: .bodyFontColor)) ?? ""
        self.bodyFontSize     = (try? container.decodeIfPresent(Int.self, forKey: .bodyFontSize)) ?? 18
        self.bodyBgColor     = (try? container.decodeIfPresent(String.self, forKey: .bodyBgColor)) ?? ""
        self.screenOverlayColor     = (try? container.decodeIfPresent(String.self, forKey: .screenOverlayColor)) ?? ""
        self.actionButtons     = (try? container.decodeIfPresent([CIActionButton].self, forKey: .actionButtons)) ?? []
    }
}

// MARK: - ActionButton
internal struct CIActionButton: Codable {
    internal let clickAction : CIButtonActionsType
    internal let label, url, buttonColor: String
    internal let fontColor, borderColor: String
    internal let keyVals: [String : String]?
}

internal enum  CIButtonActionsType: String, Codable {
    case deep_linking        = "DEEP_LINKING"
    case navigate_to_Screen  = "NAVIGATE_TO_SCREEN"
    case rich_landing        = "RICH_LANDING"
    case dismiss             = "DISMISS_NOTIFICATION"
    case request_push_permission    = "REQUEST_PUSH_PERMISSION"
    case none                = "NONE"
    
    
}
// MARK: - KeyVals

internal struct CIKeyVals: Codable {
    let product: String
}

// MARK: - Trigger
internal struct CITrigger: Codable {
    internal let type, eventID : String
    internal let eventName : String
    internal let eventFilter: CIEventFilter
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case eventID = "eventId"
        case eventName, eventFilter
    }
}

internal enum  CIEventType: String, Codable {
    case page_viewed = "page_viewed"
    case app_opened = "app_opened"
    
    
}

// MARK: - EventFilter
internal struct CIEventFilter: Codable {
    internal let type : String
    let joinType : CITriggerJoinType
    let filters: [CIEventFilters]?
    
}

// MARK: - CIEventTrigger
struct CIEventFilters: Codable {
    let type, name: String
    let operation: CITriggerOperation
}

internal enum  CITriggerJoinType: String, Codable {
    case and  = "AND"
    case or  = "OR"
    
}
// MARK: - Operation
struct CITriggerOperation: Codable {
    let type : CIOperationType
    let propertyType : CITriggerPropertyType
    let  value: String
}

internal enum  CITriggerPropertyType: String, Codable {
    case string  = "string"
    case date  = "date"
    case number    = "number"
    case timestamp    = "timestamp"
    case zoned_timestamp    = "zoned_timestamp"
    case bool    = "bool"
    
    
}

internal enum  CIOperationType: String, Codable {
    case EQ = "EQ"
    case NEQ = "NEQ"
    case GT = "GT"
    case LT = "LT"
    case GTE = "GTE"
    case LTE = "LTE"
    case BETWEEN = "BETWEEN"
    case CONTAINS = "CONTAINS"
    case NOTCONTAINS = "NOT_CONTAINS"
}
// MARK: - Encode/decode helpers

@objcMembers class JSONNull: NSObject, Codable {
    
    internal static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    override internal init() {}
    
    internal required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
