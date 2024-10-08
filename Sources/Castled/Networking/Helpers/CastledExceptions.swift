//
//  CastledExceptions.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
@_spi(CastledInternal)

public enum CastledExceptionMessages: String {
    case common = "We are not able to perform this request.Please check your internet connection and try again."
    case notInitialised = "Kindly initialize the Castled SDK with proper appId in the AppDelegate"
    case emptyToken = "Kindly allow the permission for push notification from the settings Or pass a valid APNs token in the api call."
    case iOS13Less = "Sorry for the inconvenience. Currently we are supporting iOS 13 and above."
    case paramsMisMatch = "Unable to create the request. Please check the params or url."
    case userNotRegistered = "Please register the user with Castled using the method Castled.sharedInstance.setUserId(< userId >)"
    case pushDisabled = "Set 'enablePush' while initializing Castled SDK"
    case appInboxDisabled = "Set 'enableAppInbox' while initializing Castled SDK"
    case inAppDisabled = "Set 'enableInapp' while initializing Castled SDK"
    case trackingDisabled = "Set 'enableTracking' while initializing Castled SDK"
    case emptyEventsArray = "Notificaion Id array cannot be empty"
    case noDeviceToken = "Register User needs a valid APNS token"
    case permittedIdentifiersNotInitialised = "Kindly add 'BGTaskSchedulerPermittedIdentifiers' key to the Info.plist and pass the same value  as 'CastledConfigs permittedBGIdentifier'. Please note that In iOS 13 and later, adding a BGTaskSchedulerPermittedIdentifiers key to the Info.plist disables the application(_:performFetchWithCompletionHandler:) and setMinimumBackgroundFetchInterval(_:) methods."
    case backgroundProcessNotenabled = "Please enable background Processing capability in your app by making sure that the 'Background Modes' capability is enabled, and that the 'Background Processing' and 'Remote notifications' options are selected."
    case pushPermissionNotGranted = "Push notification permission has not been granted yet."
    case appGrouIdEmpty = "'appGroupId' is empty. Consider setting a value for proper functionality."
    case appIdNotInitialized = "'Appid' has not been initialized. Call CastledConfigs.initialize(appId: <app_id>) with a valid app_id."
    case pushPreviouslyDenied = "You have previously denied push notification permission. Please go to your settings to enable push notifications."
}

enum CastledException: Error {
    case error(String)
}

extension CastledException: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .error(let description):
            return description
        }
    }
}

func getError(from message: String) -> NSError {
    return NSError(domain: "com.castled.error", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
}
