//
//  CastledGeofencerUtils.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

class CastledGeofencerUtils: NSObject {
    static func castledLog(_ item: Any, logLevel: CastledLogLevel, separator: String = " ", terminator: String = "\n") {
        CastledLog.castledLog(item, logLevel: logLevel)
    }
}
