//
//  CastledConfigsUtils.swift
//  Castled
//
//  Created by antony on 24/01/2024.
//

import Foundation

class CastledConfigsUtils: NSObject {
    static var kCastledAppIddKey = "_castledAppid_"
    static var kCastledAppGroupId = "_castled_config_appgroup_id_"
    static var kCastledEnableAppInbox = "_castled_config_enable_inbox_"
    static var kCastledEnableInApp = "_castled_config_enable_innapp_"
    static var kCastledEnableTracking = "_castled_config_enable_tracking_"
    static var kCastledEnablePush = "_castled_config_enable_push_"
    static var kCastledInAppFetchIntervalSec = "_castled_config_inapp_fetchInterval_"
    static var kCastledlogLevel = "_castled_config_log_level_"
    static var kCastledlocation = "_castled_config_location_"
    static var kCastledpermittedBGIdentifier = "_castled_config_permitted_bg_identifier_"

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

    static var enableTracking: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnableTracking)
    }()

    static var enablePush: Bool = {
        CastledUserDefaults.getBoolean(kCastledEnablePush)
    }()

    static var inAppFetchIntervalSec: Int = {
        CastledUserDefaults.getValueFor(kCastledInAppFetchIntervalSec) as? Int ?? 15 * 60
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
        userDefaults.set(CastledConfigs.sharedInstance.enableTracking, forKey: kCastledEnableTracking)
        userDefaults.set(CastledConfigs.sharedInstance.enablePush, forKey: kCastledEnablePush)
        userDefaults.set(CastledConfigs.sharedInstance.inAppFetchIntervalSec, forKey: kCastledInAppFetchIntervalSec)
        userDefaults.set(CastledConfigs.sharedInstance.logLevel.rawValue, forKey: kCastledlogLevel)
        userDefaults.set(CastledConfigs.sharedInstance.location.rawValue, forKey: kCastledlocation)
        userDefaults.set(Castled.sharedInstance.instanceId, forKey: kCastledAppIddKey)
        appId = Castled.sharedInstance.instanceId
        userDefaults.synchronize()
    }
}
