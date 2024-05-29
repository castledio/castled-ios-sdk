//
//  CastledAppInbox+CoreDataProperties.swift
//  CastledInbox
//
//  Created by antony on 29/05/2024.
//
//

import CoreData
import Foundation
import UIKit
@_spi(CastledInternal) import Castled

public extension CastledAppInbox {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CastledAppInbox> {
        return NSFetchRequest<CastledAppInbox>(entityName: "CastledAppInbox")
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

extension CastledAppInbox: Identifiable {
    public var actionButtonsArray: [[String: Any]] {
        get {
            if let buttons = actionButtons, let arrayOfDictionaries: [[String: Any]] = buttons.objectFromCastledData() {
                return arrayOfDictionaries
            }
            return [[String: Any]]()
        }
        set {
            if let data = Data.dataFromObject(newValue) {
                actionButtons = data
            }
        }
    }

    var messageDictionary: [String: Any] {
        get {
            if let msg = message, let dictionary: [String: Any] = msg.objectFromCastledData() {
                return dictionary
            }
            return [String: Any]()
        }
        set {
            if let data = Data.dataFromObject(newValue) {
                message = data
            }
        }
    }

    var colorContainer: UIColor {
        return CastledCommonClass.hexStringToUIColor(hex: containerBGColor) ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    var colorTitle: UIColor {
        return CastledCommonClass.hexStringToUIColor(hex: titleTextColor) ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }

    var colorBody: UIColor {
        return CastledCommonClass.hexStringToUIColor(hex: bodyTextColor) ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
