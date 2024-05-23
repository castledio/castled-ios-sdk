//
//  CastledAppCycleListener.swift
//  Castled
//
//  Created by antony on 24/05/2024.
//

import Foundation
@_spi(CastledInternal)

@objc public protocol CastledModuleListener {
    func castledInitialized()
}
