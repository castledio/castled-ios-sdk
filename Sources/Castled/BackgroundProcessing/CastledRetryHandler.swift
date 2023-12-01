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
            if pushToken != nil && CastledUserDefaults.shared.userId != nil && !CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) {
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
                        let savedEvents = value
                        self?.castledSemaphore.wait()
                        self?.castledGroup.enter()
                        Castled.reportPushEvents(params: savedEvents, completion: { [weak self] _ in
                            self?.castledSemaphore.signal()
                            self?.castledGroup.leave()
                        })

                    case CastledConstants.CastledNetworkRequestType.inappRequest.rawValue:
                        let savedEvents = value
                        self?.castledSemaphore.wait()
                        self?.castledGroup.enter()
                        Castled.reportInAppEvents(params: savedEvents, completion: { [weak self] (_: CastledResponse<[String: String]>) in
                            self?.castledSemaphore.signal()
                            self?.castledGroup.leave()

                        })
                    case CastledConstants.CastledNetworkRequestType.inboxRequest.rawValue:
                        let savedEvents = value
                        self?.castledSemaphore.wait()
                        self?.castledGroup.enter()
                        Castled.reportInboxEvents(params: savedEvents, completion: { [weak self] (_: CastledResponse<[String: String]>) in
                            self?.castledSemaphore.signal()
                            self?.castledGroup.leave()
                        })

                    case CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue:
                        if let savedEvents = value as? [[String: String]] {
                            for info in savedEvents {
                                self?.castledSemaphore.wait()
                                self?.castledGroup.enter()
                                Castled.reportDeviceInfo(deviceInfo: info) { [weak self] (_: CastledResponse<[String: String]>) in
                                    self?.castledSemaphore.signal()
                                    self?.castledGroup.leave()
                                }
                            }
                        }
                    case CastledConstants.CastledNetworkRequestType.productEventRequest.rawValue:
                        let savedEvents = value
                        self?.castledSemaphore.wait()
                        self?.castledGroup.enter()
                        Castled.reportCustomEvents(params: savedEvents, completion: { [weak self] (_: CastledResponse<[String: String]>) in
                            self?.castledSemaphore.signal()
                            self?.castledGroup.leave()
                        })
                    case CastledConstants.CastledNetworkRequestType.userEventRequest.rawValue:
                        let savedEvents = value
                        self?.castledSemaphore.wait()
                        self?.castledGroup.enter()
                        Castled.reportUserEvents(params: savedEvents, completion: { [weak self] (_: CastledResponse<[String: String]>) in
                            self?.castledSemaphore.signal()
                            self?.castledGroup.leave()
                        })

                    case CastledConstants.CastledNetworkRequestType.userProfileRequest.rawValue:
                        let savedEvents = value
                        for info in savedEvents {
                            self?.castledSemaphore.wait()
                            self?.castledGroup.enter()
                            Castled.reportUserAttributes(params: info) { [weak self] (_: CastledResponse<[String: String]>) in
                                self?.castledSemaphore.signal()
                                self?.castledGroup.leave()
                            }
                        }

                    default:
                        break
                }
            }
            if shouldCallRegister == true {
                self?.castledSemaphore.wait()
                self?.castledGroup.enter()
                Castled.sharedInstance.api_RegisterUser(userId: CastledUserDefaults.shared.userId ?? "", apnsToken: pushToken ?? "") { _ in
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
