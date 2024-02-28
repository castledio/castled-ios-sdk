//
//  NotificationService.swift
//  CNotificationServiceDemo
//
//  Created by antony on 07/06/2023.
//

import CastledNotificationService
import UserNotifications

class NotificationService: CastledNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        appGroupId = "<your_app_group_id>"
        // calling super to make sure Castled implementation is called.
        super.didReceive(request, withContentHandler: contentHandler)
    }

    override func serviceExtensionTimeWillExpire() {
        // This method is called right before the extension is terminated by the system.
        // Take this opportunity to provide your "best attempt" at modified content.
        // If you don't make any changes, the original push payload will be used by default.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
