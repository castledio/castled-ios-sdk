//
//  CastledPushNotificationApi.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation

enum CastledPushNotificationRepository {
    static let eventsPath = "v1/push/\(CastledPushNotification.sharedInstance.castledConfig.instanceId)/event"
    static let registerUserPath = "v1/push/\(CastledPushNotification.sharedInstance.castledConfig.instanceId)/apns/register"
    static let logoutPath = "v1/push/\(CastledPushNotification.sharedInstance.castledConfig.instanceId)/apns/logout"

    static func getEventsRequest(params: [[String: Any]]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.pushRequest.rawValue,
            method: .post,
            parameters: [CastledConstants.EventsReporting.events: params])
    }

    static func getUserRegnRequest(params: [String: Any]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.userRegisterationRequest.rawValue,
            method: .post,
            parameters: params)
    }

    static func getLogoutRequest(params: [String: Any]) -> CastledNetworkRequest {
        return CastledNetworkRequest(
            type: CastledConstants.CastledNetworkRequestType.logoutUser.rawValue,
            method: .put,
            parameters: params)
    }

    static func reportPushEvents(params: [[String: Any]], success: @escaping (Bool) -> Void) {
        let request = CastledPushNotificationRepository.getEventsRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: eventsPath, withRetry: true) { response in
            success(response.success)
        }
    }

    static func registerUser(params: [String: Any]) {
        print("Castled: Registering to caslted with params \(params)")
        let request = CastledPushNotificationRepository.getUserRegnRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: registerUserPath, withRetry: true) { response
            in
            if let uid = params[CastledConstants.PushNotification.userId] as? String {
                if response.success {
                    print("'\(uid)' registered successfully...\(params)")

                    //   CastledLog.castledLog("'\(uid)' registered successfully...\(params)", logLevel: CastledLogLevel.debug)
                } else {
                    print("Register User '\(uid)' failed: \(response.errorMessage) and params\(params)")
//                    CastledLog.castledLog("Register User '\(uid)' failed: \(response.errorMessage) and params\(params)", logLevel: CastledLogLevel.error)
                }
            }
        }
    }

    static func logoutUser(params: [String: Any]) {
        let request = CastledPushNotificationRepository.getLogoutRequest(params: params)
        CastledNetworkLayer.shared.makeApiCall(request: request, path: logoutPath, withRetry: true) { _ in
        }
    }
}
