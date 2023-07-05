//
//  NotificationViewController.swift
//  CNotificationContentDemo
//
//  Created by antony on 07/06/2023.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import CastledNotificationContent

class NotificationViewController: CastledNotificationViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appGroupId = "group.com.castled.CastledPushDemo.Castled"
    }
    
    override func didReceive(_ notification: UNNotification) {
        super.didReceive(notification)
    }
    
}


