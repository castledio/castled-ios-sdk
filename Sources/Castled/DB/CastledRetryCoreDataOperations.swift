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
            }
        }
    }

    func deleteCastledNetworkRequests(_ items: [CastledNetworkRequest]) {
        castledRetryQueue.async(flags: .barrier) {
            CastledCoreDataOperations.shared.performBackgroundTask { context in
                for item in items {
                    let fetchRequest: NSFetchRequest<CastledRetryRequestMO> = CastledRetryRequestMO.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "retry_id == %@", item.requestId)
                    if let reqToDelete = CastledCoreDataOperations.shared.getEntity(from: context, fetchRequest: fetchRequest) {
                        context.delete(reqToDelete)
                    }
                }
            }
        }
    }

    func getAllFailedRequests() -> [CastledNetworkRequest] {
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
                    CastledLog.castledLog("Error fetching failed network requests: \(error)", logLevel: .error)
                }

                semaphore.signal()
            }
        }

        semaphore.wait()
        return failedRequests
    }

    private func ensureRequestLimit(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CastledRetryRequestMO> = CastledRetryRequestMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "retry_date_added", ascending: true)]
        do {
            let allRequests = try context.fetch(fetchRequest)
            if allRequests.count > maxmFailedItems {
                let requestsToDelete = allRequests.prefix(allRequests.count - maxmFailedItems)
                for request in requestsToDelete {
                    context.delete(request)
                }
            }
        } catch {
            CastledLog.castledLog("Error managing request limit: \(error)", logLevel: .error)
        }
    }
}
