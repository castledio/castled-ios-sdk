//
//  CastledNotificationServiceExtension.swift
//  CastledNotificationService
//
//  Created by Abhilash Thulaseedharan on 06/05/23.
//

import Foundation
import UserNotifications
@_spi(CastledInternal) import Castled

open class CastledNotificationServiceExtension: UNNotificationServiceExtension {
    var sharedUserDefaults: UserDefaults?

    @objc public var appGroupId = "" {
        didSet {
            if !appGroupId.isEmpty, CastledUserDefaults.isAppGroupIsEnabledFor(appGroupId) {
                CastledShared.sharedInstance.appGroupId = appGroupId
                sharedUserDefaults = UserDefaults(suiteName: appGroupId)
            }
        }
    }

    @objc public var contentHandler: ((UNNotificationContent) -> Void)?
    @objc public var bestAttemptContent: UNMutableNotificationContent?

    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.pushReceived, logLevel: .debug)
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.ignoringPushAsBestAttemptNil, logLevel: .debug)
            return
        }

        if let customCasledDict = CastledShared.sharedInstance.getCastledDictionary(userInfo: request.content.userInfo),
           customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String
        {
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.pushFromCastled, logLevel: .debug)

            CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: request.content.userInfo)

            let completeNotificationHandling: () -> Void = { [weak self] in
                self?.setApplicationBadge()
                contentHandler(self?.bestAttemptContent ?? request.content)
            }

            if let msgFramesString = customCasledDict[CastledPushMediaConstants.messageFrames] as? String,
               let convertedAttachments = CastledPushMediaConstants.getMediaArrayFrom(messageFrames: msgFramesString) as? [[String: Any]],
               !convertedAttachments.isEmpty,
               let media = convertedAttachments.first,
               let mediaType = media[CastledPushMediaConstants.MediaObject.mediaType.rawValue] as? String,
               mediaType != CastledPushMediaConstants.MediaType.text_only.rawValue

            {
                getAttachments(medias: convertedAttachments) { attachments in
                    bestAttemptContent.attachments = attachments
                    completeNotificationHandling()
                }

            } else {
                CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.likelyTextMessage, logLevel: .info)
                completeNotificationHandling()
            }

        } else {
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.notFromCaslted, logLevel: .debug)
        }
    }

    override open func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
