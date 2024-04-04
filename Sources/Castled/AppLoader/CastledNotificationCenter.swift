//
//  CastledNotificationCenter.swift
//  Castled
//
//  Created by antony on 28/03/2024.
//

import Foundation
import UIKit
import UserNotifications

class CastledNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    @objc public static let shared = CastledNotificationCenter()
    private static var swizzledClasses = NSMutableSet()

    override private init() {}

    func setNotiificationDelegates() {
        CastledSwizzler.swizzleImplementations(originalSelector: #selector(setter: UNUserNotificationCenter.delegate), originalClass: UNUserNotificationCenter.self, swizzledSelector: #selector(CastledNotificationCenter.setCastledNotificationDelegate), swizzlinglClass: type(of: CastledNotificationCenter.shared))
        if let delegate = UNUserNotificationCenter.current().delegate {
            UNUserNotificationCenter.current().delegate = delegate
            // swizzled method will get called after adding this
        } else {
            UNUserNotificationCenter.current().delegate = CastledNotificationCenter.shared
        }
    }

    private func swizzleNotificationDelegates(delegateObject: AnyObject) {
        CastledNotificationCenter.shared.swizzleImplementations(type(of: delegateObject), "userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:")
        CastledNotificationCenter.shared.swizzleImplementations(type(of: delegateObject), "userNotificationCenter:willPresentNotification:withCompletionHandler:")
        CastledNotificationCenter.shared.swizzleImplementations(type(of: delegateObject), "application:didReceiveRemoteNotification:fetchCompletionHandler:")
    }

    private func swizzleImplementations(_ className: AnyObject.Type, _ methodSelector: String) {
        let defaultSelector = Selector(methodSelector)
        let swizzledSelector = Selector(CastledConstants.kCastledSwizzledMethodPrefix + methodSelector)
        CastledSwizzler.swizzleImplementations(originalSelector: defaultSelector, originalClass: className, swizzledSelector: swizzledSelector, swizzlinglClass: CastledNotificationDelegates.self)
    }
}

extension CastledNotificationCenter {
    @objc func setCastledNotificationDelegate(_ delegate: Any?) {
        defer {
            if responds(to: #selector(setCastledNotificationDelegate(_:))) {
                setCastledNotificationDelegate(delegate)
            }
        }

        guard let delegateObject = delegate as? AnyObject, !CastledNotificationCenter.swizzledClasses.contains(delegateObject) else {
            return
        }
        CastledNotificationCenter.swizzledClasses.add(delegateObject)
        CastledNotificationCenter.shared.swizzleNotificationDelegates(delegateObject: delegateObject)
    }
}
