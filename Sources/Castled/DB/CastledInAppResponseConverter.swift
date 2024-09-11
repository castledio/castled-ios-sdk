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
        inapp.inapp_data = data
    }
}
