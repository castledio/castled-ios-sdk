//
//  CastledAPIs.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UIKit

extension Castled {
    
    /**
     Funtion which alllows to register the User & Token with Castled.
     */
    @objc public static func registerUser(userId uid : String, apnsToken token : String?){
        
        var deviceToken = token
        if deviceToken == nil{
            deviceToken =  CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey)
        }
        else if (CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey) == nil){
            // Saving this in ud for retry mechanism, in the case of failure in the below api
            CastledUserDefaults.setString(CastledUserDefaults.kCastledAPNsTokenKey, deviceToken)
        }
        CastledUserDefaults.setString(CastledUserDefaults.kCastledUserIdKey, uid)


        if deviceToken != nil && CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) == false
        {
            Castled.sharedInstance?.api_RegisterUser(userId: uid, apnsToken: deviceToken!) {response in
                if response.success{
                    Castled.sharedInstance?.executeBGTaskWithDelay()

                }
            }
        }
        else{
            Castled.sharedInstance?.executeBGTaskWithDelay()
        }
    }
    
    /**
     Funtion which alllows to register the Events for InApp with Castled.
     */
    internal static func updateInAppEvents(params : [[String : String]],  completion: @escaping (_ response: CastledResponse<[String : String]>) -> Void){
        
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Castled.sharedInstance?.api_RegisterInAppEvents(params: params,type: [String : String].self) { response in
            if response.success{
                //handle
            }
            completion(response)
        }
    }
    
    /**
     Funtion which alllows to register Notifification events like OPENED,ACKNOWLEDGED etc.. with Castled.
     */
    internal static func registerEvents(params : [[String : String]],  completion: @escaping (_ response: CastledResponse<[String : String]>) -> Void)
    {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Castled.sharedInstance?.api_RegisterEvents(params: params,type: [String : String].self) { response in
            if response.success{
                //handle
            }
            completion(response)
        }
    }
    
    /**
     trigger Campaign api
     */
    internal static func triggerCampaign(completion: @escaping (_ response: CastledResponse<[String : String]>) -> Void){
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Castled.sharedInstance?.api_Trigger_Campaign(model: [String : String].self, completion: { response in
            if response.success{
                castledLog("Campaign triggered")
            }
            completion(response)
        })
    }
    
    /**
     Function to fetch all App Notification
     */
    internal static func fetchInAppNotification(completion: @escaping (_ response: CastledResponse<[CastledInAppObject]>) -> Void){
        
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Castled.sharedInstance?.api_fetch_inApp(model: [CastledInAppObject].self, completion: { response in
            completion((response))
        })
    }
}


extension Castled{
    
    internal func api_RegisterUser(userId uid : String, apnsToken token : String,  completion: @escaping (_ response: CastledResponse<[String : String]>) -> Void){
        
        guard let instance_id = Castled.sharedInstance?.instanceId else{
            castledLog("Register User Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        if token.count == 0 {
            castledLog("Register User Error:❌❌❌\(CastledExceptionMessages.emptyToken.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.emptyToken.rawValue, statusCode: 999))
            return
        }
        
        Task{
            let router: CastledNetworkRouter = .registerUser(userID: uid, apnsToken: token, instanceId: instance_id)
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint :router.endpoint)
            switch response {
            case .success(let responsJSON):
                castledLog("Register User Success:✅✅✅ \(responsJSON)")
                CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, true)
                completion(CastledResponse(response: responsJSON as! [String : String]))
                
            case .failure(let error):
                castledLog("Register User Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }
    
    private func api_RegisterEvents<T: Any>(params : [[String : String]],type: T.Type,  completion: @escaping (_ response: CastledResponse<T>) -> Void){

        guard let instance_id = Castled.sharedInstance?.instanceId else{
            castledLog("Register Push Events Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Task{
            
            let router: CastledNetworkRouter = .registerEvents(params: params, instanceId: instance_id)
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint :router.endpoint)
            
            switch response {
            case .success(let responsJSON):
                castledLog("Register Push Events Success:✅✅✅ \(responsJSON) params\(params)")
                var savedEvents = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingPushEvents) as? [[String:String]]) ?? [[String:String]]()
                savedEvents = savedEvents.filter { !params.contains($0) }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingPushEvents, savedEvents)
                completion(CastledResponse(response: responsJSON as! T))
                
            case .failure(let error):
                castledLog("Register Push Events Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
                
            }
        }
    }
    
    private func api_RegisterInAppEvents<T: Any>(params : [[String : String]],type: T.Type,  completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        guard let instance_id = Castled.sharedInstance?.instanceId else{
            castledLog("Update InApp Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        Task{
            let router: CastledNetworkRouter = .registerInAppEvent(params: params, instanceId: instance_id)
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint :router.endpoint)
            
            switch response {
            case .success(let responsJSON):
                // castledLog("Update InApp Events Success:✅✅✅ \(responsJSON)")
                var savedEvents = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingInAppsEvents) as? [[String:String]]) ?? [[String:String]]()
                savedEvents = savedEvents.filter { !params.contains($0) }
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingInAppsEvents, savedEvents)
                completion(CastledResponse(response: responsJSON as! T))
                
            case .failure(let error):
                castledLog("Update InApp Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
            }
        }
    }
    
    private func api_Trigger_Campaign<T: Any>(model : T.Type,completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        Task{
            let router: CastledNetworkRouter = .triggerCampaign
            let response = await  CastledNetworkLayer.shared.sendRequest(model: String.self, endpoint :router.endpoint)

            switch response {
            case .success(let responsJSON):
                castledLog("Trigger Campaign Success:✅✅✅ \(responsJSON)")
                completion(CastledResponse(response: responsJSON as! T))
                
            case .failure(let error):
                castledLog("Trigger Campaign Error:❌❌❌\(error.localizedDescription)")
                completion(CastledResponse(error: error.localizedDescription, statusCode: 999))
                
            }
        }
    }
    
    private func api_fetch_inApp<T: Codable>(model : T.Type, completion: @escaping (_ response: CastledResponse<T>) -> Void){
        
        guard let instance_id = Castled.sharedInstance?.instanceId else{
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.notInitialised.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.notInitialised.rawValue, statusCode: 999))
            return
        }
        
        guard let userId = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) else{
            castledLog("Fetch InApps Error:❌❌❌\(CastledExceptionMessages.userNotRegistered.rawValue)")
            completion(CastledResponse(error: CastledExceptionMessages.userNotRegistered.rawValue, statusCode: 999))
            return
        }
        
        Task{
            let router: CastledNetworkRouter = .fetchInAppNotification(userID: userId, instanceId: instance_id)
            let response = await  CastledNetworkLayer.shared.sendRequestFoFetch(model: model, endpoint: router.endpoint)
            if  response.success == false {
                castledLog("Fetch InApps Error:❌❌❌\(response.errorMessage)")
            }
            else{
               // castledLog("Fetch InApps Success:✅✅✅ \(String(describing: response.result))")
            }
            completion(response)
        }
    }
}

