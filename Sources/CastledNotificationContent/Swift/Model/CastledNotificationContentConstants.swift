//
//  CastledNotificationContentConstants.swift
//  CastledNotificationContent
//
//  Created by antony on 21/08/2024.
//

enum CastledNotificationContentConstants {
    static let CastledClickedNotiContentIndx = "_kCastledClickedNotiContentIndx_"
    static let messageFrames = "msg_frames"
    static let templateType = "template_type"

    public enum TemplateType: String {
        case defaultTemplate = "DEFAULT"
        case carousel = "CAROUSEL"
    }
}
