//
//  CastledConfigsUtils.swift
//  Castled
//
//  Created by antony on 24/01/2024.
//

import Foundation

class CastledConfigsUtils: NSObject {
    static let kCastledAppIddKey = "_castledAppid_"
    static let kCastledAppGroupId = "_castled_config_appgroup_id_"
    static let kCastledEnableAppInbox = "_castled_config_enable_inbox_"
    static let kCastledEnableInApp = "_castled_config_enable_innapp_"
    static let kCastledEnableSession = "_castled_config_enable_session_"
    static let kCastledEnableTracking = "_castled_config_enable_tracking_"
    static let kCastledEnablePush = "_castled_config_enable_push_"
    static let kCastledInAppFetchIntervalSec = "_castled_config_inapp_fetchInterval_"
    static let kCastledInAppSessionTimeoutSec = "_castled_config_session_timeout_"
    static let kCastledlogLevel = "_castled_config_log_level_"
    static let kCastledlocation = "_castled_config_location_"
    static let kCastledpermittedBGIdentifier = "_castled_config_permitted_bg_identifier_"

    // var instanceId: String = ""

    // MARK: - Supporting properites

    static var appId: String? = {
        CastledUserDefaults.getString(kCastledAppIddKey)
    }()

    static var appGroupId: String = {
        CastledUserDefaults.getString(kCastledAppGroupId) ?? ""
    }()

    static var enableAppInbox: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnableAppInbox)
    }()

    static var enableInApp: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnableInApp)
    }()

    static var enableSessionTracking: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnableSession)
    }()

    static var enableTracking: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnableTracking)
    }()

    static var enablePush: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnablePush)
    }()

    static var inAppFetchIntervalSec: Int = {
        CastledUserDefaults.getValueFor(kCastledInAppFetchIntervalSec) as? Int ?? 15 * 60
    }()

    static var sessionTimeOutSec: Double = {
        CastledUserDefaults.getValueFor(kCastledInAppSessionTimeoutSec) as? Double ?? 15 * 60
    }()

    static var permittedBGIdentifier: String = {
        CastledUserDefaults.getString(kCastledpermittedBGIdentifier) ?? ""
    }()

    static var logLevel: CastledLogLevel = {
        (CastledUserDefaults.getValueFor(kCastledlogLevel) as? Int)
            .flatMap(CastledLogLevel.init(rawValue:)) ?? .debug
    }()

    static var location: CastledLocation = {
        (CastledUserDefaults.getValueFor(kCastledlocation) as? Int)
            .flatMap(CastledLocation.init(rawValue:)) ?? .US

    }()

    static func saveTheConfigs() {
        let userDefaults = CastledUserDefaults.getSharedUserdefaults()
        userDefaults.set(CastledConfigs.sharedInstance.appGroupId, forKey: kCastledAppGroupId)
        userDefaults.set(CastledConfigs.sharedInstance.permittedBGIdentifier, forKey: kCastledpermittedBGIdentifier)
        userDefaults.set(CastledConfigs.sharedInstance.enableAppInbox, forKey: kCastledEnableAppInbox)
        userDefaults.set(CastledConfigs.sharedInstance.enableInApp, forKey: kCastledEnableInApp)
        userDefaults.set(CastledConfigs.sharedInstance.enableSessionTracking, forKey: kCastledEnableSession)
        userDefaults.set(CastledConfigs.sharedInstance.enableTracking, forKey: kCastledEnableTracking)
        userDefaults.set(CastledConfigs.sharedInstance.enablePush, forKey: kCastledEnablePush)
        userDefaults.set(CastledConfigs.sharedInstance.sessionTimeOutSec, forKey: kCastledInAppSessionTimeoutSec)
        userDefaults.set(CastledConfigs.sharedInstance.inAppFetchIntervalSec, forKey: kCastledInAppFetchIntervalSec)
        userDefaults.set(CastledConfigs.sharedInstance.logLevel.rawValue, forKey: kCastledlogLevel)
        userDefaults.set(CastledConfigs.sharedInstance.location.rawValue, forKey: kCastledlocation)
        userDefaults.set(Castled.sharedInstance.instanceId, forKey: kCastledAppIddKey)
        appId = Castled.sharedInstance.instanceId
        userDefaults.synchronize()
    }
}
