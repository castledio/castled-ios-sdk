//
//  CastledRetryRequestMO+CoreDataProperties.swift
//  Castled
//
//  Created by antony on 16/09/2024.
//
//

import CoreData
import Foundation

public extension CastledRetryRequestMO {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CastledRetryRequestMO> {
        return NSFetchRequest<CastledRetryRequestMO>(entityName: "CastledRetryRequestMO")
    }

    @NSManaged var retry_date_added: Date?
    @NSManaged var retry_id: String?
    @NSManaged var retry_last_attempt: Date?
    @NSManaged var retry_request: Data?
    @NSManaged var retry_type: String?
}

extension CastledRetryRequestMO: Identifiable {}
