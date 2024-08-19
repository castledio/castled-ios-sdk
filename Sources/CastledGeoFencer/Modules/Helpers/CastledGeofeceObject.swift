//
//  CastledGeofeceObject.swift
//  CastledGeoFencer
//
//  Created by antony on 14/08/2024.
//

import Foundation

struct CastledGeofeceObject: Codable, Equatable {
    public static func == (lhs: CastledGeofeceObject, rhs: CastledGeofeceObject) -> Bool {
        return lhs.id == rhs.id
    }

    let lat: Double
    let long: Double
    let id: String
    let radius: Double

    enum CodingKeys: String, CodingKey {
        case lat
        case long
        case id
        case radius
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lat = (try? container.decodeIfPresent(Double.self, forKey: .lat)) ?? 0.0
        self.long = (try? container.decodeIfPresent(Double.self, forKey: .long)) ?? 0.0
        self.radius = (try? container.decodeIfPresent(Double.self, forKey: .radius)) ?? 0.0
        self.id = (try? container.decodeIfPresent(String.self, forKey: .id)) ?? ""
        // Call super initializer if needed
        // super.init()
    }

    // Implement the required method to encode properties
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
        try container.encode(id, forKey: .id)
        try container.encode(radius, forKey: .radius)
    }
}
