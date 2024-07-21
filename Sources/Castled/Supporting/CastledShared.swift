//
//  CastledShared.swift
//  Castled
//
//  Created by antony on 20/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledShared: NSObject {
    @objc public static var sharedInstance = CastledShared()
    lazy var pendingPushEvents = [[AnyHashable: Any]]()
    @objc public var appGroupId: String = "" {
        didSet {
            if !appGroupId.isEmpty {
                CastledUserDefaults.appGroupId = appGroupId
                if !pendingPushEvents.isEmpty {
                    // this is to handle the scenario where the user set the appid after theu super. in their extension class
                    pendingPushEvents.forEach { event in
                        CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: event)
                    }
                    pendingPushEvents.removeAll()
                }
            }
        }
    }

    override private init() {}
    public func getCastledConfig() -> CastledConfigs {
        return Castled.sharedInstance.getCastledConfig()
    }

    public func reportCastledPushEventsFromExtension(userInfo: [AnyHashable: Any]) {
        if CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledAppInForeground) {
            return
        }
        if !appGroupId.isEmpty {
            CastledPushNotification.sharedInstance.shouldReportFromNotiExtension = true
            Castled.sharedInstance.processCastledPushEvents(userInfo: userInfo, deliveredDate: Date())
        } else {
            pendingPushEvents.append(userInfo)
        }
    }
}
