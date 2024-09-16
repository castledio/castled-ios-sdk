//
//  CastledInAppCoreDataOperations.swift
//  CastledInbox
//
//  Created by antony on 11/09/2024.
//

import CoreData
import Foundation

class CastledInAppCoreDataOperations {
    static let shared = CastledInAppCoreDataOperations()
    var isInserting = false
    private init() {}

    func refreshInappItems(inAppResponse: [CastledInAppObject], completion: @escaping () -> Void) {
        if isInserting {
            completion()
            return
        }
        isInserting = true
        CastledCoreDataOperations.shared.performBackgroundTask { context in
            // Step 1: Fetch all existing items from the database
            let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
            var existingItems: [CastledInAppMO] = []
            do {
                existingItems = try context.fetch(fetchRequest)
            } catch {
                CastledLog.castledLog("Error fetching existing items: \(error)", logLevel: .error)
            }

            // Step 2: Create a set of IDs from the response array
            let responseIDs = Set(inAppResponse.compactMap { $0.notificationID })
            // Step 3: Update or insert items from the response array
            for item in inAppResponse {
                self.updateOrInsertInAppObject(from: item, in: context)
            }

            let expiredInboxItems = existingItems.filter { !responseIDs.contains(Int($0.inapp_id)) }
            for expiredItem in expiredInboxItems {
                context.delete(expiredItem)
            }

            // Call completion on the main thread
            DispatchQueue.main.async {
                completion()
                CastledInAppCoreDataOperations.shared.isInserting = false
            }
        }
    }

    func getLiveInAppItems(withFilter: Bool = false) -> [CastledInAppObject] {
        let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        if withFilter {
            let predicate = NSPredicate(format: "inapp_attempts < inapp_maxm_attempts")
            fetchRequest.predicate = predicate
        }
        do {
            let cachedInAppObjects = try context.fetch(fetchRequest)
            let liveItems: [CastledInAppObject] = cachedInAppObjects.compactMap {
                let item = CastledInAppResponseConverter.convertToinAppItem(inapp: $0)
                return item
            }
            return liveItems
        } catch {
            return []
        }
    }

    func fetchSatisfiedInAppItemsFrom(_ notificationIDs: [Int]) -> [CastledInAppObject] {
        var inappResults: [CastledInAppObject] = []
        let semaphore = DispatchSemaphore(value: 0)
        CastledCoreDataOperations.shared.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
            let currentDate = Date()
            let predicate = NSPredicate(format: "inapp_id IN %@ AND inapp_attempts < inapp_maxm_attempts AND (%@ - inapp_last_displayed_time) > inapp_min_interval_btwd_isplays",
                                        notificationIDs,
                                        currentDate as NSDate)
            fetchRequest.predicate = predicate
            do {
                let fetchedResults = try context.fetch(fetchRequest)
                inappResults.append(contentsOf: fetchedResults.compactMap {
                    let item = CastledInAppResponseConverter.convertToinAppItem(inapp: $0)
                    return item
                })
            } catch {
                CastledLog.castledLog("Error fetching inbox items: \(error)", logLevel: .error)
            }

            semaphore.signal()
        }
        semaphore.wait()
        return inappResults
    }

    func updateInAppItemAfterDisplay(_ inappId: Int64) {
        CastledCoreDataOperations.shared.performBackgroundTask { [weak self] context in
            if let inapp = self?.getInAppFrom(messageId: inappId, in: context) {
                inapp.inapp_attempts += 1
                inapp.inapp_last_displayed_time = Date()
            }
        }
    }

    // MARK: - PRIVATE METHODS

    private func updateOrInsertInAppObject(from item: CastledInAppObject, in context: NSManagedObjectContext) {
        if let _ = getInAppFrom(messageId: Int64(item.notificationID), in: context) {
            // Update existing object,

        } else {
            // Insert new object
            guard let data = Data.dataFromEncodable(item) else { return }
            let inapp = CastledInAppMO(context: context)
            CastledInAppResponseConverter.convertToInapp(inAppItem: item, data: data, inapp: inapp)
        }
    }

    private func getInAppFrom(messageId: Int64, in context: NSManagedObjectContext) -> CastledInAppMO? {
        let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "inapp_id == %lld", messageId)
        return CastledCoreDataOperations.shared.getEntity(from: context, fetchRequest: fetchRequest)
    }
}
