//
//  CastledVisitedPlacesDetails.swift
//  CastledGeoFencer
//
//  Created by antony on 14/08/2024.
//

import Foundation

struct CastledVisitedPlacesDetails: Codable {
    var timeStamp: Double
    var type: String
    enum CodingKeys: String, CodingKey {
        case timeStamp
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timeStamp = (try? container.decodeIfPresent(Double.self, forKey: .timeStamp)) ?? 0.0
        self.type = (try? container.decodeIfPresent(String.self, forKey: .type)) ?? ""
        // Call super initializer if needed
        // super.init()
    }

    init() {
        self.timeStamp = 0
        self.type = ""
    }
}
