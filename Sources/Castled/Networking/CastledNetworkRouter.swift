//
//  CastledNetworkRouter.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

struct CastledNetworkRequest {
    let baseURL: String
    let baseURLEndPoint: String
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
}

enum HTTPMethod: String {
    case post
    case put
    case get
}

enum CastledNetworkRouter {
    case registerUser(userID: String, apnsToken: String, instanceId: String)
    case fetchInAppNotification(userID: String, instanceId: String)
    case fetchInInboxItems(userID: String, instanceId: String)
    case reportPushEvents(params: [[String: Any]], instanceId: String)
    case reportInAppEvent(params: [[String: Any]], instanceId: String)
    case reportInboxEvent(params: [[String: Any]], instanceId: String)
    case reportDeviceInfo(deviceInfo: [String: String], userID: String)
    case reportCustomEvent(params: [[String: Any]])
    case reportUserAttributes(params: [String: Any])

    var baseURL: String {
        return "https://\(CastledConfigs.sharedInstance.location.description).castled.io/"
    }

    var baseURLEndPoint: String {
        return "backend/"
    }

    var request: CastledNetworkRequest {
        switch self {
        case .registerUser(let userID, let apnsToken, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/push/\(instanceId)/apns/register",
                                         method: .post,
                                         parameters: ["userId": userID, "apnsToken": apnsToken],
                                         headers: nil)

        case .reportPushEvents(let params, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/push/\(instanceId)/event",
                                         method: .post,
                                         parameters: ["events": params],
                                         headers: nil)

        case .fetchInAppNotification(let userID, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/inapp/\(instanceId)/ios/campaigns",
                                         method: .get,
                                         parameters: ["user": userID],
                                         headers: nil)
        case .fetchInInboxItems(let userID, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/app-inbox/\(instanceId)/ios/campaigns",
                                         method: .get,
                                         parameters: ["user": userID],
                                         headers: nil)

        case .reportInAppEvent(let params, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/inapp/\(instanceId)/ios/event",
                                         method: .post,
                                         parameters: ["events": params],
                                         headers: nil)
        case .reportInboxEvent(let params, let instanceId):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "v1/app-inbox/\(instanceId)/ios/event",
                                         method: .post,
                                         parameters: ["events": params],
                                         headers: nil)
        case .reportDeviceInfo(let deviceInfo, let userID):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "external/v1/collections/devices",
                                         method: .post,
                                         parameters: ["type": "track", "deviceInfo": deviceInfo, "userId": userID],
                                         headers: nil)
        case .reportCustomEvent(let params):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "external/v1/collections/events/lists?apiSource=app",
                                         method: .post,
                                         parameters: ["events": params],
                                         headers: getHeaders())
        case .reportUserAttributes(let params):
            return CastledNetworkRequest(baseURL: baseURL,
                                         baseURLEndPoint: baseURLEndPoint,
                                         path: "external/v1/collections/users?apiSource=app",
                                         method: .post,
                                         parameters: params,
                                         headers: getHeaders())
        }
    }

    private func getHeaders() -> [String: String] {
        var headers = [String: String]()
        if let secureUserId = CastledUserDefaults.shared.userToken {
            headers["Auth-Key"] = secureUserId
        }
        if let instanceId = Castled.sharedInstance?.instanceId {
            headers["App-Id"] = instanceId
        }
        return headers
    }
}
