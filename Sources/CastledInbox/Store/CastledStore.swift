//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Castled
import Foundation
import RealmSwift

@objc class CastledStore: NSObject {
    static let castledStoreQueue = DispatchQueue(label: "CastledbHandler")
    static let castledFailedItemsOperations = DispatchQueue(label: "CastledFailedItemsOperations", attributes: .concurrent)

    static var isInserting = false

    static func insertAllSendingItemsToStore(_ items: [[String: Any]]) {
        CastledStore.castledFailedItemsOperations.async(flags: .barrier) {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]]) ?? [[String: Any]]()
            failedItems.append(contentsOf: items)
            failedItems = failedItems.removeDuplicates()
            let maxmFailedItems = 5000
            if failedItems.count > maxmFailedItems {
                let numberOfElementsToRemove = failedItems.count - maxmFailedItems
                failedItems.removeFirst(numberOfElementsToRemove)
            }
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func deleteAllFailedItemsFromStore(_ items: [[String: Any]]) {
        CastledStore.castledFailedItemsOperations.async(flags: .barrier) {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]]) ?? [[String: Any]]()
            failedItems = failedItems.subtract(items)
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func getAllFailedItemss() -> [[String: Any]] {
        var result: [[String: Any]]!
        CastledStore.castledFailedItemsOperations.sync {
            if let failedItems = CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: Any]] {
                result = failedItems
            } else {
                result = [[String: Any]]()
            }
        }
        return result
    }

    // MARK: - DB

    static func getInboxUnreadCount(realm: Realm?) -> Int {
        realm?.objects(CAppInbox.self)
            .filter("isRead == false")
            .count ?? 0
    }

    static func getIAllnboxItemsCount(realm: Realm?) -> Int {
        realm?.objects(CAppInbox.self)
            .filter("isDeleted == false")
            .count ?? 0
    }

    static func deleteInboxItem(inboxItem: CastledInboxItem) {
        if let realm = CastledDBManager.shared.getRealm() {
            if let existingItem = realm.object(ofType: CAppInbox.self, forPrimaryKey: inboxItem.messageId) {
                do {
                    try? realm.write {
                        realm.delete(existingItem)
                        CastledStore.resetUnreadUncountAfterCRUD(realm: realm)
                    }
                }
            }
        }
    }

    static func saveInboxItemsRead(readItems: [CastledInboxItem]) {
        let inboxItemIds = Set(readItems.map { $0.messageId })
        DispatchQueue.main.async {
            if let realm = CastledDBManager.shared.getRealm() {
                let filteredAppInbox = realm.objects(CAppInbox.self).filter("messageId IN %d", inboxItemIds)
                if !filteredAppInbox.isEmpty {
                    CastledStore.saveInboxObjectsRead(readItemsObjects: Array(filteredAppInbox))
                }
            }
        }
    }

    static func saveInboxIdsRead(readItems: [Int64]) {
        DispatchQueue.main.async {
            if let realm = CastledDBManager.shared.getRealm() {
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
    }

    static func saveInboxObjectsRead(readItemsObjects: [CAppInbox]) {
        if let realm = CastledDBManager.shared.getRealm() {
            realm.writeAsync {
                for item in readItemsObjects {
                    item.isRead = true
                }
                CastledStore.resetUnreadUncountAfterCRUD(realm: realm)

            } onComplete: { _ in
            }
        }
    }

    static func resetUnreadUncountAfterCRUD(realm: Realm) {
        CastledInbox.sharedInstance.inboxUnreadCount = getInboxUnreadCount(realm: realm)
    }

    static func refreshInboxItems(liveInboxResponse: [CastledInboxItem]) {
        if CastledStore.isInserting {
            return
        }
        CastledStore.isInserting = true
        CastledStore.castledStoreQueue.async {
            autoreleasepool {
                if let backgroundRealm = CastledDBManager.shared.getRealm() {
                    do {
                        try backgroundRealm.write {
                            // Map live inbox response to Realm objects and add them to the Realm
                            let cachedInboxItems = backgroundRealm.objects(CAppInbox.self)
                            let liveInboxItemIds = Set(liveInboxResponse.map { $0.messageId })

                            let liveInboxItems = liveInboxResponse.compactMap { responseItem -> CAppInbox? in
                                let inboxItem = CastledInboxResponseConverter.convertToInbox(inboxItem: responseItem, realm: backgroundRealm)
                                return inboxItem
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
                    } catch {
                        // Handle error gracefully
                        print("Error writing to realm: \(error)")
                        CastledStore.isInserting = false
                    }

                } else { CastledStore.isInserting = false
                }
            }
        }
    }
}

extension CastledStore {
    // Function to write to a file (appending)
    static func writeToFile(data: Data, filename: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: filePath))
            fileHandle.write(data)
            fileHandle.closeFile()

        } catch {}
    }

    // Function to read from a file
    static func readFromFile(filename: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                return data
            }
            return nil
        } catch {
            return nil
        }
    }

    static func removeFile(filename: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsDirectory.appendingPathComponent(filename).path

        do {
            if FileManager.default.fileExists(atPath: filePath) {
                try FileManager.default.removeItem(atPath: filePath)
            }

        } catch {}
    }
}
