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
    static let castledSRetryQueue = DispatchQueue(label: "com.castled.retryDbQueue")

    private init() {}

    func retrySendingAllFailedEvents(completion: (() -> Void)? = nil) {
        if isResending {
            return
        }
        isResending = true
        let failedRequests = CastledRetryCoreDataOperations.shared.getAllFailedRequests()
        if failedRequests.isEmpty {
            completion?()
            isResending = false
            return
        }
        CastledRetryHandler.castledSRetryQueue.async { [weak self] in
            var processedRequests = [CastledNetworkRequest]()
            let requestsByType = Dictionary(grouping: failedRequests) { $0.type }
            for (key, requests) in requestsByType {
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
                    CastledRetryCoreDataOperations.shared.deleteCastledNetworkRequests(processedRequests)
                }
                self?.isResending = false
                completion?()
            }
        }
    }
}
