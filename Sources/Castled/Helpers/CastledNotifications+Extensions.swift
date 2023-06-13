//
//  CastledNotifications+Extensions.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UserNotifications
import UIKit

extension Castled{
    
}

/**
 extension UIViewController {
     
     @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              willPresent notification: UNNotification,
                                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         
         print("willPresent swizzled")
         Castled.sharedInstance!.handleNotificationInForeground(notification: notification)
         self.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
     }
     
     
     // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
     
     @objc public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                              didReceive response: UNNotificationResponse,
                                              withCompletionHandler completionHandler: @escaping () -> Void) {
         print("didReceive swizzled")
         Castled.sharedInstance!.handleNotificationAction(response: response)
         self.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
     }
 }
 */




