//
//  CastledNetworkRequestHandler.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal)

public protocol CastledNetworkRequestHandler: Codable {
    static func handleRequest(
        requests: [CastledNetworkRequest],
        onSuccess: @escaping ([CastledNetworkRequest]) -> Void,
        onError: @escaping ([CastledNetworkRequest]) -> Void
    )
}
