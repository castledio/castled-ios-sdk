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
        if let uiApplicationClass = NSClassFromString("UIApplication") as? NSObject.Type {
            let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
            if uiApplicationClass.responds(to: sharedApplicationSelector),
               let sharedApplication = uiApplicationClass.perform(sharedApplicationSelector)?.takeUnretainedValue()
            {
                return sharedApplication
            }
        }
        return nil
    }
}
