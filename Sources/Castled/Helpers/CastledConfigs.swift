//
//  CastledConfigs.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation

@objc public class CastledConfigs: NSObject {
    private static var sharedConfig: CastledConfigs?
    var instanceId: String = ""

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

    @objc public lazy var appGroupId: String = {
        ""
    }()

    @objc public lazy var enableAppInbox: Bool = {
        false
    }()

    @objc public lazy var enableInApp: Bool = {
        false
    }()

    @objc public lazy var enableTracking: Bool = {
        false
    }()

    @objc public lazy var enablePush = false {
        didSet {
            if enablePush {
                Castled.sharedInstance?.registerForPushNotifications()
            }
        }
    }

    @objc public lazy var inAppFetchIntervalSec: Int = {
        15 * 60
    }()

    @objc public lazy var logLevel: CastledLogLevel = {
        CastledLogLevel.debug
    }()

    @objc public lazy var location: CastledLocation = {
        CastledLocation.US
    }()

    @objc public lazy var permittedBGIdentifier: String = {
        ""
    }()

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
            fatalError("CastledConfigs has not been initialized. Call CastledConfigs.initialize(instanceId:) first.")
        }
        return sharedConfig
    }
}
