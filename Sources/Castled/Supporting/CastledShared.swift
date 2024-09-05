//
//  CastledShared.swift
//  Castled
//
//  Created by antony on 20/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledShared: NSObject {
    // Dont initialize/ call any CastledUserDefaults method here for extensions. only after setting appGroupId. otherwise userdefaults will get initialize without group id
    @objc public static var sharedInstance = CastledShared()
    var pendingPushEvent: [AnyHashable: Any]?
    @objc public var appGroupId: String = "" {
        didSet {
            if !appGroupId.isEmpty {
                // CastledLog.castledLog("Set the appGroupId from extensions '\(appGroupId)'", logLevel: .debug)
                CastledUserDefaults.appGroupId = appGroupId
                if let event = pendingPushEvent {
                    // this is to handle the scenario where the user set the appid after theu super. in their extension class
                    CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: event)
                    pendingPushEvent = nil
                }
            }
        }
    }

    override private init() {}

    public func reportCastledPushEventsFromExtension(userInfo: [AnyHashable: Any]) {
        if !appGroupId.isEmpty {
            CastledLog.castledLog("About to report the push received event from the extension.", logLevel: .debug)
            Castled.sharedInstance.processCastledPushEvents(userInfo: userInfo, deliveredDate: Date())
        } else {
            CastledLog.castledLog("Not reporting the push event from the extension as appGroupId hasn't set.", logLevel: .warning)
            pendingPushEvent = userInfo
        }
    }

    public func getCastledDictionary(userInfo: [AnyHashable: Any]) -> [String: Any]? {
        return CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo)
    }

    // MARK: - REACT AND OTHER SDK SUPPORT

    /**
     Supporting method for react and other SDKs
     */
    public func setDelegate(_ delegate: CastledNotificationDelegate) {
        Castled.sharedInstance.delegate = delegate
    }

    public func initializeComponents() {
        if let appgrpId = UserDefaults.standard.value(forKey: CastledConstants.AppGroupID.kCastledAppGroupId) as? String, !appgrpId.isEmpty {
            appGroupId = appgrpId
        }
    }

    public func getCastledConfig() -> CastledConfigs {
        return CastledConfigsUtils.configs
    }

    /**
     Supporting method for react and other SDKs
     */
    public func logMessage(_ message: String, _ logLevel: CastledLogLevel) {
        CastledLog.castledLog(message, logLevel: logLevel)
    }

    public func isCastledInitialized() -> Bool {
        return Castled.sharedInstance.isCastledInitialized()
    }
}
