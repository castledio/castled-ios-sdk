//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation

@objc class CastledStore: NSObject {
    static let castledStoreQueue = DispatchQueue(label: "com.castled.dbHandler", qos: .background)
    static var isInserting = false
    static func insertAllIntoStore(_ items: [[String: String]]) {
        CastledStore.castledStoreQueue.async {
            var failedItems = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledFailedItems) as? [[String: String]]) ?? [[String: String]]()
            failedItems.append(contentsOf: items)
            failedItems = Array(Set(failedItems))
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledFailedItems, failedItems)
        }
    }

    static func deleteAllFromStore(_ items: [[String: String]]) {
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
}
