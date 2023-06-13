//
//  NotificationService.swift
//  CNotificationServiceDemo
//
//  Created by antony on 07/06/2023.
//

import UserNotifications
import CastledNotificationService

class NotificationService: CastledNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        print("coming here 1")
        super.didReceive(request, withContentHandler: contentHandler)
    }
    
}
