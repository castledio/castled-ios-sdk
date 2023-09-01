//
//  CastledNetworkRouter.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

struct CastledEndpoint {
    let baseURL: String
    let baseURLEndPoint: String
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
}

enum HTTPMethod: String {
    case post
    case put
    case get
}


enum CastledNetworkRouter {
    case registerUser(userID: String, apnsToken: String, instanceId: String)
    case registerEvents(params: [[String: Any]], instanceId: String)
    case triggerCampaign
    case fetchInAppNotification(userID: String, instanceId: String)
    case fetchInInboxItems(userID: String, instanceId: String)
    case registerInAppEvent(params: [[String: Any]], instanceId: String)
    case registerInboxEvent(params: [[String: Any]], instanceId: String)

    var baseURL: String {
        return "https://\(CastledConfigs.sharedInstance.location.description).castled.io/"
    }
    
    var baseURLEndPoint: String {
        return "backend/v1"
    }
    
    var endpoint: CastledEndpoint {
        switch self {
        case .registerUser(let userID, let apnsToken, let instanceId):
            return CastledEndpoint(baseURL: baseURL,
                                   baseURLEndPoint: baseURLEndPoint,
                                   path: "/push/\(instanceId)/apns/register",
                                   method: .post,
                                   parameters: ["userId": userID, "apnsToken": apnsToken])
            
        case .registerEvents(let params, let instanceId):
            return CastledEndpoint(baseURL: baseURL,
                                   baseURLEndPoint: baseURLEndPoint,
                                   path: "/push/\(instanceId)/event",
                                   method: .post,
                                   parameters: ["events": params])
            
        case .triggerCampaign:
            return CastledEndpoint(baseURL: baseURL,
                                   baseURLEndPoint: baseURLEndPoint,
                                   path: "/campaigns/119/trigger-run",
                                   method: .put,
                                   parameters: nil)
            
        case .fetchInAppNotification(let userID, let instanceId):
            return CastledEndpoint(baseURL: baseURL,
                                   baseURLEndPoint: baseURLEndPoint,
                                   path: "/inapp/\(instanceId)/ios/campaigns",
                                   method: .get,
                                   parameters: ["user": userID])
        case .fetchInInboxItems(let userID, let instanceId):
                return CastledEndpoint(baseURL: baseURL,
                                       baseURLEndPoint: baseURLEndPoint,
                                       path: "/app-inbox/\(instanceId)/ios/campaigns",
                                       method: .get,
                                       parameters: ["user": userID])
            
        case .registerInAppEvent(let params, let instanceId):
            return CastledEndpoint(baseURL: baseURL,
                                   baseURLEndPoint: baseURLEndPoint,
                                   path: "/inapp/\(instanceId)/ios/event",
                                   method: .post,
                                   parameters: ["events": params])
        case .registerInboxEvent(let params, let instanceId):
            return CastledEndpoint(baseURL: baseURL,
                                       baseURLEndPoint: baseURLEndPoint,
                                       path: "/app-inbox/\(instanceId)/ios/event",
                                       method: .post,
                                       parameters: ["events": params])
        }
    }
}


