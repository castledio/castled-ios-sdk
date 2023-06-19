//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
@objc public class CastledUserDefaults: NSObject {
    
    // static let userDefaults = UserDefaults.init(suiteName: appConfiguration.suitName) ?? UserDefaults.standard
    
    static let userDefaults = UserDefaults.standard
    
    //Userdefault keys
    internal static var kCastledIsTokenRegisteredKey        = "_castledIsTokenRegistered_"
    internal static var kCastledAnonymousIdKey              = "_castledAnonymousId_"
    @objc public static var kCastledUserIdKey                   = "_castledUserId_"
    @objc public static let kCastledAPNsTokenKey         = "_castledApnsToken_"
    public static let kCastledInAppsList               = "castled_inapps"
    public static var kCastledEnablePushNotificationKey = "_castledEnablePushNotification_"
    
    internal static let kCastledSendingInAppsEvents       = "_castledSendingInAppEvents_"
    internal static let kCastledSendingPushEvents         = "_castledSendingPushEvents_"
    internal static let kCastledSavedInappConfigs         = "_castledSavedInappConfigs_"
    internal static let kCastledLastInappDisplayedTime         = "_castledLastInappDisplayedTime_"
    
    
    
    @objc public static func getString(_ key: String) -> String? {

        // Fetch value from UserDefaults
        if let stringValue = userDefaults.string(forKey: key){
            return stringValue
        }
        return nil
    }
    
    internal class func setString(_ key: String, _ value: String?) {
        // Save the value in UserDefaults
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    class func getBoolean(_ key: String) -> Bool {
        
        // Fetch Bool value from UserDefaults
        return userDefaults.bool(forKey: key)
    }
    
    class func setBoolean(_ key: String, _ value: Bool?) {
        // Store value in UserDefaults
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
        
    }
    class func removeFor(_ key: String){
        
        // Remove value from UserDefaults
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
        
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
}
