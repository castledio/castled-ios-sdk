//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

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
