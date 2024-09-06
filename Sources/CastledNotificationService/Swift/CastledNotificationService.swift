//
//  CastledNotificationServiceExtension.swift
//  CastledNotificationService
//
//  Created by antony on 05/09/2024.
//

import Foundation
import UserNotifications
@_spi(CastledInternal) import Castled

open class CastledNotificationServiceExtension: UNNotificationServiceExtension {
    @objc public lazy var appGroupId = "" {
        didSet {
            if !appGroupId.isEmpty, CastledUserDefaults.isAppGroupIsEnabledFor(appGroupId) {
                CastledShared.sharedInstance.appGroupId = appGroupId
                sharedUserDefaults = UserDefaults(suiteName: appGroupId)
            }
        }
    }

    @objc public lazy var contentHandler: ((UNNotificationContent) -> Void)? = nil
    @objc public lazy var bestAttemptContent: UNMutableNotificationContent? = nil

    @objc static var extensionInstance = CastledNotificationServiceExtension()
    lazy var sharedUserDefaults: UserDefaults? = nil

    override private init() {}

    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        configureNotificationContent(request: request, contentHandler: contentHandler)
    }

    @objc private func configureNotificationContent(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) {
        CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.pushReceived, logLevel: .debug)

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.ignoringPushAsBestAttemptNil, logLevel: .debug)
            return
        }

        if let customCasledDict = getCastledPushObject(request.content.userInfo),
           customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String
        {
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.pushFromCastled, logLevel: .debug)
            CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: request.content.userInfo)

            let completeNotificationHandling: () -> Void = { [weak self] in
                self?.setApplicationBadge()
                contentHandler(self?.bestAttemptContent ?? request.content)
            }

            if let convertedAttachments = getMediasArrayFromCastledObject(customCasledDict) {
                getNotificationAttachments(medias: convertedAttachments) { attachments in
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

    @objc public func isCastledPushNotificationRequest(_ request: UNNotificationRequest) -> Bool {
        if let customCasledDict = getCastledPushObject(request.content.userInfo),
           customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String
        {
            return true
        }
        return false
    }
}
