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

    private init() {
        // Define a custom Realm configuration
        var config = Realm.Configuration()

        // Set the schema version to the latest version of your data model
        config.schemaVersion = 1 // Update this to match your app's schema version

        // Set the file URL to the app's Documents directory with a custom file name
        if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let customURL = documentsURL.appendingPathComponent("castled_db.realm")
            config.fileURL = customURL
            castledLog(config.fileURL as Any)
        }

        // Set the new configuration as the default
        Realm.Configuration.defaultConfiguration = config
    }

    func getRealm() -> Realm {
        // Retrieve a Realm instance with the custom configuration
        return try! Realm()
    }
}
