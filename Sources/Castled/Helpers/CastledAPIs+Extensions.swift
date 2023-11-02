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
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Report InApp Events failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        let router: CastledNetworkRouter = .reportInAppEvent(params: params, instanceId: instance_id)
        Castled.sharedInstance?.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
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
        if Castled.sharedInstance == nil {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        let router: CastledNetworkRouter = .reportInboxEvent(params: params, instanceId: instance_id)

        Castled.sharedInstance?.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
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
        if Castled.sharedInstance == nil {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard (Castled.sharedInstance?.instanceId) != nil else {
            CastledLog.castledLog("Report Custom Events failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }

        let router: CastledNetworkRouter = .reportCustomEvent(params: params)
        Castled.sharedInstance?.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Custom Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)

        })
    }

    static func reportUserAttributes(params: [String: Any], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if Castled.sharedInstance == nil {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard (Castled.sharedInstance?.instanceId) != nil else {
            CastledLog.castledLog("Set User Attributes failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }

        let router: CastledNetworkRouter = .reportUserAttributes(params: params)

        Castled.sharedInstance?.reportEvents(router: router, sendingParams: [params], type: [String: String].self, completion: { response in
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
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Report Push Events failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Report Push Events failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        let router: CastledNetworkRouter = .reportPushEvents(params: params, instanceId: instance_id)
        Castled.sharedInstance?.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
            if !response.success {
                CastledLog.castledLog("Report Push Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            }
            completion(response)

        })
    }

    static func reportDeviceInfo(deviceInfo: [String: String], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        let router: CastledNetworkRouter = .reportDeviceInfo(deviceInfo: deviceInfo, userID: CastledUserDefaults.shared.userId!)
        Castled.sharedInstance?.reportEvents(router: router, sendingParams: [deviceInfo], type: [String: String].self, completion: { response in

            completion(response)

        })
    }

    // MARK: - HELPER METHODS FOR FETCHING ITEMS

    static func fetchInAppNotifications(completion: @escaping () -> Void) {
        if !CastledConfigs.sharedInstance.enableInApp {
            completion()
            return
        }
        CastledInApps.sharedInstance.fetchInAppNotificationWithCompletion {
            completion()
        }
    }

    /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotification(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Fetch inapps failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_fetch_inApp(model: [CastledInAppObject].self, completion: { response in
            completion(response)
        })
    }

    /**
     Function to fetch all Inbox Items
     */
    static func fetchInboxItems(completion: @escaping (_ response: CastledResponse<[CastledInboxItem]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Fetch inbox items failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        if !CastledConfigs.sharedInstance.enableAppInbox {
            CastledLog.castledLog("Fetch inbox items failed: \(CastledExceptionMessages.appInboxDisabled.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.appInboxDisabled.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_fetch_inBox(model: [CastledInboxItem].self, completion: { response in
            completion(response)
        })
    }
}

// MARK: - PRIVATE METHODS

extension Castled {
    private func reportEvents<T: Any>(router: CastledNetworkRouter, sendingParams: [[String: Any]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        // sendingParams used for insert/ delete from failed items array for resending purpose

        guard (Castled.sharedInstance?.instanceId) != nil else {
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
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

    private func api_fetch_inBox<T: Codable>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Fetch inbox items failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Fetch inbox items failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.request)
            if !response.success {
                CastledLog.castledLog("Fetch inbox items failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
            } else {
                CastledStore.refreshInboxItems(liveInboxResponse: response.result as? [CastledInboxItem] ?? [])
                // CastledLog.castledLog("Fetch InApps Success \(String(describing: response.result))")
            }
            completion(response)
        }
    }

    func api_RegisterUser(userId uid: String, apnsToken token: String, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Register User failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        if token.isEmpty {
            CastledLog.castledLog("Register User failed: \(CastledExceptionMessages.emptyToken.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, request: router.request)
            switch response {
            case .success(let responsJSON):
                CastledLog.castledLog("Register User Success \(responsJSON)", logLevel: CastledLogLevel.debug)
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                completion(CastledResponse(response: responsJSON as! [String: String]))

            case .failure(let error):
                CastledLog.castledLog("Register User failed: \(error.localizedDescription)", logLevel: CastledLogLevel.error)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_fetch_inApp<T: Codable>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Fetch InApps failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Fetch InApps failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.request)
//            if response.success == false {
//                CastledLog.castledLog("Fetch InApps\(response.errorMessage)", logLevel: CastledLogLevel.debug)
//            } else {
//                // CastledLog.castledLog("Fetch InApps Success \(String(describing: response.result))")
//            }
            completion(response)
        }
    }
}
