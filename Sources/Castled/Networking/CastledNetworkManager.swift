//
//  CastledNetworkManager.swift
//  Castled
//
//  Created by antony on 05/02/2024.
//

import Foundation

class CastledNetworkManager {
    private static let shared = CastledNetworkManager()

    private init() {}

    // MARK: - HELPER METHODS FOR REPORTING EVENTS

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportInAppEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportInAppEvent(params: params, instanceId: Castled.sharedInstance.instanceId)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report InApp Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)
        })
    }

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportInboxEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportInboxEvent(params: params, instanceId: Castled.sharedInstance.instanceId)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            completion(response)
        })
    }

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportCustomEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportCustomEvent(params: params)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Custom Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)
        })
    }

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportUserEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportUserEvent(params: params.last!)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            completion(response)
        })
    }

    /**
     Funtion which alllows to report the Sessions with Castled.
     */
    static func reportSessions(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportSession(params: params)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Session tracking failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } else {
                CastledLog.castledLog("Session tracking sucess", logLevel: CastledLogLevel.debug)
            }
            completion(response)
        })
    }

    /**
     Funtion which alllows to set the user attributes..
     */
    static func reportUserAttributes(params: [String: Any], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportUserAttributes(params: params)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: [params], type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Set User Attributes failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } else {
                CastledLog.castledLog("Set User Attributes success", logLevel: CastledLogLevel.debug)
            }
            completion(response)
        })
    }

    /**
     Funtion which alllows to report push Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    static func reportPushEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportPushEvents(params: params, instanceId: Castled.sharedInstance.instanceId)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Push Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)
        })
    }

    static func reportDeviceInfo(deviceInfo: [String: String], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportDeviceInfo(deviceInfo: deviceInfo, userID: CastledUserDefaults.shared.userId!)
        CastledNetworkManager.shared.reportEvents(router: router, sendingParams: [deviceInfo], type: [String: String].self, completion: { response in
            completion(response)
        })
    }

    // MARK: - HELPER METHODS FOR FETCHING ITEMS

    /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotifications(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        if !CastledConfigsUtils.enableInApp {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: CastledUserDefaults.shared.userId ?? "", instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequest(model: [CastledInAppObject].self, request: router.request, isFetch: true)
            if response.success {
                DispatchQueue.global().async {
                    do {
                        // Create JSON Encoder
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(response.result)
                        CastledStore.writeToFile(data: data, filename: CastledUserDefaults.kCastledInAppsList)
                        CastledInApps.sharedInstance.prefetchInApps()

                    } catch {
                        // CastledLog.castledLog("Unable to Encode response (\(error))", logLevel: CastledLogLevel.error)
                    }
                }
            }

            completion(response)
        }
    }

    /**
     Function to fetch all Inbox Items
     */
    static func fetchInboxItems(completion: @escaping (_ response: CastledResponse<[CastledInboxItem]>) -> Void) {
        if Castled.sharedInstance.instanceId.isEmpty {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))

            return
        } else if !CastledConfigsUtils.enableAppInbox {
            completion(CastledResponse(error: CastledExceptionMessages.appInboxDisabled.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))

            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequest(model: [CastledInboxItem].self, request: router.request, isFetch: true)
            if response.success {
                CastledStore.refreshInboxItems(liveInboxResponse: response.result ?? [])
            }
            completion(response)
        }
    }

    // MARK: - USER LIFE CYCLE

    /**
     Function to Register user with Castled
     */
    static func api_RegisterUser(userId uid: String, apnsToken token: String, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if token.isEmpty {
            CastledLog.castledLog("Register User [\(uid)] failed: \(CastledExceptionMessages.emptyToken.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequest(model: [String: String].self, request: router.request)
            switch response.success {
                case true:
                    CastledLog.castledLog("'\(uid)' registered successfully...", logLevel: CastledLogLevel.debug)
                    CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                    completion(CastledResponse(response: response.result!))

                case false:
                    CastledLog.castledLog("Register User '\(uid)' failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
                    completion(CastledResponse(error: response.errorMessage, statusCode: 999))
            }
        }
    }

    static func logoutUser(params: [String: Any]) {
        Task {
            let router: CastledNetworkRouter = .logoutUser(params: params, instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequest(model: [String: String].self, request: router.request)
            switch response.success {
                case true:
                    CastledStore.deleteAllFailedItemsFromStore([params])

                case false:
                    CastledStore.insertAllFailedItemsToStore([params])
            }
        }
    }
}

// MARK: - COMMON REPORT EVENT

extension CastledNetworkManager {
    private func reportEvents<T: Any>(router: CastledNetworkRouter, sendingParams: [[String: Any]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        if Castled.sharedInstance.instanceId.isEmpty {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        } else if CastledUserDefaults.shared.userId == nil {
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let api_response = await CastledNetworkLayer.shared.sendRequest(model: [String: String].self, request: router.request)
            switch api_response.success {
                case true:
                    print("✅✅✅✅✅ \(router.request.path)\(sendingParams)")
                    CastledStore.deleteAllFailedItemsFromStore(sendingParams)
                    completion(api_response as? CastledResponse<T> ?? CastledResponse(response: ["success": "1"] as! T))

                case false:
                    print("❌❌❌❌❌❌ \(router.request.path)\(api_response.errorMessage)")
                    CastledStore.insertAllFailedItemsToStore(sendingParams)
                    completion(api_response as? CastledResponse<T> ?? CastledResponse(error: api_response.errorMessage, statusCode: 999))
            }
        }
    }
}
