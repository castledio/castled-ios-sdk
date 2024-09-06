//
//  NotificationViewController.swift
//  CNotificationContentDemo
//
//  Created by antony on 07/06/2023.
//

import CastledNotificationContent
import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: CastledNotificationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        appGroupId = "group.com.castled.CastledPushDemo.Castled"
    }

    override func didReceive(_ notification: UNNotification) {
        if isCastledPushNotification(notification) {
            super.didReceive(notification)
        }
    }
}
