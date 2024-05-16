//
//  CAppInbox.swift
//  Castled
//
//  Created by antony on 03/10/2023.
//

import Castled
import Foundation
import RealmSwift
import UIKit

class CAppInbox: Object {
    @Persisted(primaryKey: true) var messageId: Int64
    @Persisted var teamID: Int
    @Persisted var startTs: Int64
    @Persisted var sourceContext: String
    @Persisted var imageUrl: String
    @Persisted var title: String
    @Persisted var body: String
    @Persisted var isRead: Bool
    @Persisted var isDeleted: Bool
    @Persisted var isPinned: Bool
    @Persisted var updatedTime: Int64
    @Persisted var tag: String
    @Persisted var addedDate: Date
    @Persisted var aspectRatio: Float
    @Persisted var inboxType: CastledInboxType
    @Persisted var bodyTextColor: String
    @Persisted var containerBGColor: String
    @Persisted var dateTextColor: String
    @Persisted var titleTextColor: String
    @Persisted var actionButtons: Data
    @Persisted var message: Data

    var actionButtonsArray: [[String: Any]] {
        get {
            if let arrayOfDictionaries: [[String: Any]] = actionButtons.objectFromCastledData() {
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
            if let dictionary: [String: Any] = message.objectFromCastledData() {
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

    override static func ignoredProperties() -> [String] {
        return ["actionButtonsArray", "messageDictionary"]
    }
}

extension CAppInbox {
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
