//
//  CastledDBManager.swift
//  Castled
//
//  Created by antony on 04/10/2023.
//

import Foundation

class CastledDBManager {
    static let shared = CastledDBManager()
    private let dbName = "castled_db.realm"
    private init() {}

    func clearTables() {
        // FIXME: do the needful
        /* do {
             let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
             let dbFilePath = documentDirectory.appendingPathComponent(dbName)
             if FileManager.default.fileExists(atPath: dbFilePath.path) {
                 let realm = try Realm()
                 let objectsToDelete = realm.objects(CAppInbox.self)
                 try realm.write {
                     // Delete all objects in the result set
                     realm.delete(objectsToDelete)
                 }
             }

         } catch {}*/
    }
}
