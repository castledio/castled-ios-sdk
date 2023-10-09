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
    static func insertAllFailedItemsToStore(_ items: [[String: String]]) {
        CastledStore.castledStoreQueue.async {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: String]]) ?? [[String: String]]()
            failedItems.append(contentsOf: items)
            failedItems = Array(Set(failedItems))
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func deleteAllFailedItemsFromStore(_ items: [[String: String]]) {
        CastledStore.castledStoreQueue.async {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: String]]) ?? [[String: String]]()
            failedItems = failedItems.filter { !items.contains($0) }
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

    static func deleteInboxItem(inboxItem: CastledInboxItem) {
        let realm = CastledDBManager.shared.getRealm()
        if let existingItem = realm.object(ofType: CAppInbox.self, forPrimaryKey: inboxItem.messageId) {
            try! realm.write {
                realm.delete(existingItem)
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

    static func saveInboxObjectsRead(readItemsObjects: [CAppInbox], shouldCallApi: Bool? = false) {
        let realm = CastledDBManager.shared.getRealm()
        var readItems = [CastledInboxItem]()
        realm.writeAsync {
            for item in readItemsObjects {
                readItems.append(CastledInboxResponseConverter.convertToInboxItem(appInbox: item))
                item.isRead = true
            }

        } onComplete: { error in
            if !(error != nil) {
                if let api = shouldCallApi, api {
                    Castled.sharedInstance?.logInboxItemsRead(readItems)
                }
            }
        }
    }
}