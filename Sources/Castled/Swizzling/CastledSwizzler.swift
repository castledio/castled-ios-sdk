//
//  CastledSwizzler.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//
//

import Foundation
import UIKit

class CastledSwizzler {
    static let swizzzlingDisabled = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledSwzzlingDisableKey) as? Bool ?? false

    class func swizzleImplementations(originalSelector: Selector, originalClass: AnyObject.Type, swizzledSelector: Selector, swizzlingClass: AnyObject.Type) {
        guard let swizzledMethod = class_getInstanceMethod(swizzlingClass, swizzledSelector) else {
            return
        }
        let swizzledImplementation = method_getImplementation(swizzledMethod)
        let methodTypeEncoding = method_getTypeEncoding(swizzledMethod)
        if let originalMethod = class_getInstanceMethod(originalClass, originalSelector) {
            let originalImplementation = method_getImplementation(originalMethod)
            // If the swizzled method implementation is the same as the original, do nothing
            if swizzledImplementation != originalImplementation {
                class_addMethod(originalClass, swizzledSelector, swizzledImplementation, methodTypeEncoding)
                if let swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector) {
                    method_exchangeImplementations(originalMethod, swizzledMethod)
                }
            }

        } else {
            class_addMethod(originalClass, originalSelector, swizzledImplementation, methodTypeEncoding)
        }
    }
}
