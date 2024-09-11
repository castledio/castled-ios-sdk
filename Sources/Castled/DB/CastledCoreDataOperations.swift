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
        print("performBackgroundTask beinning")
        let context = CastledCoreDataStack.shared.newBackgroundContext()
        context.perform {
            block(context)
            if context.hasChanges {
                do {
                    try context.save()
                    CastledCoreDataStack.shared.saveContext()
                    print("performBackgroundTask completion")

                } catch {
                    // Handle the error appropriately in your application
                    print("Error saving background context: \(error)")
                }
            } else {
                print("performBackgroundTask completion no chnage")
            }
        }
    }

    public func getEntity<T: NSManagedObject>(from context: NSManagedObjectContext, fetchRequest: NSFetchRequest<T>) -> T? {
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching \(T.self): \(error)")
            return nil
        }
    }
}
