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
    static let modelName = "CastledInbox"
    private init() {}

    static var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.resourceBundle(for: CastledCoreDataStack.self).url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        let storeURL = CastledCoreDataStack.applicationDocumentsDirectory.appendingPathComponent("castled_inbox.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        // CastledLog.castledLog("Inbox path \(storeURL)", logLevel: .info)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in

            if let err = error {
                //   fatalError("❌ Loading of store failed:\(err)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    public var mainContext: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }

    func initialize() {
        _ = Self.persistentContainer
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        return Self.persistentContainer.newBackgroundContext()
    }

    public func saveContext() {
        let context = Self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                //   let nserror = error as NSError
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    static var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
