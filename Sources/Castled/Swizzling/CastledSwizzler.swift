//
//  CastledSwizzler.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
// Reference https://medium.com/rocknnull/ios-to-swizzle-or-not-to-swizzle-f8b0ed4a1ce6

import Foundation
import UIKit

class CastledSwizzler {
    static func enableSwizzlingForNotifications() {
        // Checking if swizzling has been disabled in plist by the developer
        let swizzzlingDisabled = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledSwzzlingDisableKey) as? Bool ?? false
        if swizzzlingDisabled == true {
            return
        }

        let appDelegate = UIApplication.shared.delegate!
        self.swizzleImplementations(type(of: appDelegate), "application:didRegisterForRemoteNotificationsWithDeviceToken:")
        self.swizzleImplementations(type(of: appDelegate), "application:didFailToRegisterForRemoteNotificationsWithError:")
        self.swizzleImplementations(type(of: appDelegate), "userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:")
        self.swizzleImplementations(type(of: appDelegate), "userNotificationCenter:willPresentNotification:withCompletionHandler:")
        self.swizzleImplementations(type(of: appDelegate), "application:didReceiveRemoteNotification:fetchCompletionHandler:")
    }
    private class func swizzleImplementations(_ className: AnyObject.Type, _ methodSelector: String) {
        // Name of the method
        // We are not changing the method name
        let defaultSelector = Selector(methodSelector)

        let swizzledSelector = Selector("swizzled_" + methodSelector)
        if let swizzledMethod = class_getInstanceMethod(Castled.self, swizzledSelector) {
            guard let defaultMethod = class_getInstanceMethod(className, defaultSelector) else {
                class_addMethod(className, defaultSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

              //  CastledLog.castledLog("failed to swizzle \(methodSelector)", logLevel: CastledLogLevel.info)
                return
            }
            // Adding a method to the class at runtime and returns a boolean if the “add procedure” was successful
            let isMethodExists = class_addMethod(className, defaultSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

            if !isMethodExists {
                // Swap the implementation of our defaultMethod with the swizzledMethod
                method_exchangeImplementations(defaultMethod, swizzledMethod)
            } else {
                // Method already defined
                class_replaceMethod(Castled.self, swizzledSelector, method_getImplementation(defaultMethod), method_getTypeEncoding(defaultMethod))
            }
        }
    }
}
