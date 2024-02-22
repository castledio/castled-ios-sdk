//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

class CastledUserDefaults: NSObject {
    static let shared = CastledUserDefaults()

    private static let userDefaults = UserDefaults.standard
    static let userDefaultsSuit = UserDefaults(suiteName: CastledConfigsUtils.configs.appGroupId) ?? UserDefaults.standard
    // Userdefault keys
    static let kCastledUserIdKey = "_castledUserId_"
    static let kCastledDeviceIddKey = "_castledDeviceId_"
    static let kCastledDeviceInfoKey = "_castledDeviceInfo_"
    static let kCastledUserTokenKey = "_castleduserToken_"
    static let kCastledAPNsTokenKey = "_castledApnsToken_"
    static let kCastledFCMTokenKey = "_castledFCMToken_"
    static let kCastledBadgeKey = "_castledApplicationBadge_"
    static let kCastledLastBadgeIncrementTimeKey = "_castledLastBadgeIncrementTimer_"
    static let kCastledFailedItems = "_castledFailedItems_"
    static let kCastledSavedInappConfigs = "_castledSavedInappConfigs_"
    static let kCastledDeliveredPushIds = "_castledDeliveredPushIds_"
    static let kCastledClickedPushIds = "_castledClickedPushIds_"
    static let kCastledLastInappDisplayedTime = "_castledLastInappDisplayedTime_"
    static let kCastledClickedNotiContentIndx = "_castledClickedNotiContentIndx_"
    static let kCastledSessionId = "_castledSessionId_"
    static let kCastledLastSessionEndTime = "_castledLastSessionEndTime_"
    static let kCastledSessionDuration = "_castledSessionDuration_"
    static let kCastledSessionStartTime = "_castledSessionStartTime_"
    static let kCastledIsFirstSesion = "_castledIsFirstSesion_"
    static let kCastledInAppsList = "_castledInappsList_"

    var userId: String?
    var userToken: String?
    lazy var deliveredPushIds: [String] = {
        CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledDeliveredPushIds) as? [String] ?? [String]()
    }()

    lazy var clickedPushIds: [String] = {
        CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledClickedPushIds) as? [String] ?? [String]()
    }()

    lazy var apnsToken: String? = {
        CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey)
    }()

    lazy var fcmToken: String? = {
        CastledUserDefaults.getString(CastledUserDefaults.kCastledFCMTokenKey)
    }()

    override private init() {
        userId = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey)
        userToken = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserTokenKey)
    }

    @objc static func getString(_ key: String) -> String? {
        // Fetch value from UserDefaults
        if let stringValue = userDefaults.string(forKey: key) {
            return stringValue
        }
        return nil
    }

    static func setString(_ key: String, _ value: String?) {
        // Save the value in UserDefaults
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func getBoolean(_ key: String) -> Bool {
        // Fetch Bool value from UserDefaults
        return userDefaults.bool(forKey: key)
    }

    static func setBoolean(_ key: String, _ value: Bool?) {
        // Store value in UserDefaults
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    static func removeFor(_ key: String, ud: UserDefaults = UserDefaults.standard) {
        // Remove value from UserDefaults
        ud.removeObject(forKey: key)
        ud.synchronize()
    }

    static func setObjectFor(_ key: String, _ data: Any) {
        // Save the value in UserDefaults
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }

    static func getDataFor(_ key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }

    static func getObjectFor(_ key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    static func setValueFor(_ key: String, _ data: Any, ud: UserDefaults = UserDefaults.standard) {
        // Save the value in UserDefaults
        ud.setValue(data, forKey: key)
        ud.synchronize()
    }

    static func getValueFor(_ key: String, ud: UserDefaults = UserDefaults.standard) -> Any? {
        return ud.value(forKey: key)
    }

    static func getUserDefaults() -> UserDefaults {
        return userDefaults
    }

    static func clearAllFromPreference() {
        removeFor(kCastledUserIdKey)
        removeFor(kCastledDeviceIddKey)
        removeFor(kCastledDeviceInfoKey)
        removeFor(kCastledUserTokenKey)
        removeFor(kCastledFailedItems)
        removeFor(kCastledSavedInappConfigs)
        removeFor(kCastledDeliveredPushIds)
        removeFor(kCastledClickedPushIds)
        removeFor(kCastledLastInappDisplayedTime)
        removeFor(kCastledInAppsList)
        removeFor(kCastledClickedNotiContentIndx, ud: CastledUserDefaults.userDefaultsSuit)
        if CastledConfigsUtils.configs.enableSessionTracking {
            CastledSessionsManager.shared.resetSessionDetails()
        }
        CastledUserDefaults.shared.userId = nil
        CastledUserDefaults.shared.userToken = nil
    }
}
