//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
@_spi(CastledInternal)

public class CastledUserDefaults: NSObject {
    public static let shared = CastledUserDefaults()
    private var observers: [CastledPreferenceStoreListener] = []
    static var appGroupId = ""
    static let userDefaults: UserDefaults = {
        if appGroupId.isEmpty {
            return UserDefaults.standard
        }
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return UserDefaults.standard
        }

        return defaults
    }()

    private static var userDefaultsLocal = UserDefaults.standard

    // Userdefault keys
    static let kCastledAppIddKey = "_castledAppid_"
    static let kCastledUserIdKey = "_castledUserId_"
    static let kCastledDeviceIddKey = "_castledDeviceId_"
    static let kCastledDeviceInfoKey = "_castledDeviceInfo_"
    static let kCastledUserTokenKey = "_castleduserToken_"
    static let kCastledAPNsTokenKey = "_castledApnsToken_"
    static let kCastledFCMTokenKey = "_castledFCMToken_"
    public static let kCastledBadgeKey = "_castledApplicationBadge_"
    public static let kCastledLastBadgeIncrementTimeKey = "_castledLastBadgeIncrementTimer_"
    public static let kCastledFailedRequests = "_castledFailedRequests_"
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
    static let kCastledIsMigratedToSuit = "_castledUsMigratedToSuit_"
    static let kCastledAppInForeground = "_castledAppInForeground_"

    public var userId: String? {
        didSet {
            if let userId = userId {
                notifyUserIdObservers(userId)
            }
        }
    }

    var userToken: String?
    public var isAppInForeground = false {
        didSet {
            CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledAppInForeground, isAppInForeground)
        }
    }

    func getDeliveredPushIds() -> [String] {
        return CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledDeliveredPushIds) as? [String] ?? [String]()
    }

    func getClickedPushIds() -> [String] {
        return CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledClickedPushIds) as? [String] ?? [String]()
    }

    lazy var apnsToken: String? = {
        CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey)
    }()

    lazy var fcmToken: String? = {
        CastledUserDefaults.getString(CastledUserDefaults.kCastledFCMTokenKey)
    }()

    override private init() {
        super.init()
        initializeUserDetails()
    }

    private func initializeUserDetails() {
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

    static func removeFor(_ key: String) {
        // Remove value from UserDefaults
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }

    public static func setObjectFor(_ key: String, _ data: Any) {
        // Save the value in UserDefaults
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }

    static func getDataFor(_ key: String) -> Data? {
        return userDefaults.data(forKey: key)
    }

    public static func getObjectFor(_ key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    public static func getObjectFor<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            return nil
        }
    }

    public static func setObject<T: Encodable>(_ object: T, as type: T.Type, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
            userDefaults.synchronize()
        } catch {}
    }

    static func setValueFor(_ key: String, _ data: Any) {
        // Save the value in UserDefaults
        userDefaults.setValue(data, forKey: key)
        userDefaults.synchronize()
    }

    static func getValueFor(_ key: String) -> Any? {
        return userDefaults.value(forKey: key)
    }

    static func getUserDefaults() -> UserDefaults {
        return userDefaults
    }

    static func clearAllFromPreference() {
        removeFor(kCastledUserIdKey)
        removeFor(kCastledDeviceIddKey)
        removeFor(kCastledDeviceInfoKey)
        removeFor(kCastledUserTokenKey)
        removeFor(kCastledFailedRequests)
        removeFor(kCastledSavedInappConfigs)
        removeFor(kCastledDeliveredPushIds)
        removeFor(kCastledClickedPushIds)
        removeFor(kCastledLastInappDisplayedTime)
        removeFor(kCastledInAppsList)
        removeFor(kCastledClickedNotiContentIndx)
        CastledUserDefaults.shared.notifyLogout()
        CastledUserDefaults.shared.userId = nil
//        CastledUserDefaults.shared.userToken = nil
    }

    public func addObserver(_ observer: CastledPreferenceStoreListener) {
        if let userId = userId {
            observer.onStoreUserIdSet(userId)
        }
        observers.append(observer)
    }

    private func notifyUserIdObservers(_ userid: String) {
        for observer in observers {
            observer.onStoreUserIdSet(userid)
        }
    }

    private func notifyLogout() {
        for observer in observers {
            observer.onUserLoggedOut()
        }
    }

    static func migrateDatasToSuit() {
        // Check if migration has already been performed
        if userDefaults.bool(forKey: kCastledIsMigratedToSuit) == true {
            return
        }

        // Use defer to mark migration as complete, even if an error occurs
        defer {
            userDefaults.setValue(true, forKey: kCastledIsMigratedToSuit)
            userDefaults.synchronize()
            CastledUserDefaults.shared.initializeUserDetails()
            CastledUserDefaults.saveAppGroupId()
        }
        guard userDefaultsLocal.string(forKey: kCastledAppIddKey) != nil else {
            return
        }

        // Keys to migrate
        let keysToMigrate = [
            kCastledAppIddKey,
            kCastledUserIdKey,
            kCastledDeviceIddKey,
            kCastledDeviceInfoKey,
            kCastledUserTokenKey,
            kCastledAPNsTokenKey,
            kCastledFCMTokenKey,
            kCastledBadgeKey,
            kCastledLastBadgeIncrementTimeKey,
            kCastledFailedRequests,
            kCastledSavedInappConfigs,
            kCastledDeliveredPushIds,
            kCastledClickedPushIds,
            kCastledInAppsList,
            kCastledLastInappDisplayedTime,
            kCastledSessionId,
            kCastledLastSessionEndTime,
            kCastledSessionDuration,
            kCastledSessionStartTime,
            kCastledIsFirstSesion
        ]

        // Migrate data
        for key in keysToMigrate {
            if let value = userDefaultsLocal.object(forKey: key) {
                userDefaults.set(value, forKey: key)
            }
        }

        // Remove old data
        for key in keysToMigrate {
            userDefaultsLocal.removeObject(forKey: key)
        }

        userDefaultsLocal.synchronize()
    }

    static func saveAppGroupId() {
        // this is for react, there is no option to get the appgroup id for push click when the app is in terminated state as the intiialization part happens in react side. so local userdefault will get initialize instead of suit
        DispatchQueue.main.async {
            userDefaultsLocal.setValue(appGroupId, forKey: CastledConstants.AppGroupID.kCastledAppGroupId)
            userDefaultsLocal.synchronize()
        }
    }
}
