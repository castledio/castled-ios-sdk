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
        appGroupId = "group.com.castled.CastledPushDemo.Castled"
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
