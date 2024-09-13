//
//  CastledCoreDataStack.swift
//  Castled
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation

@_spi(CastledInternal)

public class CastledCoreDataStack {
    public static let modelName = "CastledModel"
    private static let castledFolder = "Castled"
    private static let castledDB = "CastledEntities.sqlite"

    public static let shared = CastledCoreDataStack()

    private init() {}

    public static var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.resourceBundle(for: CastledCoreDataStack.self).url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        let fileManager = FileManager.default
        let castledFolderURL = CastledCoreDataStack.applicationDocumentsDirectory.appendingPathComponent(castledFolder)

        if !fileManager.fileExists(atPath: castledFolderURL.path) {
            try? fileManager.createDirectory(at: castledFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
        let storeURL = castledFolderURL.appendingPathComponent(castledDB)
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        CastledLog.castledLog("DB path \(storeURL)", logLevel: .info)
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
        let context = Self.persistentContainer.newBackgroundContext()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mergeChangesFromContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: context
        )

        return context
    }

    @objc func mergeChangesFromContextDidSave(notification: Notification) {
        print("mergeChangesFromContextDidSave about to begin")
        let viewContext = Self.persistentContainer.viewContext
        viewContext.perform {
            viewContext.mergeChanges(fromContextDidSave: notification)
            print("mergeChangesFromContextDidSave completed..")
        }
    }

    public func saveContext() {
        let context = Self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                print("Saving to maincontext completed.. \(Thread.isMainThread) \(Thread.current)")
                try context.save()
            } catch {
                //   let nserror = error as NSError
                // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            print("No change in the context to merge with main.. \(Thread.isMainThread) ")
        }
    }

    public static var applicationDocumentsDirectory: URL {
        if !CastledUserDefaults.appGroupId.isEmpty,
           let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CastledUserDefaults.appGroupId)
        {
            print("Shared url as uses suit.. \(Thread.isMainThread) ")

            return sharedContainerURL
        }

        print("Default url as appgroupid is empty.. \(Thread.isMainThread) ")

        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
