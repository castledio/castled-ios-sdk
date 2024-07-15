//
//  CastledCoreDataStack.swift
//  Castled
//
//  Created by antony on 29/05/2024.
//

import CoreData
import Foundation
@_spi(CastledInternal) import Castled
@_spi(CastledInboxTestable) import CastledInbox

@objc public class CastledTestCoreDataStack: NSObject {
    public static let shared = CastledTestCoreDataStack()
    override private init() {}

    static var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.resourceBundle(for: CastledCoreDataStack.self).url(forResource: CastledInboxTestHelper.shared.getModelName(), withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: CastledInboxTestHelper.shared.getModelName(), managedObjectModel: managedObjectModel!)
        let storeURL = CastledInboxTestHelper.shared.getApplicationDocumentsDirectory().appendingPathComponent("castled_inbox_test.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        CastledLog.castledLog("Inbox test path \(storeURL)", logLevel: .info)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in

            if let err = error {
                //   fatalError("❌ Loading of store failed:\(err)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true

        return container
    }()

    @objc public static func initializeTestStack() {
        CastledInboxTestHelper.shared.setCoredataStackContainer(container: persistentContainer)
    }
}
