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
            let failedRequests = CastledStore.getAllFailedRequests().filter { $0.type == CastledConstants.CastledNetworkRequestType.pushRequest.rawValue ? $0.insertTime < (Date().timeIntervalSince1970 - 2 * 60) : true }
            // Adding this timeframe to handle the race condition that occurs (avoid duplicate reporting) from the push extension and the click events that happen immediately after receiving it.

            guard !failedRequests.isEmpty else {
                completion?()
                self?.isResending = false
                return
            }
            var processedRequests = [CastledNetworkRequest]()
            let requestsByType = Dictionary(grouping: failedRequests) { $0.type }
            requestsByType.forEach { key, requests in
                if let handler = CastledRequestHelper.sharedInstance.getHandlerFor(key) {
                    self?.castledSemaphore.wait()
                    self?.castledGroup.enter()
                    handler.handleRequest(requests: requests, onSuccess: { processed_requests in
                        processedRequests.append(contentsOf: processed_requests)
                        self?.castledSemaphore.signal()
                        self?.castledGroup.leave()
                    },
                    onError: { _ in
                        self?.castledSemaphore.signal()
                        self?.castledGroup.leave()

                    })
                }
            }
            self?.castledGroup.notify(queue: .main) {
                if !processedRequests.isEmpty {
                    CastledStore.deleteCastledNetworkRequests(processedRequests)
                }
                self?.isResending = false
                completion?()
            }
        }
    }
}
