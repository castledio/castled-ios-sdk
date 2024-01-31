//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

class CastledUserDefaults: NSObject {
    private static let userDefaults = UserDefaults.standard
    static let userDefaultsSuit = UserDefaults(suiteName: CastledConfigsUtils.appGroupId) ?? UserDefaults.standard

    // Userdefault keys
    static let kCastledIsTokenRegisteredKey = "_castledIsTokenRegistered_"
    static let kCastledUserIdKey = "_castledUserId_"
    static let kCastledDeviceIddKey = "_castledDeviceId_"
    static let kCastledDeviceInfoKey = "_castledDeviceInfo_"
    static let kCastledUserTokenKey = "_castleduserToken_"
    static let kCastledAPNsTokenKey = "_castledApnsToken_"
    static let kCastledInAppsList = "castled_inapps"
    static let kCastledBadgeKey = "castled_application_badge"
    static let kCastledLastBadgeIncrementTimeKey = "castled_last_badge_increment_timer"
    static var kCastledEnablePushNotificationKey = "_castledEnablePushNotification_"
    static let kCastledFailedItems = "_castledFailedItems_"
    static let kCastledSavedInappConfigs = "_castledSavedInappConfigs_"
    static let kCastledDeliveredPushIds = "_castledDeliveredPushIds_"
    static let kCastledClickedPushIds = "_castledClickedPushIds_"
    static let kCastledLastInappDisplayedTime = "_castledLastInappDisplayedTime_"
    static let kCastledClickedNotiContentIndx = "_kCastledClickedNotiContentIndx_"
    static let shared = CastledUserDefaults()
    var userId: String?
    var userToken: String?
    var apnsToken: String?
    lazy var deliveredPushIds: [String] = {
        CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledDeliveredPushIds) as? [String] ?? [String]()
    }()

    lazy var clickedPushIds: [String] = {
        CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledClickedPushIds) as? [String] ?? [String]()
    }()

    override private init() {
        userId = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey)
        userToken = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserTokenKey)
        apnsToken = CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey)
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

    static func getValueFor(_ key: String,ud: UserDefaults = UserDefaults.standard) -> Any? {
        return ud.value(forKey: key)
    }

    static func getSharedUserdefaults() -> UserDefaults {
        return userDefaults
    }

    static func clearAllFromPreference() {
        // TODO: remove db
        removeFor(kCastledIsTokenRegisteredKey)
        removeFor(kCastledUserIdKey)
        removeFor(kCastledDeviceIddKey)
        removeFor(kCastledDeviceInfoKey)
        removeFor(kCastledUserTokenKey)
        removeFor(kCastledAPNsTokenKey)
        removeFor(kCastledInAppsList)
        removeFor(kCastledEnablePushNotificationKey)
        removeFor(kCastledFailedItems)
        removeFor(kCastledSavedInappConfigs)
        removeFor(kCastledDeliveredPushIds)
        removeFor(kCastledClickedPushIds)
        removeFor(kCastledLastInappDisplayedTime)
        removeFor(kCastledClickedNotiContentIndx, ud: CastledUserDefaults.userDefaultsSuit)
        CastledUserDefaults.shared.userId = nil
        CastledUserDefaults.shared.userToken = nil
        CastledUserDefaults.shared.apnsToken = nil
    }
}
