//
//  CastledCoreDataOperations.swift
//  CastledInbox
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation
@_spi(CastledInternal) import Castled

class CastledCoreDataOperations {
    static let shared = CastledCoreDataOperations()
    var isInserting = false
    private init() {}

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                    CastledCoreDataStack.shared.saveContext()
                    print("after insertion total inbox count \(self.getAllInboxItemsCount())")
                    CastledCoreDataOperations.shared.isInserting = false

                } catch {
                    // Handle the error appropriately in your application
                    print("Error saving background context: \(error)")
                    CastledCoreDataOperations.shared.isInserting = false
                }
            } else {
                print("context.hasChanges elseeeee \(self.getAllInboxItemsCount())")
                CastledCoreDataOperations.shared.isInserting = false
            }
        }
    }

    func refreshInboxItems(liveInboxResponse: [CastledInboxItem]) {
        if CastledCoreDataOperations.shared.isInserting {
            return
        }
        CastledCoreDataOperations.shared.isInserting = true

        self.performBackgroundTask { context in
            // Step 1: Fetch all existing items from the database
            let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
            var existingItems: [CastledAppInbox] = []
            do {
                existingItems = try context.fetch(fetchRequest)
                print("existingItems \(existingItems.count)")
            } catch {
                print("Error fetching existing items: \(error)")
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
//                self.resetUnreadUncountAfterCRUD()

                CastledInbox.sharedInstance.inboxUnreadCount = unreadCount
            }
        }
    }

    func resetUnreadUncountAfterCRUD() {
        CastledInbox.sharedInstance.inboxUnreadCount = self.getInboxUnreadCount()
    }

    func getInboxUnreadCount() -> Int {
        let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRead == %@ AND isRemoved == %@", NSNumber(value: false), NSNumber(value: false))
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching unread items: \(error)")
            return 0
        }
    }

    func getAllInboxItemsCount() -> Int {
        let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRemoved == %@", NSNumber(value: false))
        let context = CastledCoreDataStack.shared.mainContext
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching unread items: \(error)")
            return 0
        }
    }

    private func updateOrInsertInboxObject(from item: CastledInboxItem, in context: NSManagedObjectContext) {
        if let existingObject = getAppInboxFrom(messageId: item.messageId, in: context) {
            // Update existing object
            CastledInboxResponseConverter.convertToInbox(inboxItem: item, appinbox: existingObject)

        } else {
            // Insert new object
            let newObject = CastledAppInbox(context: context)
            CastledInboxResponseConverter.convertToInbox(inboxItem: item, appinbox: newObject)
        }
    }

    func getAppInboxFrom(messageId: Int64, in context: NSManagedObjectContext) -> CastledAppInbox? {
        let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "messageId == %lld", messageId)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
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
            let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
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
                print("Failed to mark messages as unread: \(error)")
            }
        }
    }

    func saveInboxIdsDeleted(deletedItems: [Int64]) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "messageId IN %@", deletedItems)

            do {
                let messages = try context.fetch(fetchRequest)
                for message in messages {
                    message.isRemoved = false
                    message.isRead = true
                }
                let inboxItems = Array(messages.compactMap {
                    CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                })
                try context.save()

                // Ensure main context reflects these changes if needed
                DispatchQueue.main.async {
                    CastledCoreDataStack.shared.saveContext()
                    self.resetUnreadUncountAfterCRUD()
                }

            } catch {
                print("Failed to mark messages as unread: \(error)")
            }
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
                    print("Failed to mark messages as unread: \(error)")
                }
            }
        }
    }

    func getLiveInboxItems() -> [CastledInboxItem] {
        let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
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
            print("Error fetching unread items: \(error)")
            return []
        }
    }
}
