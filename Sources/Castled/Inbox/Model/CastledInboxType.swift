//
//  CastledInboxType.swift
//  Castled
//
//  Created by antony on 31/08/2023.
//
import RealmSwift

@objc public enum CastledInboxType: Int, RawRepresentable,PersistableEnum {
    case messageWithMedia = 0
    case messageBanner
    case messageBannerNoIcon
    case other

    public typealias RawValue = String

    public init?(rawValue: RawValue) {
        switch rawValue {
            case "MESSAGE_WITH_MEDIA": self = .messageWithMedia
            case "MESSAGE_BANNER": self = .messageBanner
            case "MESSAGE_BANNER_NO_ICON": self = .messageBannerNoIcon
            default: self = .other
        }
    }

    public var rawValue: RawValue {
        switch self {
            case .messageWithMedia: return "MESSAGE_WITH_MEDIA"
            case .messageBanner: return "MESSAGE_BANNER"
            case .messageBannerNoIcon: return "MESSAGE_BANNER_NO_ICON"
            case .other: return "OTHER"
        }
    }
}
