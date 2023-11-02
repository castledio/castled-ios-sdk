//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import RealmSwift

@objc class CastledStore: NSObject {
    static let castledStoreQueue = DispatchQueue(label: "com.castled.dbHandler")
    static var isInserting = false

    static func insertAllFailedItemsToStore(_ items: [[String: Any]]) {
        CastledStore.castledStoreQueue.async {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]]) ?? [[String: Any]]()
            failedItems.append(contentsOf: items)
            failedItems = failedItems.removeDuplicates()

            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func deleteAllFailedItemsFromStore(_ items: [[String: Any]]) {
        CastledStore.castledStoreQueue.async {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]]) ?? [[String: Any]]()
            failedItems = failedItems.subtract(items)
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func getAllFailedItemss() -> [[String: Any]] {
        guard let failedItems = CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]] else {
            return [[String: Any]]()
        }
        return failedItems
    }

    // MARK: - DB

    static func getInboxUnreadCount(realm: Realm) -> Int {
        realm.objects(CAppInbox.self)
            .filter("isRead == false")
            .count
    }

    static func getIAllnboxItemsCount(realm: Realm) -> Int {
        realm.objects(CAppInbox.self)
            .filter("isDeleted == false")
            .count
    }

    static func deleteInboxItem(inboxItem: CastledInboxItem) {
        let realm = CastledDBManager.shared.getRealm()
        if let existingItem = realm.object(ofType: CAppInbox.self, forPrimaryKey: inboxItem.messageId) {
            do {
                try? realm.write {
                    realm.delete(existingItem)
                    CastledStore.resetUnreadUncountAfterCRUD(realm: realm)
                }
            } catch let error as NSError {
                CastledLog.castledLog("in deltion \(error.localizedDescription)", logLevel: .error)
            }
        }
    }

    static func saveInboxItemsRead(readItems: [CastledInboxItem]) {
        let inboxItemIds = Set(readItems.map { $0.messageId })
        DispatchQueue.main.async {
            let realm = CastledDBManager.shared.getRealm()
            let filteredAppInbox = realm.objects(CAppInbox.self).filter("messageId IN %d", inboxItemIds)
            if !filteredAppInbox.isEmpty {
                CastledStore.saveInboxObjectsRead(readItemsObjects: Array(filteredAppInbox))
            }
        }
    }

    static func saveInboxIdsRead(readItems: [Int64]) {
        DispatchQueue.main.async {
            let realm = CastledDBManager.shared.getRealm()
            let filteredAppInbox = realm.objects(CAppInbox.self).filter("messageId IN %d", readItems)
            if !filteredAppInbox.isEmpty {
                CastledStore.saveInboxObjectsRead(readItemsObjects: Array(filteredAppInbox))
                let inboxItems = Array(filteredAppInbox.compactMap {
                    CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                })
                CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems, changeReadStatus: false)
            }
        }
    }

    static func saveInboxObjectsRead(readItemsObjects: [CAppInbox]) {
        let realm = CastledDBManager.shared.getRealm()
        realm.writeAsync {
            for item in readItemsObjects {
                item.isRead = true
            }
            CastledStore.resetUnreadUncountAfterCRUD(realm: realm)

        } onComplete: { _ in
        }
    }

    static func resetUnreadUncountAfterCRUD(realm: Realm) {
        Castled.sharedInstance?.inboxUnreadCount = getInboxUnreadCount(realm: realm)
    }

    static func refreshInboxItems(liveInboxResponse: [CastledInboxItem]) {
        if CastledStore.isInserting {
            return
        }
        CastledStore.isInserting = true
        CastledStore.castledStoreQueue.async {
            autoreleasepool {
                let backgroundRealm = CastledDBManager.shared.getRealm()
                try! backgroundRealm.write {
                    // Map live inbox response to Realm objects and add them to the Realm
                    let cachedInboxItems = backgroundRealm.objects(CAppInbox.self)
                    let liveInboxItemIds = Set(liveInboxResponse.map { $0.messageId })

                    let liveInboxItems = liveInboxResponse.compactMap { responseItem -> CAppInbox? in
                        if cachedInboxItems.contains(where: { $0.messageId == responseItem.messageId }) {
                            // If it exists, return nil to filter it out
                            return nil
                        } else {
                            let inboxItem = CastledInboxResponseConverter.convertToInbox(inboxItem: responseItem, realm: backgroundRealm)
                            return inboxItem
                        }
                    }
                    if !liveInboxItems.isEmpty {
                        backgroundRealm.add(liveInboxItems, update: .modified) // Insert or update as necessary
                    }
                    let expiredInboxItems = cachedInboxItems.filter { !liveInboxItemIds.contains($0.messageId) }
                    if !expiredInboxItems.isEmpty {
                        backgroundRealm.delete(expiredInboxItems)
                    }

                    CastledStore.resetUnreadUncountAfterCRUD(realm: backgroundRealm)

                    CastledStore.isInserting = false
                }
            }
        }
    }
}
