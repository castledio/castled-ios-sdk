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
            let failedRequests = CastledStore.getAllFailedRequests()
            guard !failedRequests.isEmpty else {
                completion?()
                self?.isResending = false
                return
            }
            var processedRequests = [CastledNetworkRequest]()
            let requestsByType = Dictionary(grouping: failedRequests) { $0.type }
            /*  let prioritizedKey = CastledConstants.CastledNetworkRequestType.logoutUser.rawValue
             if let prioritizedRequests = requestsByType[prioritizedKey] {
                 if let handler = CastledRequestHelper.sharedInstance.getHandlerFor(prioritizedKey) {
                     //self?.castledSemaphore.wait()
                     self?.castledGroup.enter()
                     handler.handleRequest(requests: prioritizedRequests, onSuccess: { processed_requests in
                         print("retry success: ")
                         processedRequests.append(contentsOf: processed_requests)
                         //self?.castledSemaphore.signal()
                         self?.castledGroup.leave()

                     },
                     onError: { _ in
                         print("retry failed: \(prioritizedRequests)")
                         //self?.castledSemaphore.signal()
                         self?.castledGroup.leave()

                     })
                 }
             }*/
            requestsByType.forEach { key, requests in
                if let handler = CastledRequestHelper.sharedInstance.getHandlerFor(key) {
                    // self?.castledSemaphore.wait()
                    self?.castledGroup.enter()
                    handler.handleRequest(requests: requests, onSuccess: { processed_requests in
                        print("retry success: ")
                        processedRequests.append(contentsOf: processed_requests)
                        // self?.castledSemaphore.signal()
                        self?.castledGroup.leave()

                    },
                    onError: { _ in
                        print("retry failed: \(requests)")
                        // self?.castledSemaphore.signal()
                        self?.castledGroup.leave()

                    })
                }
            }
            self?.castledGroup.notify(queue: .main) {
                if !processedRequests.isEmpty {
                    CastledStore.deleteFailedRequests(processedRequests)
                }
                self?.isResending = false
                completion?()
            }
        }
    }
}
