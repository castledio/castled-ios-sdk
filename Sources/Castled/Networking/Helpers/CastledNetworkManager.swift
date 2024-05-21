//
//  CastledNetworkManager.swift
//  Castled
//
//  Created by antony on 05/02/2024.
//

import Foundation
import UIKit

class CastledNetworkManager {
    private static let shared = CastledNetworkManager()

    private init() {}

    // MARK: - HELPER METHODS FOR REPORTING EVENTS

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    /*  static func reportInAppEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let router: CastledNetworkRouter = .reportInAppEvent(params: params, instanceId: Castled.sharedInstance.instanceId)
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
             if !response.success {
                 CastledLog.castledLog("Report InApp Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
             }
             completion(response)
         })
     }*/

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    /*  static func reportCustomEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let router: CastledNetworkRouter = .reportCustomEvent(params: params)
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
             if !response.success {
                 CastledLog.castledLog("Report Custom Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
             }
             completion(response)
         })
     }*/

    /**
     Funtion which alllows to report the Events for InApp with Castled.
     */
    /* static func reportUserEvents(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let router: CastledNetworkRouter = .reportUserEvent(params: params.last!)
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
             completion(response)
         })
     }*/

    /**
     Funtion which alllows to report the Sessions with Castled.
     */
    /*  static func reportSessions(params: [[String: Any]], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
             let router: CastledNetworkRouter = .reportSession(params: params)
             CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
     //            if !response.success {
     //                CastledLog.castledLog("Session tracking failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
     //            } else {
     //                CastledLog.castledLog("Session tracking sucess", logLevel: CastledLogLevel.debug)
     //            }
                 completion(response)
             })
         }*/

    /**
     Funtion which alllows to set the user attributes..
     */
    /*  static func reportUserAttributes(params: [String: Any], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let router: CastledNetworkRouter = .reportUserAttributes(params: params)
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: [params], type: [String: String].self, completion: { response in
             if !response.success {
                 CastledLog.castledLog("Set User Attributes failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
             } else {
                 CastledLog.castledLog("Set User Attributes success", logLevel: CastledLogLevel.debug)
             }
             completion(response)
         })
     }*/

    /**
     Funtion which alllows to report push Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    /*    static func reportPushEvents(params: [[String: Any]], isRetry: Bool? = false, completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let application = UIApplication.shared
         var backgroundTask: UIBackgroundTaskIdentifier?
         backgroundTask = application.beginBackgroundTask(withName: "com.castled.pushsending") {
             application.endBackgroundTask(backgroundTask!)
             backgroundTask = .invalid
         }
         let router: CastledNetworkRouter = .reportPushEvents(params: params, instanceId: Castled.sharedInstance.instanceId)
         if isRetry ?? false == false {
             // saving this for push to ensure that data won't be lost in case of a weak network connection. This will mainly occur when the action is rich landing or other apps by deeplinking
             CastledStore.insertAllSendingItemsToStore(params)
         }
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: params, type: [String: String].self, completion: { response in
             if !response.success {
                 CastledLog.castledLog("Report Push Events failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
             }
             completion(response)
             if let backgroundTask = backgroundTask {
                 application.endBackgroundTask(backgroundTask)
             }
         })
     }
     */
    /*
     static func reportDeviceInfo(deviceInfo: [String: String], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         let router: CastledNetworkRouter = .reportDeviceInfo(deviceInfo: deviceInfo, userID: CastledUserDefaults.shared.userId!)
         CastledNetworkManager.shared.reportEvents(router: router, sendingParams: [deviceInfo], type: [String: String].self, completion: { response in
             completion(response)
         })
     }
     */

    // MARK: - HELPER METHODS FOR FETCHING ITEMS

    /*  /**
     Function to fetch all App Notification
     */
    static func fetchInAppNotifications(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void) {
        completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
        //FIXME: do the needful

         if !CastledConfigsUtils.configs.enableInApp {
             completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
             return
         }
         Task {
             let router: CastledNetworkRouter = .fetchInAppNotification(userID: CastledUserDefaults.shared.userId ?? "", instanceId: Castled.sharedInstance.instanceId)
             let response = await CastledNetworkLayer.shared.sendRequest(model: [CastledInAppObject].self, request: router.request, shouldDecodeResponse: true)
             if response.success {
                 DispatchQueue.global().async {
                     let encoder = JSONEncoder()
                     if let data = try? encoder.encode(response.result) {
                         CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledInAppsList, data)
                         CastledInApps.sharedInstance.prefetchInApps()
                     }
                 }
             }

             completion(response)
         }
    }
     */
    /*     //FIXME: do the needful
       /**
          Function to fetch all Inbox Items
          */
         static func fetchInboxItems(completion: @escaping (_ response: CastledResponse<[CastledInboxItemOld]>) -> Void) {
             completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
             return;
             if Castled.sharedInstance.instanceId.isEmpty {
                 completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))

                 return
             } else if !CastledConfigsUtils.configs.enableAppInbox {
                 completion(CastledResponse(error: CastledExceptionMessages.appInboxDisabled.rawValue, statusCode: 999))
                 return
             }
             guard let userId = CastledUserDefaults.shared.userId else {
                 completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))

                 return
             }
     //        Task {
     //            let router: CastledNetworkRouter = .fetchInInboxItems(userID: userId, instanceId: Castled.sharedInstance.instanceId)
     //            let response = await CastledNetworkLayer.shared.sendRequest(model: [CastledInboxItemOld].self, request: router.request, isFetch: true)
     //            if response.success {
     //                CastledStore.refreshInboxItems(liveInboxResponse: response.result ?? [])
     //            }
     //            completion(response)
     //        }
         }
     */

    // MARK: - USER LIFE CYCLE

    /**
     Function to Register user with Castled
     */
    /* static func registerUser(params: [String: Any], completion: @escaping (_ response: CastledResponse<[String: String]>) -> Void) {
         Task {
             let router: CastledNetworkRouter = .registerUser(params: params, instanceId: Castled.sharedInstance.instanceId)
             let response = await CastledNetworkLayer.shared.sendRequest(model: [String: String].self, request: router.request)
             switch response.success {
                 case true:
                     if let uid = params[CastledConstants.PushNotification.userId] as? String {
                         CastledLog.castledLog("'\(uid)' registered successfully...", logLevel: CastledLogLevel.debug)
                     }
                     CastledStore.deleteAllFailedItemsFromStore([params])
                     completion(CastledResponse(response: response.result!))

                 case false:
                     if let uid = params[CastledConstants.PushNotification.userId] as? String {
                         CastledLog.castledLog("Register User '\(uid)' failed: \(response.errorMessage)", logLevel: CastledLogLevel.error)
                     }
                     CastledStore.insertAllSendingItemsToStore([params])
                     completion(CastledResponse(error: response.errorMessage, statusCode: 999))
             }
         }
     }*/

    /* static func logoutUser(params: [String: Any]) {
         Task {
             let router: CastledNetworkRouter = .logoutUser(params: params, instanceId: Castled.sharedInstance.instanceId)
             let response = await CastledNetworkLayer.shared.sendRequest(model: [String: String].self, request: router.request)
             switch response.success {
                 case true:
                     CastledStore.deleteAllFailedItemsFromStore([params])

                 case false:
                     CastledStore.insertAllSendingItemsToStore([params])
             }
         }
     }*/
}

// MARK: - COMMON REPORT EVENT

/* extension CastledNetworkManager {
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
                     CastledStore.deleteAllFailedItemsFromStore(sendingParams)
                     completion(api_response as? CastledResponse<T> ?? CastledResponse(response: ["success": "1"] as! T))

                 case false:
                     CastledStore.insertAllSendingItemsToStore(sendingParams)
                     completion(api_response as? CastledResponse<T> ?? CastledResponse(error: api_response.errorMessage, statusCode: 999))
             }
         }
     }
 } */
