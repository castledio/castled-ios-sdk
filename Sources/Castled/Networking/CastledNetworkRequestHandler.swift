//
//  CastledNetworkRequestHandler.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal)

public protocol CastledNetworkRequestHandler {
    static func sendRequest(_ requests: [CastledNetworkRequest]) async
}
