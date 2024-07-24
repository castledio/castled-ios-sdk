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
    public func getCastledConfig() -> CastledConfigs {
        return Castled.sharedInstance.getCastledConfig()
    }

    public func reportCastledPushEventsFromExtension(userInfo: [AnyHashable: Any]) {
        if !appGroupId.isEmpty {
            if CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledAppInForeground) {
                return
            }
            CastledPushNotification.sharedInstance.shouldReportFromNotiExtension = true
            Castled.sharedInstance.processCastledPushEvents(userInfo: userInfo, deliveredDate: Date())
        } else {
            pendingPushEvent = userInfo
        }
    }

    public func getCastledDictionary(userInfo: [AnyHashable: Any]) -> [String: Any]? {
        return CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo)
    }
}
