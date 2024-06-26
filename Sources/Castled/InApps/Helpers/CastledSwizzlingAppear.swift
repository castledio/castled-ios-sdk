//
//  CastledSwizzling.swift
//  SwizzleViewVill
//
//  Created by antony on 07/04/2023.
//

import Foundation
import UIKit

extension UIViewController {
    @objc func _tracked_viewwDidAppear(_ animated: Bool) {
        defer {
            if responds(to: #selector(_tracked_viewwDidAppear(_:))) {
                _tracked_viewwDidAppear(animated)
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
        let swizzledSelector = #selector(UIViewController._tracked_viewwDidAppear)
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        let didAddViewDidAppearMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        if didAddViewDidAppearMethod {
            class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        //   method_exchangeImplementations (originalMethod!, swizzledMethod!)
    }
}
