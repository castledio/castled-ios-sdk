//
//  CastledRetryRequestMO+CoreDataProperties.swift
//  Castled
//
//  Created by antony on 13/09/2024.
//
//

import Foundation
import CoreData


extension CastledRetryRequestMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CastledRetryRequestMO> {
        return NSFetchRequest<CastledRetryRequestMO>(entityName: "CastledRetryRequestMO")
    }

    @NSManaged public var retry_date_added: Date?
    @NSManaged public var retry_last_attempt: Date?
    @NSManaged public var retry_request: Data?
    @NSManaged public var retry_id: String?
    @NSManaged public var retry_type: String?

}

extension CastledRetryRequestMO : Identifiable {

}
