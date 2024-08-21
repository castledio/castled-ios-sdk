//
//  Bundle+Extensions.swift
//  Castled
//
//  Created by antony on 30/11/2023.
//

import Foundation
import UIKit

public extension Bundle {
    static func resourceBundle(for bundleClass: AnyClass) -> Bundle {
        let mainBundle = Bundle.main
        let sourceBundle = Bundle(for: bundleClass)
        guard let moduleName = String(reflecting: bundleClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(bundleClass)")
        }
        var bundle: Bundle?
        // CocoaPods (framework)
        if bundle == nil, let frameworkBundlePath = sourceBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: frameworkBundlePath)
        }
        // CocoaPods (static)
        else if bundle == nil, let staticBundlePath = mainBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: staticBundlePath)
        }
        // SPM
        else if bundle == nil, let bundlePath = mainBundle.path(forResource: "\(moduleName)_\(moduleName)", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        // SPM for other modules : Inbox
        else if bundle == nil, let bundlePath = mainBundle.path(forResource: "Castled_\(moduleName)", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        return bundle ?? sourceBundle
    }

    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last
        {
            return UIImage(named: icon)
        }

        return nil
    }

    var iconFileName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return iconFileName
    }
}
