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

    static func getAllFailedRequests() -> [CastledNetworkRequest] {
        var result: [CastledNetworkRequest]!
        CastledStore.castledFailedItemsOperations.sync {
            if let failedItems: [CastledNetworkRequest] = CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedRequests, as: [CastledNetworkRequest].self) {
                result = failedItems
            } else {
                result = [CastledNetworkRequest]()
            }
        }
        return result
    }

    static func deleteFailedRequests(_ items: [CastledNetworkRequest]) {
        CastledStore.castledFailedItemsOperations.async(flags: .barrier) {
            let failedItems = CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedRequests, as: [CastledNetworkRequest].self) ?? [CastledNetworkRequest]()
            let failedcount = failedItems.count
            let idsToRemove = Set(items.map { $0.requestId })
            let updatedRequests = failedItems.filter { !idsToRemove.contains($0.requestId) }
            print("deleteFailedRequests \(updatedRequests) resned count \(idsToRemove.count)/\(failedcount)")
            CastledUserDefaults.setObject(updatedRequests, as: [CastledNetworkRequest].self, forKey: CastledUserDefaults.kCastledFailedRequests)
        }
    }

    static func enqueFailedRequest(_ request: CastledNetworkRequest) {
        CastledStore.castledFailedItemsOperations.async(flags: .barrier) {
            var failedItems = CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedRequests, as: [CastledNetworkRequest].self) ?? [CastledNetworkRequest]()
            failedItems.append(request)
            let maxmFailedItems = 5000
            if failedItems.count > maxmFailedItems {
                let numberOfElementsToRemove = failedItems.count - maxmFailedItems
                failedItems.removeFirst(numberOfElementsToRemove)
            }
            CastledUserDefaults.setObject(failedItems, as: [CastledNetworkRequest].self, forKey: CastledUserDefaults.kCastledFailedRequests)
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
