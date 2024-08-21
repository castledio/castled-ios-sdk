//
//  CastledNotificationContentProtocol.swift
//  CastledNotificationContent
//
//  Created by antony on 21/08/2024.
//

import UserNotifications

protocol CastledNotificationContentProtocol {
    var userDefaults: UserDefaults? { get set }
    func getContentSizeHeight() -> CGFloat
    func populateDetailsFrom(notificaiton: UNNotification)
}
