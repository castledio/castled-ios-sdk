//
//  CastledInAppMO+CoreDataProperties.swift
//  Castled
//
//  Created by antony on 16/09/2024.
//
//

import CoreData
import Foundation

public extension CastledInAppMO {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CastledInAppMO> {
        return NSFetchRequest<CastledInAppMO>(entityName: "CastledInAppMO")
    }

    @NSManaged var inapp_attempts: Int16
    @NSManaged var inapp_data: Data?
    @NSManaged var inapp_id: Int64
    @NSManaged var inapp_last_displayed_time: Date?
    @NSManaged var inapp_maxm_attempts: Int16
    @NSManaged var inapp_min_interval_btwd_isplays: Int32
}

extension CastledInAppMO: Identifiable {}
