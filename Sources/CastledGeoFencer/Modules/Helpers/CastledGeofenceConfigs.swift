//
//  CastledGeofenceConfigs.swift
//  CastledGeoFencer
//
//  Created by antony on 14/08/2024.
//

import Foundation

@objc public class CastledGeofenceConfigs: NSObject, Codable {
    @objc public var locationFilterDistance: Double = 1000 {
        didSet {
            // Ensure the value is at least 100 M
            if locationFilterDistance < 100 {
                locationFilterDistance = 100
                CastledGeofencerUtils.castledLog("Location filter distance must be at least \(locationFilterDistance)Mtrs.Resetting to \(locationFilterDistance).", logLevel: .info)
            }
        }
    }

    @objc public var locationUpdateIntervalSec: Double = 3600 {
        didSet {
            // Ensure the value is at least 15 Mns
            if locationUpdateIntervalSec < 900 {
                locationUpdateIntervalSec = 900
                CastledGeofencerUtils.castledLog("Location update interval must be at least \(locationUpdateIntervalSec) seconds.Resetting to \(locationUpdateIntervalSec).", logLevel: .info)
            }
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.locationFilterDistance = try container.decodeIfPresent(Double.self, forKey: .locationFilterDistance) ?? 1000
        self.locationUpdateIntervalSec = try container.decodeIfPresent(Double.self, forKey: .locationUpdateIntervalSec) ?? 3600
        super.init()
    }

    // Implement the required method to encode properties
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locationFilterDistance, forKey: .locationFilterDistance)
        try container.encode(locationUpdateIntervalSec, forKey: .locationUpdateIntervalSec)
    }

    override public init() {}

    // Define CodingKeys enum
    private enum CodingKeys: String, CodingKey {
        case locationFilterDistance
        case locationUpdateIntervalSec
    }
}
