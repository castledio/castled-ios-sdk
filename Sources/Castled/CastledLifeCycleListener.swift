//
//  CastledLifeCycleListener.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
@_spi(CastledInternal)

@objc public protocol CastledLifeCycleListener: AnyObject {
    @objc func appDidBecomeActive()
    @objc optional func appWillResignActive()
    @objc optional func appDidEnterBackground()
    @objc optional func appWillEnterForeground()
}
