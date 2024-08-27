//
//  CastledNotificationDelegates.swift
//  Castled
//
//  Created by antony on 01/04/2024.
//

import Foundation
import UIKit

@objc class CastledNotificationDelegates: NSObject {
    @objc public static let shared = CastledNotificationDelegates()

    override private init() {}
}

extension CastledNotificationDelegates {
    // MARK: - Notification Delegates Swizzled methods

    @objc func swizzled_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Castled.sharedInstance.setDeviceToken(deviceToken: deviceToken)
        if responds(to: #selector(swizzled_application(_:didRegisterForRemoteNotificationsWithDeviceToken:))) {
            self.swizzled_application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    @objc func swizzled_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        CastledLog.castledLog("Failed to register: \(error)", logLevel: CastledLogLevel.error)
        if responds(to: #selector(swizzled_application(_:didFailToRegisterForRemoteNotificationsWithError:))) {
            swizzled_application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        }
    }

    @objc func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                               willPresentNotification notification: UNNotification,
                                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let isCastledSilent = Castled.sharedInstance.isCastledSilentPush(fromInfo: notification.request.content.userInfo)
        Castled.sharedInstance.castledUserNotificationCenter(center, willPresent: notification, isCastledSilentPush: isCastledSilent)
        if !isCastledSilent {
            if responds(to: #selector(swizzled_userNotificationCenter(_:willPresentNotification:withCompletionHandler:))) {
                swizzled_userNotificationCenter(center, willPresentNotification: notification) { options in
                    completionHandler(options)
                }
            } else {
                if #available(iOS 14.0, *) {
                    // For iOS 14 and later
                    completionHandler([.banner, .list, .badge, .sound])
                } else {
                    // For iOS 13 and earlier
                    completionHandler([.alert, .badge, .sound])
                }
            }
        } else {
            completionHandler([])
        }
    }

    @objc func swizzled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let isCastledSilent = Castled.sharedInstance.isCastledSilentPush(fromInfo: userInfo)
        Castled.sharedInstance.didReceiveRemoteNotification(inApplication: application, withInfo: userInfo, isCastledSilentPush: isCastledSilent, fetchCompletionHandler: { [self] response in
            if !isCastledSilent {
                if self.responds(to: #selector(swizzled_application(_:didReceiveRemoteNotification:fetchCompletionHandler:))) {
                    self.swizzled_application(application, didReceiveRemoteNotification: userInfo) { result in
                        completionHandler(result)
                    }
                } else {
                    completionHandler(response)
                }
            } else {
                completionHandler(response)
            }

        })
    }

    @objc func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                               didReceiveNotificationResponse response: UNNotificationResponse,
                                               withCompletionHandler completionHandler: @escaping () -> Void)
    {
        Castled.sharedInstance.handleNotificationAction(response: response)
        if responds(to: #selector(swizzled_userNotificationCenter(_:didReceiveNotificationResponse:withCompletionHandler:))) {
            swizzled_userNotificationCenter(center, didReceiveNotificationResponse: response) {
                completionHandler()
            }
        } else {
            completionHandler()
        }
    }

    @objc func swizzled_application(_ application: UIApplication, openURL url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if responds(to: #selector(swizzled_application(_:openURL:options:))) {
            return swizzled_application(application, openURL: url, options: options)
        }
        return true
    }
}
