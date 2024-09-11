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
        print("inapp insertion about to begin....\(inAppResponse.count)")
        if CastledInAppCoreDataOperations.shared.isInserting {
            completion()
            return
        }
        CastledInAppCoreDataOperations.shared.isInserting = true

        CastledCoreDataOperations.shared.performBackgroundTask { context in
            // Step 1: Fetch all existing items from the database
            let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
            var existingItems: [CastledInAppMO] = []
            do {
                existingItems = try context.fetch(fetchRequest)
            } catch {
                print("Error fetching existing items: \(error)")
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
                print("inapp insertion completed....")
            }
        }
    }

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

    func getLiveInAppItems() -> [CastledInAppObject] {
        let fetchRequest: NSFetchRequest<CastledInAppMO> = CastledInAppMO.fetchRequest()
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        do {
            let cachedInAppObjects = try context.fetch(fetchRequest)
            let liveItems: [CastledInAppObject] = cachedInAppObjects.compactMap {
                let item = CastledInAppResponseConverter.convertToinAppItem(inapp: $0)
                return item
            }
            return liveItems
        } catch {
            print("Error fetching unread items: \(error)")
            return []
        }
    }
}
