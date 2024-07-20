//
//  CastledTestingHelper.swift
//  Castled
//
//  Created by antony on 16/07/2024.
//

import Foundation
@_spi(CastledTestable)

public class CastledTestingHelper {
    public static let shared = CastledTestingHelper()

    public func getSatisifiedInApps() -> [CastledInAppObject] {
        CastledInAppsDisplayController.sharedInstance.getAllPendingItems()
    }

    public func getSessionId() -> String {
        return CastledSessionsManager.shared.sessionId
    }

    func getLastSessionDuration() -> Double {
        return CastledSessionsManager.shared.getLastSessionDuration()
    }

    public func getAppgroupIdFromUserdefaults() -> String {
        return CastledUserDefaults.appGroupId
    }
}
