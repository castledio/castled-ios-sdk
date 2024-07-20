//
//  CastledApplication+Extension.swift
//  Castled
//
//  Created by antony on 19/07/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal)

public extension UIApplication {
    static func getSharedApplication() -> Any? {
        #if os(iOS) || os(tvOS)
            if !CastledEnvironmentChecker.isAppExtension() {
                if let uiApplicationClass = NSClassFromString("UIApplication") as? NSObject.Type,
                   uiApplicationClass.responds(to: NSSelectorFromString("sharedApplication"))
                {
                    let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
                    if let sharedApplication = uiApplicationClass.perform(sharedApplicationSelector)?.takeUnretainedValue() {
                        return sharedApplication
                    }
                }
            }
        #elseif os(watchOS)
            return ProcessInfo.processInfo
        #endif
        return nil
    }
}
