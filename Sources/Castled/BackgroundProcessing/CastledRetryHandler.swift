//
//  CastledRetryHandler.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation

internal class CastledRetryHandler {
    static let shared = CastledRetryHandler()
    private let castledDispatchQueue = DispatchQueue(label: "com.castled.retryhandler", qos: .background)
    private let castledSemaphore = DispatchSemaphore(value: 1)
    private let castledGroup = DispatchGroup()
    
    private init() {}
    
    func retrySendingAllFailedEvents(completion: (() -> Void)? = nil) {
        castledDispatchQueue.async {[weak self] in
            
            let savedInAppEvents = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingInAppsEvents) as? [[String:String]]) ?? [[String:String]]()
            
            let savedPushEvents = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingPushEvents) as? [[String:String]]) ?? [[String:String]]()
            
            guard savedInAppEvents.count > 0 || savedPushEvents.count > 0  else {
                completion?()
                return
            }
            if (savedInAppEvents.count > 0){
                
                self?.castledSemaphore.wait()
                self?.castledGroup.enter()
                
                Castled.updateInAppEvents(params: savedInAppEvents, completion: { [weak self] (response: CastledResponse<[String : String]>) in
                    defer {
                        self?.castledSemaphore.signal()
                        self?.castledGroup.leave()
                    }
                    
                    if response.success {
                        // castledLog("inApp upload success in \(#function) response\(response.result as Any)")
                    } else {
                        // castledLog("Error in updating inapp event \(#function)")
                    }
                })
            }
            
            if (savedPushEvents.count > 0){
                
                self?.castledSemaphore.wait()
                self?.castledGroup.enter()
                
                Castled.registerEvents(params: savedPushEvents, completion: { [weak self] response in
                    defer {
                        self?.castledSemaphore.signal()
                        self?.castledGroup.leave()
                    }
                    
                    if response.success {
                        // castledLog("inApp upload success in \(#function) response\(response.result as Any)")
                    } else {
                        // castledLog("Error in updating inapp event \(#function)")
                    }
                })
            }
            
            
            self?.castledGroup.notify(queue: .main) {
                completion?()
            }
        }
    }
}

