//
//  CastledNotificationServiceManager.swift
//  CastledNotificationService
//
//  Created by antony on 05/09/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

enum CastledNotificationServiceLogManager {
    static let notFromCaslted = "Received push is from Castled."
    static let likelyTextMessage = "Received push is likely just a text message."
    static let pushFromCastled = "Received push is from Castled."
    static let ignoringPushAsBestAttemptNil = "Ignoring push notification reporting as bestAttemptContent is nil."
    static let pushReceived = "Push notification received inside Notification Service Extension."
    static let notDisplayingMediaAttacmentNil = "Media not displaying, as the attachment URL is either nil or invalid, likely just a text message."
    static func logMessage(_ message: String, logLevel: CastledLogLevel) {
        CastledLog.castledLog(message, logLevel: logLevel)
    }
}
