//
//  CastledCoreDataStack.swift
//  Castled
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation

public class CasCoreDataStack {
    public static let shared = CasCoreDataStack()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CastledInbox")

        // Customize the SQLite store location
        let storeURL = self.applicationDocumentsDirectory.appendingPathComponent("castled11.sqlite") // Change "CustomSQLiteFileName" if desired
        print("storeURL--------------\(storeURL)")
        let description = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var viewContext: NSManagedObjectContext {
        print(persistentContainer)
        return persistentContainer.viewContext
    }

    public var mainContext: NSManagedObjectContext {
        print(persistentContainer)
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
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}
