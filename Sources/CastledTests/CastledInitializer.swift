//
//  CastledInitializer.swift
//  CastledTests
//
//  Created by antony on 15/07/2024.
//

import Castled
import UIKit

class CastledInitializer: NSObject, CastledNotificationDelegate {
    func initializeCaslted(enableAppInbox: Bool = false, enableInApp: Bool = false, enableTracking: Bool = false, enableSessionTracking: Bool = false, enablePush: Bool = false, location: CastledLocation = .US) {
        let config = CastledConfigs.initialize(appId: "718c38e2e359d94367a2e0d35e1fd4df")
        config.enableAppInbox = enableAppInbox
        config.enableInApp = enableInApp
        config.enableTracking = enableTracking
        config.enableSessionTracking = enableSessionTracking
        config.skipUrlHandling = false
        config.location = location
        config.logLevel = CastledLogLevel.debug
        config.appGroupId = "group.com.castled.CastledPushDemo.Castled"
        Castled.initialize(withConfig: config, andDelegate: self)
        setUserId("antony@castled.io")
    }

    func setUserId(_ userId: String, userToken: String? = nil) {
        Castled.sharedInstance.setUserId(userId, userToken: userToken)
    }
}
