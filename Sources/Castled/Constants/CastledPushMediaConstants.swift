//
//  CastledPushMediaConstants.swift
//  Castled
//
//  Created by antony on 04/09/2024.
//

import Foundation
@_spi(CastledInternal)

public enum CastledPushMediaConstants {
    public static let messageFrames = "msg_frames"
    public static let thumbNailUrl = "thumbnail_url"
    public static let templateType = "template_type"
    public static let CastledClickedNotiContentIndx = "_kCastledClickedNotiContentIndx_"

    public enum MediaObject: String {
        case mediaType = "richMediaType"
        case mediaURL = "mediaUrl"
        case thumbUrl
    }

    public enum TemplateType: String {
        case defaultTemplate = "DEFAULT"
        case carousel = "CAROUSEL"
    }

    public enum MediaType: String, Codable {
        case image = "IMAGE"
        case video = "VIDEO"
        case audio = "AUDIO"
        case text_only = "NONE"
    }

    public static func getMediaArrayFrom(messageFrames: String) -> [Any]? {
        guard let data = messageFrames.data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)

            // Ensure that the jsonObject is an array, otherwise return nil
            if let array = jsonObject as? [Any] {
                return array
            } else {
                return nil
            }
        } catch {
            // Handle the error, e.g., log it or return nil
            print("Failed to convert text to array: \(error.localizedDescription)")
            return nil
        }
    }
}
