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
        //  appGroupId = "<your_app_group_id>"
        appGroupId = "group.com.castled.CastledPushDemo.Castled"
        super.didReceive(request, withContentHandler: contentHandler)
        if isCastledPushNotificationRequest(request) {
            print("Castled notfiication received \(#function)")
        } else {
            // push from other sdks, call the respective methods
        }
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
