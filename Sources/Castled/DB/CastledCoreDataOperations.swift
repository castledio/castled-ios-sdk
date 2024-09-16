//
//  CastledCoreDataOperations.swift
//  CastledInbox
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation

@_spi(CastledInternal)

public class CastledCoreDataOperations {
    public static let shared = CastledCoreDataOperations()
    private init() {}

    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        CastledCoreDataStack.shared.saveContext()
                    }

                } catch {
                    CastledLog.castledLog("Error saving background context: \(error)", logLevel: .error)
                }
            }
        }
    }

    public func getEntity<T: NSManagedObject>(from context: NSManagedObjectContext, fetchRequest: NSFetchRequest<T>) -> T? {
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            CastledLog.castledLog("Error fetching \(T.self): \(error)", logLevel: .error)
            return nil
        }
    }

    public func deleteAllData() {
        CastledCoreDataOperations.shared.performBackgroundTask { context in
            let entities = self.fetchEntities(context: context)
            for entity in entities {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

                do {
                    try context.execute(deleteRequest)
                } catch {
                    CastledLog.castledLog("Failed to delete data for entity \(entity): \(error)", logLevel: .error)
                }
            }

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    CastledLog.castledLog("Failed to save context after deleting all data: \(error)", logLevel: .error)
                }
            }
        }
    }

    private func fetchEntities(context: NSManagedObjectContext) -> [String] {
        let model = context.persistentStoreCoordinator?.managedObjectModel
        return model?.entitiesByName.keys.sorted() ?? []
    }
}
