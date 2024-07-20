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
        let userDefaults = UserDefaults(suiteName: CastledUserDefaults.appGroupId)
        let dict = userDefaults!.dictionaryRepresentation()
        for key in dict.keys {
            if let value = dict[key], key.contains("_castled") {
                print("\(key) = \(value)")
            }
        }
        Castled.sharedInstance.processCastledPushEvents(userInfo: userInfo, deliveredDate: Date())
    }
}
