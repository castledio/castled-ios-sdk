//
//  CastledInboxCoreDataOperations.swift
//  CastledInbox
//
//  Created by antony on 11/09/2024.
//

import CoreData
import Foundation
@_spi(CastledInternal) import Castled

class CastledInboxCoreDataOperations {
    static let shared = CastledInboxCoreDataOperations()
    var isInserting = false
    private init() {}

    func refreshInboxItems(liveInboxResponse: [CastledInboxItem]) {
        if CastledInboxCoreDataOperations.shared.isInserting {
            return
        }
        CastledInboxCoreDataOperations.shared.isInserting = true

        CastledCoreDataOperations.shared.performBackgroundTask { context in
            // Step 1: Fetch all existing items from the database
            let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
            var existingItems: [CastledInboxMO] = []
            do {
                existingItems = try context.fetch(fetchRequest)
            } catch {
                CastledLog.castledLog("Error fetching existing items: \(error)", logLevel: .error)
            }

            // Step 2: Create a set of IDs from the response array
            let responseIDs = Set(liveInboxResponse.compactMap { $0.messageId })
            var unreadCount = 0
            // Step 3: Update or insert items from the response array
            for item in liveInboxResponse {
                self.updateOrInsertInboxObject(from: item, in: context)
                if item.isRead == false {
                    unreadCount += 1
                }
            }
            let expiredInboxItems = existingItems.filter { !responseIDs.contains($0.messageId) }
            for expiredItem in expiredInboxItems {
                context.delete(expiredItem)
            }

            // Call completion on the main thread
            DispatchQueue.main.async {
                CastledInbox.sharedInstance.inboxUnreadCount = unreadCount
                CastledInboxCoreDataOperations.shared.isInserting = false
            }
        }
    }

    func resetUnreadUncountAfterCRUD() {
        CastledInbox.sharedInstance.inboxUnreadCount = self.getInboxUnreadCount()
    }

    func getInboxUnreadCount() -> Int {
        var unreadCount = 0
        let semaphore = DispatchSemaphore(value: 0)
        CastledCoreDataOperations.shared.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isRead == %@ AND isRemoved == %@", NSNumber(value: false), NSNumber(value: false))
            do {
                unreadCount = try context.count(for: fetchRequest)
            } catch {
                CastledLog.castledLog("Error fetching unread inbox items: \(error)", logLevel: .error)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return unreadCount
    }

    func getAllInboxItemsCount() -> Int {
        let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: false))
        let context = CastledCoreDataStack.shared.mainContext
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            CastledLog.castledLog("Error fetching inbox items: \(error)", logLevel: .error)
            return 0
        }
    }

    func saveInboxItemsRead(readItems: [CastledInboxItem]) {
        let inboxItemIds = readItems.map { $0.messageId }
        if !inboxItemIds.isEmpty {
            self.saveInboxIdsRead(readItems: inboxItemIds, withApiCall: false)
        }
    }

    func saveInboxIdsRead(readItems: [Int64], withApiCall: Bool = true) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "messageId IN %@", readItems)

            do {
                let messages = try context.fetch(fetchRequest)
                for message in messages {
                    message.isRead = true
                }
                try context.save()
                if withApiCall {
                    let inboxItems = Array(messages.compactMap {
                        CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                    })
                    CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems, changeReadStatus: false)
                }
                // Ensure main context reflects these changes if needed
                DispatchQueue.main.async {
                    CastledCoreDataStack.shared.saveContext()
                    self.resetUnreadUncountAfterCRUD()
                }

            } catch {
                CastledLog.castledLog("Failed to mark messages as unread: \(error)", logLevel: .error)
            }
        }
    }

    func saveInboxIdsDeleted(deletedItems: [Int64]) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "messageId IN %@", deletedItems)

            do {
                let messages = try context.fetch(fetchRequest)
                for message in messages {
                    message.isRemoved = false
                    message.isRead = true
                }

                try context.save()

                DispatchQueue.main.async {
                    CastledCoreDataStack.shared.saveContext()
                    self.resetUnreadUncountAfterCRUD()
                }

            } catch {
                CastledLog.castledLog("Failed to mark messages as deleted: \(error)", logLevel: .error)
            }
        }
    }

    func saveInboxItemAsDeletedWith(messageId: Int64) {
        // added this method in addition to the above method to make the delete transition smoother
        if let existingItem = self.getAppInboxFrom(messageId: messageId, in: CastledCoreDataStack.shared.mainContext) { existingItem.isRemoved = false
            existingItem.isRead = true
            CastledCoreDataStack.shared.saveContext()
            self.resetUnreadUncountAfterCRUD()
        }
    }

    func deleteInboxItem(inboxItem: CastledInboxItem) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform { [weak self] in
            if let existingItem = self?.getAppInboxFrom(messageId: inboxItem.messageId, in: context) {
                do {
                    context.delete(existingItem)
                    try context.save()

                    // Ensure main context reflects these changes if needed
                    DispatchQueue.main.async {
                        CastledCoreDataStack.shared.saveContext()
                        self?.resetUnreadUncountAfterCRUD()
                        CastledLog.castledLog("Inbox item deleted", logLevel: CastledLogLevel.debug)
                    }

                } catch {
                    CastledLog.castledLog("Failed to delete inbvox item: \(error)", logLevel: .error)
                }
            }
        }
    }

    func getLiveInboxItems() -> [CastledInboxItem] {
        let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: false))
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        do {
            let cachedInboxObjects = try context.fetch(fetchRequest)
            let liveInboxItems: [CastledInboxItem] = cachedInboxObjects.map {
                let inboxItem = CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                return inboxItem
            }
            return liveInboxItems
        } catch {
            return []
        }
    }

    func clearInboxItems() {
        let deleteFetch: NSFetchRequest<NSFetchRequestResult> = CastledInboxMO.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            let context = CastledCoreDataStack.shared.mainContext
            try context.execute(deleteRequest)
            CastledCoreDataStack.shared.saveContext()
        } catch {
            // error
        }
    }

    // MARK: - PRIVATE METHODS

    private func updateOrInsertInboxObject(from item: CastledInboxItem, in context: NSManagedObjectContext) {
        if let _ = getAppInboxFrom(messageId: item.messageId, in: context) {
            // Update existing object,
            //  CastledInboxResponseConverter.convertToInbox(inboxItem: item, appinbox: existingObject)

        } else {
            // Insert new object
            let newObject = CastledInboxMO(context: context)
            CastledInboxResponseConverter.convertToInbox(inboxItem: item, appinbox: newObject)
        }
    }

    private func getAppInboxFrom(messageId: Int64, in context: NSManagedObjectContext) -> CastledInboxMO? {
        let fetchRequest: NSFetchRequest<CastledInboxMO> = CastledInboxMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messageId == %lld", messageId)
        return CastledCoreDataOperations.shared.getEntity(from: context, fetchRequest: fetchRequest)
    }
}
