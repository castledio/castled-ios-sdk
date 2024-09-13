//
//  CastledInAppMO+CoreDataProperties.swift
//  Castled
//
//  Created by antony on 13/09/2024.
//
//

import Foundation
import CoreData


extension CastledInAppMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CastledInAppMO> {
        return NSFetchRequest<CastledInAppMO>(entityName: "CastledInAppMO")
    }

    @NSManaged public var inapp_attempts: Int16
    @NSManaged public var inapp_data: Data?
    @NSManaged public var inapp_id: Int64
    @NSManaged public var inapp_last_displayed_time: Date?
    @NSManaged public var inapp_maxm_attempts: Int16
    @NSManaged public var inapp_min_interval_btwd_isplays: Int16

}

extension CastledInAppMO : Identifiable {

}
