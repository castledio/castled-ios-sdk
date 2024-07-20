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

    override private init() {}
    public func getCastledConfig() -> CastledConfigs {
        return Castled.sharedInstance.getCastledConfig()
    }

    public func processCastledPushEventsFromExtension(userInfo: [AnyHashable: Any], appGroupId: String) {
        CastledUserDefaults.appGroupId = appGroupId
        CastledPushNotification.sharedInstance.shouldReportFromNotiExtension = true
        Castled.sharedInstance.processCastledPushEvents(userInfo: userInfo, deliveredDate: Date())
        CastledBadgeManager.shared.updateApplicationBadgeAfterNotification(userInfo)
    }
}
