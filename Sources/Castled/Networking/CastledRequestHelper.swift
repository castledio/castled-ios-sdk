//
//  CastledRequestHelper.swift
//  Castled
//
//  Created by antony on 20/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledRequestHelper: NSObject {
    public var requestHandlerRegistry: [String: CastledNetworkRequestHandler.Type] = [:]

    @objc public static var sharedInstance = CastledRequestHelper()

    override private init() {}
}
