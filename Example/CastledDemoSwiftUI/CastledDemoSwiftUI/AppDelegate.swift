//
//  AppDelegate.swift
//  CastledDemoSwiftUI
//
//  Created by antony on 04/07/2024.
//

import Castled
import Foundation
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    // swiftlint: disable line_length
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        let config = CastledConfigs.initialize(appId: "718c38e2e359d94367a2e0d35e1fd4df")
        config.enableAppInbox = true
        config.enablePush = true
        config.enableInApp = true
        config.enableTracking = true
        config.enableSessionTracking = true
        config.skipUrlHandling = false
        config.sessionTimeOutSec = 15
        config.location = CastledLocation.US
        config.logLevel = CastledLogLevel.debug
        config.appGroupId = "group.com.castled.CastledPushDemo.Castled"
        // Register the custom category
        registerForPush()
        // UNUserNotificationCenter.current().delegate = self
        Castled.initialize(withConfig: config, andDelegate: self)

        return true
    }

    private func setupMyApp() {
        // TODO: Add any intialization steps here.
        print("Application started up!")
    }
}

extension AppDelegate: CastledNotificationDelegate {
    func registerForPush() {
        // UNUserNotificationCenter.current().delegate = self
        Castled.sharedInstance.requestPushPermission(showSettingsAlert: true)
    }

    func notificationClicked(withNotificationType type: CastledNotificationType, buttonAction: CastledButtonAction, userInfo: [AnyHashable: Any]) {
        /*
         CastledNotificationType
            0 .push
            1 .inapp
         */
        print("***** Castled Notificiation Clicked *****\nCastledNotificationType: \(type.rawValue)\nbuttonTitle: '\(buttonAction.buttonTitle ?? "")'\nactionUri:\(buttonAction.actionUri ?? "")\nkeyVals: \(buttonAction.keyVals)\ninboxCopyEnabled: \(buttonAction.inboxCopyEnabled)\nButtonActionType: \(buttonAction.actionType)")
    }

    func didReceiveCastledRemoteNotification(withInfo userInfo: [AnyHashable: Any]) {
        print("***** Castled Notificiation Received *****\n \(userInfo)\n")
    }
}
