//
//  CastledAPIs.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UIKit

extension Castled {
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
     Funtion which alllows to register the Events for InApp with Castled.
     */
    static func updateInAppEvents(params: [[String: String]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Update InApp Events\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_RegisterInAppEvents(params: params, type: [String: String].self) { response in
            if response.success {
                // handle
            }
            completion(response)
        }
    }

    /**
     Funtion which alllows to register the Events for InApp with Castled.
     */
    static func updateInboxEvents(params: [[String: String]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Update Inbox Events\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_RegisterInboxEvents(params: params, type: [String: String].self) { response in
            if response.success {
                // handle
            }
            completion(response)
        }
    }

    /**
     Funtion which alllows to register Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    static func registerEvents(params: [[String: String]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_RegisterEvents(params: params, type: [String: String].self) { response in
            if response.success {
                // handle
            }
            completion(response)
        }
    }

    /**
     trigger Campaign api
     */
    static func triggerCampaign(completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_Trigger_Campaign(model: [String: String].self, completion: { response in
            if response.success {
                CastledLog.castledLog("Campaign triggered", logLevel: CastledLogLevel.debug)
            }
            completion(response)
        })
    }

    /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotification(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        if Castled.sharedInstance == nil {
            CastledLog.castledLog("Fetch inapps \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
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
            CastledLog.castledLog("Fetch inbox items \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        if !CastledConfigs.sharedInstance.enableAppInbox {
            completion(CastledResponse(error: CastledExceptionMessages.appInboxDisabled.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_fetch_inBox(model: [CastledInboxItem].self, completion: { response in
            completion(response)
        })
    }
}

extension Castled {
    private func api_fetch_inBox<T: Codable>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Fetch InApps\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Fetch InApps \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.endpoint)
            if !response.success {
            } else {
                Castled.sharedInstance?.refreshInboxItems(liveInboxResponse: response.result as? [CastledInboxItem] ?? [])
                // CastledLog.castledLog("Fetch InApps Success \(String(describing: response.result))")
            }
            completion(response)
        }
    }

    func api_RegisterUser(userId uid: String, apnsToken token: String, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Register User\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        if token.isEmpty {
            CastledLog.castledLog("Register User\(CastledExceptionMessages.emptyToken.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                CastledLog.castledLog("Register User Success \(responsJSON)", logLevel: CastledLogLevel.debug)
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                completion(CastledResponse(response: responsJSON as! [String: String]))

            case .failure(let error):
                CastledLog.castledLog("Register User\(error.localizedDescription)", logLevel: CastledLogLevel.error)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Register Push Events\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerEvents(params: params, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                CastledStore.deleteAllFailedItemsFromStore(params)
                completion(CastledResponse(response: responsJSON as! T))

            case .failure(let error):
                CastledLog.castledLog("Register Push Events\(error.localizedDescription)", logLevel: CastledLogLevel.error)
                CastledStore.insertAllFailedItemsToStore(params)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterInAppEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Update InApp\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .registerInAppEvent(params: params, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                // CastledLog.castledLog("Update InApp Events Success ", logLevel: CastledLogLevel.debug)
                CastledStore.deleteAllFailedItemsFromStore(params)
                completion(CastledResponse(response: responsJSON as! T))

            case .failure(let error):
                //  CastledLog.castledLog("Update InApp\(error.localizedDescription)", logLevel: CastledLogLevel.error)
                CastledStore.insertAllFailedItemsToStore(params)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterInboxEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Update Inbox event\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerInboxEvent(params: params, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)

            switch response {
            case .success(let responsJSON):
                CastledStore.deleteAllFailedItemsFromStore(params)
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                CastledStore.insertAllFailedItemsToStore(params)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_Trigger_Campaign<T: Any>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        Task {
            let router: CastledNetworkRouter = .triggerCampaign
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                //  CastledLog.castledLog("Trigger Campaign Success \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                //  CastledLog.castledLog("Trigger Campaign\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_fetch_inApp<T: Codable>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            CastledLog.castledLog("Fetch InApps\(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            CastledLog.castledLog("Fetch InApps\(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.debug)
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.endpoint)
//            if response.success == false {
//                CastledLog.castledLog("Fetch InApps\(response.errorMessage)", logLevel: CastledLogLevel.debug)
//            } else {
//                // CastledLog.castledLog("Fetch InApps Success \(String(describing: response.result))")
//            }
            completion(response)
        }
    }
}
