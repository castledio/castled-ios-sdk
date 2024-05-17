//
//  CastledNetworkRouter.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

enum CastledNetworkRouter {
    case registerUser(params: [String: Any], instanceId: String)
    case fetchInAppNotification(userID: String, instanceId: String)
    case reportPushEvents(params: [[String: Any]], instanceId: String)
    case reportInAppEvent(params: [[String: Any]], instanceId: String)
    case reportInboxEvent(params: [[String: Any]], instanceId: String)
    case reportDeviceInfo(deviceInfo: [String: String], userID: String)
    case reportCustomEvent(params: [[String: Any]])
    case reportUserEvent(params: [String: Any])
    case reportUserAttributes(params: [String: Any])
    case logoutUser(params: [String: Any], instanceId: String)
    case reportSession(params: [[String: Any]])

    
    var request: CastledNetworkRequest {
        switch self {
        case .registerUser(let params, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/push/\(instanceId)/apns/register",
                method: .post,
                parameters: params)

        case .reportPushEvents(let params, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/push/\(instanceId)/event",
                method: .post,
                parameters: ["events": params])

        case .fetchInAppNotification(let userID, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/inapp/\(instanceId)/ios/campaigns",
                method: .get,
                parameters: ["user": userID])

        case .reportInAppEvent(let params, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/inapp/\(instanceId)/ios/event",
                method: .post,
                parameters: ["events": params])
        case .reportInboxEvent(let params, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/app-inbox/\(instanceId)/ios/event",
                method: .post,
                parameters: ["events": params])
        case .reportDeviceInfo(let deviceInfo, let userID):
            return CastledNetworkRequest(
                type: "",
                path: "external/v1/collections/devices",
                method: .post,
                parameters: ["type": "track", "deviceInfo": deviceInfo, "userId": userID])
        case .reportCustomEvent(let params):
            return CastledNetworkRequest(
                type: "",
                path: "external/v1/collections/events/lists?apiSource=app",
                method: .post,
                parameters: ["events": params])

        case .reportSession(let params):
            return CastledNetworkRequest(
                type: "",
                path: "external/v1/collections/session-events/lists",
                method: .post,
                parameters: ["events": params])

        case .reportUserAttributes(let params):
            return CastledNetworkRequest(
                type: "",
                path: "external/v1/collections/users?apiSource=app",
                method: .post,
                parameters: params)
        case .reportUserEvent(let params): // not using
            return CastledNetworkRequest(
                type: "",
                path: "external/v1/collections/events/lists?apiSource=app",
                method: .post,
                parameters: params)
        case .logoutUser(let params, let instanceId):
            return CastledNetworkRequest(
                type: "",
                path: "v1/push/\(instanceId)/apns/logout",
                method: .put,
                parameters: params)
        }
    }
}
