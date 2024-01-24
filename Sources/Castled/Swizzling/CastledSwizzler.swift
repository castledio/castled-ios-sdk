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
    static var isSwizzled = false
    static func enableSwizzlingForNotifications() {
        // Checking if swizzling has been disabled in plist by the developer
        let swizzzlingDisabled = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledSwzzlingDisableKey) as? Bool ?? false
        if swizzzlingDisabled || CastledSwizzler.isSwizzled {
            return
        }
        CastledSwizzler.isSwizzled = true
        let appDelegate = UIApplication.shared.delegate!
        self.swizzleImplementations(type(of: appDelegate), "application:didRegisterForRemoteNotificationsWithDeviceToken:")
        self.swizzleImplementations(type(of: appDelegate), "application:didFailToRegisterForRemoteNotificationsWithError:")
        self.swizzleImplementations(type(of: appDelegate), "userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:")
        self.swizzleImplementations(type(of: appDelegate), "userNotificationCenter:willPresentNotification:withCompletionHandler:")
        self.swizzleImplementations(type(of: appDelegate), "application:didReceiveRemoteNotification:fetchCompletionHandler:")
//        self.swizzleImplementations(type(of: appDelegate), "application:openURL:options:")
    }

    private class func swizzleImplementations(_ className: AnyObject.Type, _ methodSelector: String) {
        let defaultSelector = Selector(methodSelector)
        let swizzledSelector = Selector("swizzled_" + methodSelector)
        if let swizzledMethod = class_getInstanceMethod(Castled.self, swizzledSelector) {
            let updatedImplementaiton = method_getImplementation(swizzledMethod)
            let methodTypeEncoding = method_getTypeEncoding(swizzledMethod)
            let isOriginalMethodExists = class_getInstanceMethod(className, defaultSelector) != nil
            if isOriginalMethodExists {
                if let defaultMethod = class_getInstanceMethod(className, defaultSelector) {
                    let defaultImplementation = method_getImplementation(defaultMethod)
                    if updatedImplementaiton == defaultImplementation {
                        return
                    }
                    class_addMethod(className, swizzledSelector, updatedImplementaiton, methodTypeEncoding)
                    if let swizzledMethod = class_getInstanceMethod(className, swizzledSelector) {
                        method_exchangeImplementations(defaultMethod, swizzledMethod)
                    }
                }

            } else {
                class_addMethod(className, defaultSelector, updatedImplementaiton, methodTypeEncoding)
            }
        }
    }
}
