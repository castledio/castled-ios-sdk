//
//  CastledInAppResponseConverter.swift
//  Castled
//
//  Created by antony on 03/10/2023.
//

import Foundation

enum CastledInAppResponseConverter {
    static func convertToinAppItem(inapp: CastledInAppMO) -> CastledInAppObject? {
        return inapp.inapp_data?.encodableFromData(to: CastledInAppObject.self)
    }

    static func convertToInapp(inAppItem: CastledInAppObject, data: Data, inapp: CastledInAppMO) {
        inapp.inapp_id = Int64(inAppItem.notificationID)
        inapp.inapp_attempts = 0
        inapp.inapp_maxm_attempts = Int16(inAppItem.displayConfig?.displayLimit ?? 0)
        inapp.inapp_min_interval_btwd_isplays = Int32(Int16(inAppItem.displayConfig?.minIntervalBtwDisplays ?? 0))
        inapp.inapp_last_displayed_time = Date(timeIntervalSince1970: 0)
        inapp.inapp_data = data
    }
}
