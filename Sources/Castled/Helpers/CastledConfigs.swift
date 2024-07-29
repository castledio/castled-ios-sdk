//
//  CastledConfigs.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation

@objc public class CastledConfigs: NSObject, Codable {
    private static var sharedConfig: CastledConfigs?
    public var instanceId: String = ""

    // MARK: - initialization method

    @objc public static func initialize(appId instanceId: String) -> CastledConfigs {
        if let existingConfig = CastledConfigs.sharedConfig {
            existingConfig.instanceId = instanceId
        } else {
            CastledConfigs.sharedConfig = CastledConfigs(instanceId: instanceId)
        }
        return CastledConfigs.sharedConfig!
    }

    // MARK: - Supporting properites

    @objc public var appGroupId: String = "" {
        didSet {
            if !appGroupId.isEmpty {
                CastledUserDefaults.appGroupId = appGroupId
                CastledUserDefaults.saveAppGroupId()
            }
        }
    }

    @objc public var enableAppInbox: Bool = false
    @objc public var enableInApp: Bool = false
    @objc public var enableSessionTracking: Bool = true
    @objc public var enableTracking: Bool = false
    @objc public var enablePush: Bool = false
    @objc public var skipUrlHandling: Bool = false

    @objc public var inAppFetchIntervalSec: Int = 15 * 60
    @objc public var sessionTimeOutSec: Int = 15 * 60

    @objc public var logLevel: CastledLogLevel = .debug
    @objc public var location: CastledLocation = .US

    @objc public var permittedBGIdentifier: String = ""

    // MARK: - Supporting private methods

    private init(instanceId: String) {
        self.instanceId = instanceId
        super.init()
        if CastledConfigs.sharedConfig == nil {
            CastledConfigs.sharedConfig = self
        }
    }

    static var sharedInstance: CastledConfigs {
        guard let sharedConfig = sharedConfig else {
            fatalError("'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id.")
        }
        return sharedConfig
    }

    // Implement the required initializer to decode properties
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.instanceId = try container.decode(String.self, forKey: .instanceId)
        self.appGroupId = try container.decodeIfPresent(String.self, forKey: .appGroupId) ?? ""
        self.permittedBGIdentifier = try container.decodeIfPresent(String.self, forKey: .permittedBGIdentifier) ?? ""
        self.enablePush = try container.decodeIfPresent(Bool.self, forKey: .enablePush) ?? false
        self.enableAppInbox = try container.decodeIfPresent(Bool.self, forKey: .enableAppInbox) ?? false
        self.enableInApp = try container.decodeIfPresent(Bool.self, forKey: .enableInApp) ?? false
        self.enableSessionTracking = try container.decodeIfPresent(Bool.self, forKey: .enableSessionTracking) ?? true
        self.enableTracking = try container.decodeIfPresent(Bool.self, forKey: .enableTracking) ?? false
        self.skipUrlHandling = try container.decodeIfPresent(Bool.self, forKey: .skipUrlHandling) ?? false
        self.inAppFetchIntervalSec = try container.decodeIfPresent(Int.self, forKey: .inAppFetchIntervalSec) ?? 15 * 60
        self.sessionTimeOutSec = try container.decodeIfPresent(Int.self, forKey: .sessionTimeOutSec) ?? 15 * 60
        self.logLevel = try container.decodeIfPresent(CastledLogLevel.self, forKey: .logLevel) ?? CastledLogLevel.debug
        self.location = try container.decodeIfPresent(CastledLocation.self, forKey: .location) ?? CastledLocation.US

        // Call super initializer if needed
        super.init()
    }

    // Implement the required method to encode properties
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(instanceId, forKey: .instanceId)
        try container.encode(appGroupId, forKey: .appGroupId)
        try container.encode(permittedBGIdentifier, forKey: .permittedBGIdentifier)
        try container.encode(enablePush, forKey: .enablePush)
        try container.encode(enableAppInbox, forKey: .enableAppInbox)
        try container.encode(enableInApp, forKey: .enableInApp)
        try container.encode(enableSessionTracking, forKey: .enableSessionTracking)
        try container.encode(enableTracking, forKey: .enableTracking)
        try container.encode(skipUrlHandling, forKey: .skipUrlHandling)
        try container.encode(inAppFetchIntervalSec, forKey: .inAppFetchIntervalSec)
        try container.encode(sessionTimeOutSec, forKey: .sessionTimeOutSec)
        try container.encode(location, forKey: .location)
        try container.encode(logLevel, forKey: .logLevel)
    }

    // Define CodingKeys enum
    private enum CodingKeys: String, CodingKey {
        case instanceId
        case appGroupId
        case permittedBGIdentifier
        case enablePush
        case enableAppInbox
        case enableInApp
        case enableSessionTracking
        case enableTracking
        case skipUrlHandling
        case inAppFetchIntervalSec
        case sessionTimeOutSec
        case logLevel
        case location
    }
}
