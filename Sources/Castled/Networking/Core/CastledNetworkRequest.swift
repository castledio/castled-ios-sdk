//
//  CastledNetworkRequest.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal)

public struct CastledNetworkRequest {
    public let type: String
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    public init(type: String, path: String, method: HTTPMethod, parameters: [String: Any]?) {
        self.type = type
        self.path = path
        self.method = method
        self.parameters = parameters
    }
}

@_spi(CastledInternal)
public enum HTTPMethod: String {
    case post
    case put
    case get
}
