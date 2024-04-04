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
    static let swizzzlingDisabled = Bundle.main.object(forInfoDictionaryKey: CastledConstants.kCastledSwzzlingDisableKey) as? Bool ?? false

    class func swizzleImplementations(originalSelector: Selector, originalClass: AnyObject.Type, swizzledSelector: Selector, swizzlinglClass: AnyObject.Type) {
        if let swizzledMethod = class_getInstanceMethod(swizzlinglClass, swizzledSelector) {
            let updatedImplementaiton = method_getImplementation(swizzledMethod)
            let methodTypeEncoding = method_getTypeEncoding(swizzledMethod)
            let isOriginalMethodExists = class_getInstanceMethod(originalClass, originalSelector) != nil
            if isOriginalMethodExists {
                if let defaultMethod = class_getInstanceMethod(originalClass, originalSelector) {
                    let defaultImplementation = method_getImplementation(defaultMethod)
                    if updatedImplementaiton == defaultImplementation {
                        return
                    }
                    class_addMethod(originalClass, swizzledSelector, updatedImplementaiton, methodTypeEncoding)
                    if let swizzledMethod = class_getInstanceMethod(originalClass, swizzledSelector) {
                        method_exchangeImplementations(defaultMethod, swizzledMethod)
                    }
                }

            } else {
                class_addMethod(originalClass, originalSelector, updatedImplementaiton, methodTypeEncoding)
            }
        }
    }
}
