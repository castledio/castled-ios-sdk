//
//  CastledCoreDataStack.swift
//  Castled
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation
@_spi(CastledInternal) import Castled

public class CastledCoreDataStack {
    public static let shared = CastledCoreDataStack()
    let modelName = "CastledInbox"
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.resourceBundle(for: CastledCoreDataStack.self).url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("castled_inbox.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        CastledLog.castledLog("Inbox path \(storeURL)", logLevel: .info)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in

            if let err = error {
                //   fatalError("❌ Loading of store failed:\(err)")
            }
        }

        return container
    }()

    public var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
