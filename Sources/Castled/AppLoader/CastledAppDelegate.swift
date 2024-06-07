//
//  CastledAppDelegate.swift
//  Castled
//
//  Created by antony on 01/04/2024.
//

import Foundation
import UIKit
import UserNotifications
@_spi(CastledInternalInterface)

@objc public class CastledAppDelegate: NSObject, UNUserNotificationCenterDelegate {
    @objc public static let shared = CastledAppDelegate()
    private static var swizzledClasses = NSMutableSet()
    var isLoaded = false

    override private init() {}

    @objc public func setApplicationDelegates(sourceClass: AnyClass? = nil) {
        guard let fromClass = sourceClass, String(describing: fromClass) == "CastledApplicationLoader", !CastledSwizzler.swizzzlingDisabled,!isLoaded else {
            // If it's not the expected class, return without further execution
            return
        }
        isLoaded = true
        CastledSwizzler.swizzleImplementations(originalSelector: #selector(setter: UIApplication.delegate), originalClass: UIApplication.self, swizzledSelector: #selector(CastledAppDelegate.setCastledApplicationDelegate), swizzlinglClass: type(of: CastledAppDelegate.shared))
        CastledNotificationCenter.shared.setNotiificationDelegates()
    }

    private func swizzleNotificationDelegates(delegateObject: AnyObject) {
        CastledAppDelegate.shared.swizzleImplementations(type(of: delegateObject), "application:didRegisterForRemoteNotificationsWithDeviceToken:")
        CastledAppDelegate.shared.swizzleImplementations(type(of: delegateObject), "application:didFailToRegisterForRemoteNotificationsWithError:")
        CastledAppDelegate.shared.swizzleImplementations(type(of: delegateObject), "application:didReceiveRemoteNotification:fetchCompletionHandler:")
    }

    private func swizzleImplementations(_ className: AnyObject.Type, _ methodSelector: String) {
        let defaultSelector = Selector(methodSelector)
        let swizzledSelector = Selector(CastledConstants.kCastledSwizzledMethodPrefix + methodSelector)
        CastledSwizzler.swizzleImplementations(originalSelector: defaultSelector, originalClass: className, swizzledSelector: swizzledSelector, swizzlinglClass: CastledNotificationDelegates.self)
    }
}

extension CastledAppDelegate {
    @objc func setCastledApplicationDelegate(_ delegate: Any?) {
        defer {
            if responds(to: #selector(setCastledApplicationDelegate(_:))) {
                setCastledApplicationDelegate(delegate)
            }
        }

        guard let delegateObject = delegate as? AnyObject, !CastledAppDelegate.swizzledClasses.contains(delegateObject) else {
            return
        }
        CastledAppDelegate.swizzledClasses.add(delegateObject)
        CastledAppDelegate.shared.swizzleNotificationDelegates(delegateObject: delegateObject)
    }
}
