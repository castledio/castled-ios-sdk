//
//  CastledNotificationMediaObject.swift
//  CastledNotificationContent
//
//  Created by antony on 17/05/2023.
//

import Foundation

// MARK: - CastledNotificationMediaObject

struct CastledNotificationMediaObject: Codable {
    var mediaUrl, title, subTitle, thumbUrl, clickAction, body: String
    var keyVals: [String: String]?
    let mediaType: CNMediaType?

    enum CodingKeys: String, CodingKey {
        case title
        case body

        case subTitle = "subtitle"
        case mediaUrl
        case thumbUrl
        case mediaType = "richMediaType"
        case clickAction
        case keyVals
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.subTitle = (try? container.decodeIfPresent(String.self, forKey: .subTitle)) ?? ""
        self.mediaUrl = (try? container.decodeIfPresent(String.self, forKey: .mediaUrl)) ?? ""
        self.thumbUrl = (try? container.decodeIfPresent(String.self, forKey: .thumbUrl)) ?? self.mediaUrl
        self.mediaType = (try? container.decodeIfPresent(CNMediaType.self, forKey: .mediaType)) ?? .text_only
        self.clickAction = (try? container.decodeIfPresent(String.self, forKey: .clickAction)) ?? ""
        self.body = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        self.keyVals = (try? container.decodeIfPresent([String: String].self, forKey: .keyVals)) ?? [String: String]()
    }

    enum CNMediaType: String, Codable {
        case image = "IMAGE"
        case video = "VIDEO"
        case audio = "AUDIO"
        case text_only = "NONE"
    }
}
