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
}
