//
//  CastledNotificationServiceExtension.swift
//  CastledNotificationService
//
//  Created by antony on 05/09/2024.
//

import Foundation
import UserNotifications
@_spi(CastledInternal) import Castled

@objcMembers
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

    //   @objc static var extensionInstance = CastledNotificationServiceExtension()
    lazy var sharedUserDefaults: UserDefaults? = nil

    //  override private init() {}

    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        handleNotification(request: request, contentHandler: contentHandler)
    }

    func handleNotification(request: UNNotificationRequest, contentHandler: @escaping (UNNotificationContent) -> Void) {
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
                if let handler = self?.contentHandler {
                    CastledNotificationServiceLogManager.logMessage("contentHandler is there \(self)", logLevel: .info)
                } else {
                    CastledNotificationServiceLogManager.logMessage("contentHandler should have called before \(self)", logLevel: .warning)
                }
                self?.setApplicationBadge()
                CastledNotificationServiceLogManager.logMessage("After setting the badge....", logLevel: .debug)
                contentHandler(self?.bestAttemptContent ?? request.content)
                CastledNotificationServiceLogManager.logMessage("About to display the rich notification", logLevel: .debug)
            }

            if let convertedAttachments = getMediasArrayFromCastledObject(customCasledDict) {
                getNotificationAttachments(medias: convertedAttachments) { attachments in
                    bestAttemptContent.attachments = attachments
                    CastledNotificationServiceLogManager.logMessage("Inside getNotificationAttachments completion \(self) \(attachments.count)", logLevel: .debug)

                    completeNotificationHandling()
                }

            } else {
                CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.likelyTextMessage, logLevel: .debug)
                completeNotificationHandling()
            }

        } else {
            CastledNotificationServiceLogManager.logMessage(CastledNotificationServiceConstants.notFromCaslted, logLevel: .debug)
        }
    }

    override open func serviceExtensionTimeWillExpire() {
        CastledNotificationServiceLogManager.logMessage("about to expire \(#function)", logLevel: .debug)
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
