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
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
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
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
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
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
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
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Castled.sharedInstance?.api_Trigger_Campaign(model: [String: String].self, completion: { response in
            if response.success {
                castledLog("Campaign triggered")
            }
            completion(response)
        })
    }

    /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotification(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
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
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
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
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.userNotRegistered.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.endpoint)
            if !response.success {
                castledLog("Fetch InApps Error:❌❌❌\(response.errorMessage)")
            } else {
                Castled.sharedInstance?.refreshInboxItems(liveInboxResponse: response.result as? [CastledInboxItem] ?? [])
                // castledLog("Fetch InApps Success:✅✅✅ \(String(describing: response.result))")
            }
            completion(response)
        }
    }

    func api_RegisterUser(userId uid: String, apnsToken token: String, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            castledLog("Register User Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        if token.isEmpty {
            castledLog("Register User Error:❌❌❌\(CastledExceptionMessages.emptyToken.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }

        Task {
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                castledLog("Register User Success:✅✅✅ \(responsJSON)")
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                completion(CastledResponse(response: responsJSON as! [String: String]))

            case .failure(let error):
                castledLog("Register User Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            castledLog("Register Push Events Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
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
                castledLog("Register Push Events Error:❌❌❌\(error.localizedDescription)")
                CastledStore.insertAllFailedItemsToStore(params)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterInAppEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            castledLog("Update InApp Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .registerInAppEvent(params: params, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint: router.endpoint)
            switch response {
            case .success(let responsJSON):
                // castledLog("Update InApp Events Success:✅✅✅ \(responsJSON)")
                CastledStore.deleteAllFailedItemsFromStore(params)
                completion(CastledResponse(response: responsJSON as! T))

            case .failure(let error):
                castledLog("Update InApp Error:❌❌❌\(error.localizedDescription)")
                CastledStore.insertAllFailedItemsToStore(params)
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_RegisterInboxEvents<T: Any>(params: [[String: String]], type: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            castledLog("Update Inbox Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
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
                castledLog("Update Inbox Error:❌❌❌\(error.localizedDescription)")
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
                //  castledLog("Trigger Campaign Success:✅✅✅ \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
            case .failure(let error):
                //  castledLog("Trigger Campaign Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }

    private func api_fetch_inApp<T: Codable>(model: T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void) {
        guard let instance_id = Castled.sharedInstance?.instanceId else {
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        guard let userId = CastledUserDefaults.shared.userId else {
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.userNotRegistered.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        Task {
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: userId, instanceId: instance_id)
            let response = await CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.endpoint)
            if response.success == false {
                castledLog("Fetch InApps Error:❌❌❌\(response.errorMessage)")
            } else {
                // castledLog("Fetch InApps Success:✅✅✅ \(String(describing: response.result))")
            }
            completion(response)
        }
    }
}
