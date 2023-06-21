//
//  CastledNotificationMediaObject.swift
//  CastledNotificationContent
//
//  Created by antony on 17/05/2023.
//

import Foundation
// MARK: - CastledNotificationMediaObject
internal struct CastledNotificationMediaObject: Codable {
    
    internal var mediaUrl,title,subTitle,thumbUrl,clickAction,body: String
    internal var keyVals : [String:String]?
    internal let mediaType: CNMediaType?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case body = "body"
        
        case subTitle = "subtitle"
        case mediaUrl = "mediaUrl"
        case thumbUrl = "thumbUrl"
        case mediaType = "richMediaType"
        case clickAction = "clickAction"
        case keyVals     = "keyVals"
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        self.subTitle = (try? container.decodeIfPresent(String.self, forKey: .subTitle)) ?? ""
        self.mediaUrl = (try? container.decodeIfPresent(String.self, forKey: .mediaUrl)) ?? ""
        self.thumbUrl = (try? container.decodeIfPresent(String.self, forKey: .thumbUrl)) ?? self.mediaUrl
        self.mediaType = (try? container.decodeIfPresent(CNMediaType.self, forKey: .mediaType)) ?? .image
        self.clickAction = (try? container.decodeIfPresent(String.self, forKey: .clickAction)) ?? ""
        self.body = (try? container.decodeIfPresent(String.self, forKey: .body)) ?? ""
        
        self.keyVals = (try? container.decodeIfPresent([String:String].self, forKey: .keyVals)) ?? [String:String]()
        
        
    }
    
    internal enum  CNMediaType: String, Codable {
        case image   = "IMAGE"
        case video   = "VIDEO"
        case audio   = "AUDIO"
        
    }
}
