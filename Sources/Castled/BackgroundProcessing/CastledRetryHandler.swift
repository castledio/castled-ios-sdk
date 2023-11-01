//
//  CastledRetryHandler.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation

class CastledRetryHandler {
    static let shared = CastledRetryHandler()
    private let castledSemaphore = DispatchSemaphore(value: 1)
    private let castledGroup = DispatchGroup()
    private var isResending = false
    private init() {}

    func retrySendingAllFailedEvents(completion: (() -> Void)? = nil) {
        if isResending {
            return
        }
        isResending = true
        CastledStore.castledStoreQueue.async { [weak self] in
            let failedItems = CastledStore.getAllFailedItemss()
            var shouldCallRegister = false
            let pushToken = CastledUserDefaults.shared.apnsToken
            if pushToken != nil && !CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) {
                shouldCallRegister = true
            }
            guard !failedItems.isEmpty || shouldCallRegister else {
                completion?()
                self?.isResending = false
                return
            }
            let requestHandlerRegistry = Dictionary(grouping: failedItems, by: { dictionary in
                dictionary[CastledConstants.CastledNetworkRequestTypeKey] as? String ?? ""
            })
            for (key, value) in requestHandlerRegistry {
                switch key {
                    case CastledConstants.CastledNetworkRequestType.pushRequest.rawValue:
                        if let savedEvents = value as? [[String: String]] {
                            self?.castledSemaphore.wait()
                            self?.castledGroup.enter()
                            Castled.registerEvents(params: savedEvents, completion: { [weak self] response in
                                defer {
                                    self?.castledSemaphore.signal()
                                    self?.castledGroup.leave()
                                }
                                if response.success {
                                    //  CastledLog.castledLog("push upload success in \(#function) response\(response.result as Any)")
                                } else {
                                    // CastledLog.castledLog("Error in updating inapp event \(#function)")
                                }
                            })
                        }
                    case CastledConstants.CastledNetworkRequestType.inappRequest.rawValue:
                        if let savedEvents = value as? [[String: String]] {
                            self?.castledSemaphore.wait()
                            self?.castledGroup.enter()
                            Castled.updateInAppEvents(params: savedEvents, completion: { [weak self] (response: CastledResponse<[String: String]>) in
                                defer {
                                    self?.castledSemaphore.signal()
                                    self?.castledGroup.leave()
                                }

                                if response.success {
                                    //    CastledLog.castledLog("inApp upload success in \(#function) response\(response.result as Any)")
                                } else {
                                    // CastledLog.castledLog("Error in updating inapp event \(#function)")
                                }
                            })
                        }
                    case CastledConstants.CastledNetworkRequestType.inboxRequest.rawValue:
                        if let savedEvents = value as? [[String: String]] {
                            self?.castledSemaphore.wait()
                            self?.castledGroup.enter()
                            Castled.updateInboxEvents(params: savedEvents, completion: { [weak self] (response: CastledResponse<[String: String]>) in
                                defer {
                                    self?.castledSemaphore.signal()
                                    self?.castledGroup.leave()
                                }

                                if response.success {
                                    //   CastledLog.castledLog("inbox upload success in \(#function) response\(response.result as Any)")
                                } else {
                                    // CastledLog.castledLog("Error in updating inapp event \(#function)")
                                }
                            })
                        }
                    case CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue:
                        if let savedEvents = value as? [[String: String]] {
                            for info in savedEvents {
                                self?.castledSemaphore.wait()
                                self?.castledGroup.enter()
                                Castled.updateDeviceInfo(deviceInfo: info) { [weak self] (response: CastledResponse<[String: String]>) in
                                    defer {
                                        self?.castledSemaphore.signal()
                                        self?.castledGroup.leave()
                                    }

                                    if response.success {
                                        //   CastledLog.castledLog("inbox upload success in \(#function) response\(response.result as Any)")
                                    } else {
                                        // CastledLog.castledLog("Error in updating inapp event \(#function)")
                                    }
                                }
                            }
                        }
                    default:
                        break
                }
            }
            if shouldCallRegister == true {
                self?.castledSemaphore.wait()
                self?.castledGroup.enter()
                Castled.sharedInstance?.api_RegisterUser(userId: CastledUserDefaults.shared.userId ?? "", apnsToken: pushToken ?? "") { _ in
                    self?.castledSemaphore.signal()
                    self?.castledGroup.leave()
                }
            }
            self?.castledGroup.notify(queue: .main) {
                self?.isResending = false
                completion?()
            }
        }
    }
}
