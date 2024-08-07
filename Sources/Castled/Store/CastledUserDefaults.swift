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
    static var userDefaults: UserDefaults = {
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
    static let kCastledIsMigratedToSuit = "_castledIsMigratedToSuit_"
    static let kCastledAppInForeground = "_castledAppInForeground_"

    public var userId: String? {
        didSet {
            if let userId = userId, oldValue != userId {
                notifyUserIdObservers(userId)
            }
        }
    }

    var userToken: String?
    public lazy var isAppInForeground = false

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

    // MARK: - SETTERS

    static func setString(_ key: String, _ value: String?) {
        CastledUserDefaults.setValueFor(key: key, value)
    }

    static func setBoolean(_ key: String, _ value: Bool) {
        CastledUserDefaults.setValueFor(key: key, value)
    }

    public static func setObjectFor(_ key: String, _ data: Any) {
        CastledUserDefaults.setValueFor(key: key, data)
    }

    // MARK: - GETTERS

    @objc static func getString(_ key: String) -> String? {
        guard let value = CastledUserDefaults.getObjectFor(key) as? String else {
            return nil
        }
        return value
    }

    static func getBoolean(_ key: String) -> Bool {
        guard let value = CastledUserDefaults.getObjectFor(key) as? Bool else {
            return false
        }
        return value
    }

    static func getDataFor(_ key: String) -> Data? {
        guard let value = CastledUserDefaults.getObjectFor(key) as? Data else {
            return nil
        }
        return value
    }

    // MARK: - COMMON METHODS

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
            CastledUserDefaults.setValueFor(key: key, data)
        } catch {}
    }

    static func removeFor(_ key: String) {
        // Remove value from UserDefaults
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }

    private static func setValueFor(key: String, _ data: Any?) {
        // Save the value in UserDefaults
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }

    static func getUserDefaults() -> UserDefaults {
        return userDefaults
    }

    // MARK: - FUNCTION EXCUTED AFTER LOGOUT

    static func clearAllFromPreference() {
        userDefaults.removeObject(forKey: kCastledUserIdKey)
        userDefaults.removeObject(forKey: kCastledDeviceIddKey)
        userDefaults.removeObject(forKey: kCastledDeviceInfoKey)
        userDefaults.removeObject(forKey: kCastledUserTokenKey)
        userDefaults.removeObject(forKey: kCastledFailedRequests)
        userDefaults.removeObject(forKey: kCastledSavedInappConfigs)
        userDefaults.removeObject(forKey: kCastledDeliveredPushIds)
        userDefaults.removeObject(forKey: kCastledClickedPushIds)
        userDefaults.removeObject(forKey: kCastledLastInappDisplayedTime)
        userDefaults.removeObject(forKey: kCastledInAppsList)
        userDefaults.removeObject(forKey: kCastledClickedNotiContentIndx)
        userDefaults.synchronize()
        CastledUserDefaults.shared.notifyLogout()
        CastledUserDefaults.shared.userId = nil
//        CastledUserDefaults.shared.userToken = nil
    }

    // MARK: - OBSERVERS FOR USERID AND LOGOUT

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

    // MARK: - Migration to suit, as suit was not there for the earlier sdk versions

    static func migrateDatasToSuit() {
        // Check if migration has already been performed
        if userDefaults.bool(forKey: kCastledIsMigratedToSuit) == true {
            return
        }

        // Use defer to mark migration as complete
        defer {
            userDefaults.set(true, forKey: kCastledIsMigratedToSuit)
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

    // MARK: - FOR OTHER SDKs

    static func saveAppGroupId() {
        // this is for react, there is no option to get the appgroup id for push click when the app is in terminated state as the intiialization part happens in react side. so local userdefault will get initialize instead of suit
        DispatchQueue.main.async {
            userDefaultsLocal.set(appGroupId, forKey: CastledConstants.AppGroupID.kCastledAppGroupId)
            userDefaultsLocal.synchronize()
        }
    }

    static func resetUserDefaults() {
        // this is for the other sdk like react, after changing the appgropupid
        if appGroupId.isEmpty {
            return
        }
        guard let defaults = UserDefaults(suiteName: appGroupId) else {
            return
        }
        userDefaults = defaults
    }

    public static func isAppGroupIsEnabledFor(_ appgroupId: String) -> Bool {
        if let _ = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appgroupId) {
            //CastledLog.castledLog("App group is available for '\(appgroupId)'", logLevel: .debug)
            return true
        } else {
            let errorMessage = "Kindly enable the App Groups in the Xcode capabilities for '\(appgroupId)'. Follow the link \nhttps://docs.castled.io/developer-resources/sdk-integration/ios/push-notifications#3-adding-an-app-group-id\n"
            if !CastledEnvironmentChecker.isRunningInDesignOrTestEnvironment() {
                fatalError(errorMessage)
            }
            CastledLog.castledLog(errorMessage, logLevel: .error)
        }
        return false
    }
}
