//
//  CastledRetryCoreDataOperations.swift
//  Castled
//
//  Created by antony on 12/09/2024.
//

import CoreData
import Foundation

class CastledRetryCoreDataOperations {
    static let shared = CastledRetryCoreDataOperations()
    private let castledRetryQueue = DispatchQueue(label: "com.caatled.retryQueue", attributes: .concurrent)
    lazy var maxmFailedItems = 5000

    private init() {}
    func enqueCastledNetworkRequest(_ request: CastledNetworkRequest) {
        print("enqueCastledNetworkRequest begin...\(Thread.isMainThread) \(Thread.current)")
        castledRetryQueue.async(flags: .barrier) {
            CastledCoreDataOperations.shared.performBackgroundTask { context in
                guard let data = Data.dataFromEncodable(request) else { return }
                let retryLog = CastledRetryRequestMO(context: context)
                retryLog.retry_id = request.requestId
                retryLog.retry_date_added = Date()
                retryLog.retry_last_attempt = Date()
                retryLog.retry_request = data
                retryLog.retry_type = request.type
                self.ensureRequestLimit(in: context)
                print("enqueCastledNetworkRequest completed...\(Thread.isMainThread) \(Thread.current)")
            }
        }
    }

    func deleteCastledNetworkRequests(_ items: [CastledNetworkRequest]) {
        return
            print("deleteCastledNetworkRequests begin...\(Thread.isMainThread) \(Thread.current)")
        castledRetryQueue.async(flags: .barrier) {
            CastledCoreDataOperations.shared.performBackgroundTask { context in
                for item in items {
                    let fetchRequest: NSFetchRequest<CastledRetryRequestMO> = CastledRetryRequestMO.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "retry_id == %@", item.requestId)
                    if let reqToDelete = CastledCoreDataOperations.shared.getEntity(from: context, fetchRequest: fetchRequest) {
                        print("deleting request with id \(item.requestId)...\(Thread.isMainThread) \(Thread.current)")
                        context.delete(reqToDelete)
                    }
                }
                print("deleteCastledNetworkRequests completed...\(Thread.isMainThread) \(Thread.current)")
            }
        }
    }

    func getAllFailedRequests() -> [CastledNetworkRequest] {
        print("getAllFailedRequests begin...\(Thread.isMainThread) \(Thread.current)")
        var failedRequests: [CastledNetworkRequest] = []
        let semaphore = DispatchSemaphore(value: 0)
        castledRetryQueue.async {
            CastledCoreDataOperations.shared.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<CastledRetryRequestMO> = CastledRetryRequestMO.fetchRequest()
                let date = Date().addingTimeInterval(-1 * 60)
                let predicate = NSPredicate(format: "retry_type != %@ OR (retry_type == %@ AND retry_date_added < %@)", CastledConstants.CastledNetworkRequestType.pushRequest.rawValue,
                                            CastledConstants.CastledNetworkRequestType.pushRequest.rawValue,
                                            date as NSDate)

                fetchRequest.predicate = predicate // Adding this timeframe to handle the race condition that occurs (avoid duplicate reporting) from the push extension and the click events that happen immediately after receiving it.

                do {
                    let failedRequestMO = try context.fetch(fetchRequest)
                    failedRequests = failedRequestMO.compactMap { $0.retry_request?.encodableFromData(to: CastledNetworkRequest.self) }
                } catch {
                    print("Error fetching failed network requests: \(error)")
                }

                semaphore.signal()
            }
        }

        semaphore.wait()
        print("getAllFailedRequests completed... with count \(failedRequests.count) \(Thread.isMainThread) \(Thread.current)")

        return failedRequests
    }

    private func ensureRequestLimit(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CastledRetryRequestMO> = CastledRetryRequestMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "retry_date_added", ascending: true)]
        do {
            let allRequests = try context.fetch(fetchRequest)
            print("curerent retry request items count is \(allRequests.count) \(Thread.isMainThread) \(Thread.current)")
            if allRequests.count > maxmFailedItems {
                print("need to delete some items ...\(Thread.isMainThread) \(Thread.current)")
                let requestsToDelete = allRequests.prefix(allRequests.count - maxmFailedItems)
                for request in requestsToDelete {
                    print("deleting ...\(request.retry_id) \(Thread.isMainThread) \(Thread.current)")
                    context.delete(request)
                }
            }
        } catch {
            print("Error managing request limit: \(error)")
        }
    }
}
