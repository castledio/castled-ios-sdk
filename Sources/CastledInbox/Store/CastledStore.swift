//
//  CastledUserDefaults.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

@_spi(CastledInternal) import Castled
import Foundation

@objc class CastledStore: NSObject {
    static let castledStoreQueue = DispatchQueue(label: "CastledbHandler")
    static let castledFailedItemsOperations = DispatchQueue(label: "CastledFailedItemsOperations", attributes: .concurrent)

    static var isInserting = false

    // MARK: - DB

    static func saveInboxIdsRead(readItems: [Int64]) {
        /* DispatchQueue.main.async {
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
         }*/
    }
}
