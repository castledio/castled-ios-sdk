//
//  CastledLifeCycleListener.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
@_spi(CastledInternal)

public protocol CastledLifeCycleListener: AnyObject {
    func appBecomeActive()
}
