//
//  CastledAPIs.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UIKit

extension Castled {
    // MARK: - HELPER METHODS FOR REPORTING EVENTS

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportInAppEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportInAppEvent(params: params, instanceId: Castled.sharedInstance.instanceId)
        Castled.sharedInstance.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report InApp Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } 
//            else {
//                CastledLog.castledLog("Report InApp success : \(params)", logLevel: CastledLogLevel.info)
//            }
            completion(response)

        })
    }

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportInboxEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportInboxEvent(params: params, instanceId: Castled.sharedInstance.instanceId)

        Castled.sharedInstance.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
//            if !response.success {
//              //  CastledLog.castledLog("Report Inbox Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
//            }

            completion(response)

        })
    }

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    static func reportCustomEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportCustomEvent(params: params)
        Castled.sharedInstance.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Custom Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)

        })
    }

    /**
     Funtion which alllows to set the user attributes..
     */
    static func reportUserAttributes(params: [String: Any], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportUserAttributes(params: params)
        Castled.sharedInstance.reportEvents(router: router, sendingParams: [params], type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Set User Attributes failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } else {
                CastledLog.castledLog("Set User Attributes succsss", logLevel: CastledLogLevel.debug)
            }
            completion(response)

        })
    }

    /**
     Funtion which alllows to report push Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    static func reportPushEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportPushEvents(params: params, instanceId: Castled.sharedInstance.instanceId)
        Castled.sharedInstance.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Push Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)

        })
    }

    static func reportDeviceInfo(deviceInfo: [String: String], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportDeviceInfo(deviceInfo: deviceInfo, userID: CastledUserDefaults.shared.userId!)
        Castled.sharedInstance.reportEvents(router: router, sendingParams: [deviceInfo], type: [String: String].self, completion: { response in

            completion(response)

        })
    }

    // MARK: - HELPER METHODS FOR FETCHING ITEMS

    /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotifications(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        if !CastledConfigs.sharedInstance.enableInApp {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: CastledUserDefaults.shared.userId ?? "", instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: [CastledInAppObject].self, endpoint: router.request)
            if response.success {
                DispatchQueue.global().async {
                    do {
                        // Create JSON Encoder
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(response.result)
                        CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledInAppsList, data)
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
        } else if !CastledConfigs.sharedInstance.enableAppInbox {
            completion(CastledResponse(error: CastledExceptionMessages.appInboxDisabled.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))

            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: [CastledInboxItem].self, endpoint: router.request)
            if response.success {
                CastledStore.refreshInboxItems(liveInboxResponse: response.result ?? [])
            }
            completion(response)
        }
    }

    // MARK: - REGISTER USER

    /**
     Function to Register user with Castled
     */
    func api_RegisterUser(userId uid: String, apnsToken token: String, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if token.isEmpty {
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: Castled.sharedInstance.instanceId)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, request: router.request)
            switch response {
                case .success(let responsJSON):
                    CastledLog.castledLog("Register User Success... \(responsJSON)", logLevel: CastledLogLevel.debug)
                    CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                    completion(CastledResponse(response: responsJSON as! [String: String]))

                case .failure(let error):
                    CastledLog.castledLog("Register User failed: \(error.localizedDescription)", logLevel: CastledLogLevel.error)
                    completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }
}

// MARK: - COMMON REPORT EVENT

extension Castled {
    private func reportEvents<T: Any>(router: CastledNetworkRouter, sendingParams: [[String: Any]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        // sendingParams used for insert/ delete from failed items array for resending purpose

        if Castled.sharedInstance.instanceId.isEmpty {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        } else if CastledUserDefaults.shared.userId == nil {
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, request: router.request)
            switch response {
                case .success(let responsJSON):
                    CastledStore.deleteAllFailedItemsFromStore(sendingParams)
                    completion(CastledResponse(response: responsJSON as! T))

                case .failure(let error):
                    CastledStore.insertAllFailedItemsToStore(sendingParams)
                    completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }
}
