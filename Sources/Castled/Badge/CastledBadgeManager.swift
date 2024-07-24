//
//  CastledBadgeManager.swift
//  Castled
//
//  Created by antony on 31/01/2024.
//

import Foundation
import UIKit
import UserNotifications

class CastledBadgeManager {
    static let shared = CastledBadgeManager()

    private init() {}

    func updateApplicationBadgeAfterNotification(_ notification: [AnyHashable: Any]) {
        Castled.sharedInstance.castledCommonQueue.async {
            guard (notification[CastledConstants.PushNotification.castledKey] as? NSDictionary) != nil,
                  let aps = notification[CastledConstants.PushNotification.apsKey] as? NSDictionary, let badge = aps[CastledConstants.PushNotification.badgeKey] as? Int, badge >= 0
            else {
                return
            }
            if badge == 0 {
                self.setApplicationBadge(0)
            } else {
                self.modifyBadgeCount(by: badge)
            }
        }
    }

    func clearApplicationBadge() {
        Castled.sharedInstance.castledCommonQueue.async {
            self.setApplicationBadge(0)
        }
    }

    private func modifyBadgeCount(by delta: Int = 1) {
        Castled.sharedInstance.castledCommonQueue.async {
            var currentBadge = CastledUserDefaults.getValueFor(CastledUserDefaults.kCastledBadgeKey) as? Int ?? 0
            currentBadge += delta
            self.setApplicationBadge(currentBadge)
        }
    }

    private func setApplicationBadge(_ badge: Int) {
        let lastIncrementTimestamp = CastledUserDefaults.getUserDefaults().double(forKey: CastledUserDefaults.kCastledLastBadgeIncrementTimeKey)
        let currentTimestamp = Date().timeIntervalSince1970
        if currentTimestamp - lastIncrementTimestamp > 2 || badge == 0 {
            /* This check is for avoiding the badge increment more than 1, as we are incrementing the count in
             // Check if it's been more than a certain interval (e.g., 2 sec) since the last increment

             1. background
             2. will present
             3. notification extension */
            CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledBadgeKey, badge)
            CastledUserDefaults.setValueFor(CastledUserDefaults.kCastledLastBadgeIncrementTimeKey, currentTimestamp)

            DispatchQueue.main.async {
                if #available(iOS 16.0, *) {
                    UNUserNotificationCenter.current().setBadgeCount(badge) { _ in
                    }
                } else {
                    if let application = UIApplication.getSharedApplication() as? UIApplication {
                        application.applicationIconBadgeNumber = badge
                    }
                }
            }
        }
    }
}
