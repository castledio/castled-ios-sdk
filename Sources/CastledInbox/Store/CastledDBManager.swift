//
//  CastledDBManager.swift
//  Castled
//
//  Created by antony on 04/10/2023.
//

import Foundation
import RealmSwift

class CastledDBManager {
    static let shared = CastledDBManager()
    private let dbName = "castled_db.realm"
    private init() {
        // Define a custom Realm configuration
        var config = Realm.Configuration()

        // Set the schema version to the latest version of your data model
        config.schemaVersion = 1 // Update this to match your app's schema version

        // Set the file URL to the app's Documents directory with a custom file name
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let customURL = documentsURL.appendingPathComponent(dbName)
            config.fileURL = customURL
            //  CastledLog.castledLog(config.fileURL as Any, logLevel: CastledLogLevel.info)
        }

        // Set the new configuration as the default
        Realm.Configuration.defaultConfiguration = config
    }

    func getRealm() -> Realm? {
        // Retrieve a Realm instance with the custom configuration
        return try? Realm()
    }

    func clearTables() {
        do {
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

        } catch {}
    }
}
