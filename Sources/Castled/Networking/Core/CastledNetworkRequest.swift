//
//  CastledNetworkRequest.swift
//  Castled
//
//  Created by antony on 17/05/2024.
//

import Foundation
@_spi(CastledInternal)

public struct CastledNetworkRequest: Codable, Equatable, Hashable {
    public let type: String
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    let requestId: String

    public init(type: String, method: HTTPMethod, parameters: [String: Any]?) {
        self.type = type
        self.method = method
        self.parameters = parameters
        self.requestId = UUID().uuidString
    }

    public static func == (lhs: CastledNetworkRequest, rhs: CastledNetworkRequest) -> Bool {
        return lhs.requestId == rhs.requestId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(requestId)
    }

    public enum CodingKeys: String, CodingKey {
        case type, path, method, parameters, requestId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(method, forKey: .method)
        try container.encode(requestId, forKey: .requestId)
        try container.encodeIfPresent(parameters, forKey: .parameters)

        // Encode other fields if needed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.requestId = try container.decode(String.self, forKey: .requestId)
        self.method = try container.decode(HTTPMethod.self, forKey: .method)
        self.parameters = try container.decode([String: Any].self, forKey: .parameters)
    }

//    public init(from decoder: Decoder) throws {}
}

@_spi(CastledInternal)
public enum HTTPMethod: String, Codable {
    case post
    case put
    case get
    enum CodingKeys: String, CodingKey {
        case post, put, get
    }
}
