//
//  Bundle+Extensions.swift
//  Castled
//
//  Created by antony on 30/11/2023.
//

import Foundation
import UIKit
@_spi(CastledInternal)

public extension Bundle {
    static func resourceBundle(for bundleClass: AnyClass) -> Bundle {
        let mainBundle = Bundle.main
        let sourceBundle = Bundle(for: bundleClass)
        guard let moduleName = String(reflecting: bundleClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(bundleClass)")
        }
        // SPM
        var bundle: Bundle?
        if bundle == nil, let bundlePath = sourceBundle.path(forResource: "Castled", ofType: "bundle") {
            // cocoapod
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = mainBundle.path(forResource: "\(moduleName)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = mainBundle.path(forResource: "Castled_CastledNotificationContent", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = mainBundle.path(forResource: "Castled_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if let bundlePath = mainBundle.path(forResource: "\(bundleClass)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = mainBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = sourceBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        } else if bundle == nil, let bundlePath = mainBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        // CocoaPods (static)
        else if bundle == nil, let staticBundlePath = mainBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: staticBundlePath)
        }

        // CocoaPods (framework)
        else if bundle == nil, let frameworkBundlePath = sourceBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: frameworkBundlePath)
        }
        return bundle ?? sourceBundle
    }
}
