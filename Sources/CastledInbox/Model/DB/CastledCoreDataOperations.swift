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

                } catch {
                    // Handle the error appropriately in your application
                    print("Error saving background context: \(error)")
                }
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

            // Step 4: Delete items that are not in the response array
            for existingItem in existingItems {
                if !responseIDs.contains(existingItem.messageId) {
                    context.delete(existingItem)
                }
            }

            // Call completion on the main thread
            DispatchQueue.main.async {
//                self.resetUnreadUncountAfterCRUD()

                CastledInbox.sharedInstance.inboxUnreadCount = unreadCount
                CastledCoreDataOperations.shared.isInserting = false
            }
        }
    }

    func resetUnreadUncountAfterCRUD() {
        CastledInbox.sharedInstance.inboxUnreadCount = self.getInboxUnreadCount()
    }

    func getInboxUnreadCount() -> Int {
        let fetchRequest: NSFetchRequest<CastledAppInbox> = CastledAppInbox.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isRead == %@", NSNumber(value: false))
        let context = CastledCoreDataStack.shared.newBackgroundContext()
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
        fetchRequest.predicate = NSPredicate(format: "messageId == %d", messageId)
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            return nil
        }
    }
}
