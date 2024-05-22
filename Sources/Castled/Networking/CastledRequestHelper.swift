//
//  CastledRequestHelper.swift
//  Castled
//
//  Created by antony on 20/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledRequestHelper: NSObject {
    private var requestHandlerRegistry: [String: CastledNetworkRequestHandler.Type] = [:]

    @objc public static var sharedInstance = CastledRequestHelper()

    override private init() {}

    public func registerHandlerWith(key: String, handler: CastledNetworkRequestHandler.Type) {
        requestHandlerRegistry[key] = handler
        print("requestHandlerRegistry \(requestHandlerRegistry)")
    }

    func getHandlerFor(_ key: String) -> CastledNetworkRequestHandler.Type? {
        requestHandlerRegistry[key]
    }
}
