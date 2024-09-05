//
//  CastledNotificationContentConstants.swift
//  CastledNotificationContent
//
//  Created by antony on 21/08/2024.
//
import Foundation

enum CastledNotificationContentConstants {
    static let contentTemplatesStoryBoard = "CNotificationContent"
    static let contentTemplatesDefaultVC = "CastledDefaultViewController"

    static let likelyTextOrUnsupported = "Received push is likely just a text message or uses an unsupported template, default view is being created."
    static let notFromCaslted = "Received push is not from Castled."
    static let pushFromCastled = "Received push is from Castled."
    static let pushReceived = "Push notification received inside Notification Content Extension."
}
