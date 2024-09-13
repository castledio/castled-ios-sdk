//
//  CastledInboxMO+CoreDataProperties.swift
//  Castled
//
//  Created by antony on 13/09/2024.
//
//

import CoreData
import Foundation

public extension CastledInboxMO {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CastledInboxMO> {
        return NSFetchRequest<CastledInboxMO>(entityName: "CastledInboxMO")
    }

    @NSManaged var actionButtons: Data?
    @NSManaged var addedDate: Date
    @NSManaged var aspectRatio: Float
    @NSManaged var body: String
    @NSManaged var bodyTextColor: String
    @NSManaged var containerBGColor: String
    @NSManaged var dateTextColor: String
    @NSManaged var imageUrl: String
    @NSManaged var inboxType: String
    @NSManaged var isPinned: Bool
    @NSManaged var isRead: Bool
    @NSManaged var isRemoved: Bool
    @NSManaged var message: Data?
    @NSManaged var messageId: Int64
    @NSManaged var sourceContext: String
    @NSManaged var startTs: Int64
    @NSManaged var tag: String
    @NSManaged var teamID: Int16
    @NSManaged var title: String
    @NSManaged var titleTextColor: String
    @NSManaged var updatedTime: Int64
}

extension CastledInboxMO: Identifiable {}
