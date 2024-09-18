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
    public static let modelName = "CastledDB"
    private static let castledFolder = "Castled"
    private static let castledDB = "CastledDB.sqlite"

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
        // CastledLog.castledLog("DB path \(storeURL)", logLevel: .info)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in

            if let err = error {
                CastledLog.castledLog("Loading of store failed:\(err)", logLevel: .error)
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
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

    @objc func mergeChangesFromContextDidSave(notification: Notification) {
        let viewContext = Self.persistentContainer.viewContext
        viewContext.perform {
            viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    public func saveContext() {
        let context = Self.persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            CastledLog.castledLog("Unresolved error \(nserror), \(nserror.userInfo)", logLevel: .error)
        }
    }

    public static var applicationDocumentsDirectory: URL {
        if !CastledUserDefaults.appGroupId.isEmpty,
           let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CastledUserDefaults.appGroupId)
        {
            return sharedContainerURL
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
