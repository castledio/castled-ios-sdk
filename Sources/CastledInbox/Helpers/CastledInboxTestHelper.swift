//
//  CastledInboxTestHelper.swift
//  CastledInbox
//
//  Created by antony on 15/07/2024.
//

import CoreData
import UIKit
@_spi(CastledInboxTestable)

public class CastledInboxTestHelper: NSObject {
    public static let shared = CastledInboxTestHelper()

    public func getModelName() -> String {
        return CastledCoreDataStack.modelName
    }

    public func getApplicationDocumentsDirectory() -> URL {
        return CastledCoreDataStack.applicationDocumentsDirectory
    }

    public func setCoredataStackContainer(container: NSPersistentContainer) {
        CastledCoreDataStack.persistentContainer = container
    }

    public func isInboxModuleInitialized() -> Bool {
        return CastledInbox.sharedInstance.isInitilized
    }
}
