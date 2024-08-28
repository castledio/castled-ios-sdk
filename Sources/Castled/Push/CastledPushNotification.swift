//
//  CastledPushNotification.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

@objc class CastledPushNotification: NSObject {
    @objc static var sharedInstance = CastledPushNotification()
    lazy var userId = CastledUserDefaults.shared.userId ?? ""
    var instanceId: String { CastledConfigsUtils.appId ?? "" }
    var isInitilized = false

    override private init() {}

    @objc public func initializePush() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("Push initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Pushmodule already initialized..", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.pushRequest.rawValue, handler: CastledPushNotificationEventsRequestHandler.self)
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.userRegisterationRequest.rawValue, handler: CastledPushNotificationRegisterRequestHandler.self)
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.logoutUser.rawValue, handler: CastledPushNotificationLogoutRequestHandler.self)

        isInitilized = true
        CastledPushNotificationController.sharedInstance.initializePush()
        CastledLog.castledLog("Push module initialized..", logLevel: CastledLogLevel.info)
    }

    func reportPushEvents(params: [[String: Any]], success: @escaping (Bool) -> Void) {
        if instanceId.isEmpty {
            CastledLog.castledLog("Report push events failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            success(false)
            return
        }
        CastledLog.castledLog("Push notification is being reported…", logLevel: .debug)
        CastledPushNotificationRepository.reportPushEvents(params: params) { result in
            success(result)
        }
    }

    func registerUser(params: [String: Any]) {
        if !isInitilized {
            CastledLog.castledLog("Register user failed: \(CastledExceptionMessages.pushDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledPushNotificationRepository.registerUser(params: params)
    }

    func logoutUser(params: [String: Any]) {
        if !isInitilized {
            CastledLog.castledLog("Logout user failed: \(CastledExceptionMessages.pushDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if userId.isEmpty {
            return
        }
        CastledPushNotificationRepository.logoutUser(params: params)
    }

    @objc func isPushFromCastled(userInfo: [AnyHashable: Any]) -> Bool {
        if let customCasledDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: userInfo), customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
            return true
        }
        return false
    }

    func getCastledDictionary(userInfo: [AnyHashable: Any]) -> [String: Any]? {
        if let customCasledDict = userInfo[CastledConstants.PushNotification.castledKey] as? [String: Any] {
            return customCasledDict
        }
        return nil
    }
}
