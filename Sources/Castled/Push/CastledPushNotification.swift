//
//  CastledPushNotification.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

@objc class CastledPushNotification: NSObject {
    @objc static var sharedInstance = CastledPushNotification()
    var userId = CastledUserDefaults.shared.userId ?? ""
    let castledConfig = Castled.sharedInstance.getCastledConfig()
    private var isInitilized = false

    override private init() {}

    @objc public func initializePush() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("Push initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Pushmodule already initialized.. \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.pushRequest.rawValue] = CastledPushNotificationEventsRequestHandler.self
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.userRegisterationRequest.rawValue] = CastledPushNotificationRegisterRequestHandler.self
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.logoutUser.rawValue] = CastledPushNotificationLogoutRequestHandler.self

        CastledPushNotificationController.sharedInstance.initializePush()
        isInitilized = true
        CastledLog.castledLog("Push module initialized..", logLevel: CastledLogLevel.info)
    }

    func reportPushEvents(params: [[String: Any]], success: @escaping (Bool) -> Void) {
        if userId.isEmpty {
            success(false)
            return
        }
        else if !isInitilized {
            CastledLog.castledLog("Report push events failed: \(CastledExceptionMessages.pushDisabled.rawValue)", logLevel: CastledLogLevel.error)
            success(false)
            return
        }

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
}
