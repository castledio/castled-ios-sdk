//
//  CastledSwizzling.swift
//  SwizzleViewVill
//
//  Created by antony on 07/04/2023.
//

import Foundation
import UIKit

extension UIViewController {
    @objc func castled_viewwDidAppear(_ animated: Bool) {
        defer {
            if responds(to: #selector(castled_viewwDidAppear(_:))) {
                castled_viewwDidAppear(animated)
            }
        }
        let screenName = String(describing: type(of: self))
        if !(screenName.hasPrefix("CastledInApp")), !CastledInApp.sharedInstance.userId.isEmpty {
            Castled.sharedInstance.logPageViewedEvent(screenName)
        }
    }

    static func swizzleViewDidAppear() {
        if CastledSwizzler.swizzzlingDisabled {
            return
        }
        let originalSelector = #selector(UIViewController.viewDidAppear)
        let swizzledSelector = #selector(UIViewController.castled_viewwDidAppear)
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        CastledSwizzler.swizzleImplementations(originalSelector: originalSelector, originalClass: UIViewController.self, swizzledSelector: swizzledSelector, swizzlingClass: UIViewController.self)
    }
}
