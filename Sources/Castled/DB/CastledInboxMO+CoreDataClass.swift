//
//  CastledInboxMO+CoreDataClass.swift
//  Castled
//
//  Created by antony on 11/09/2024.
//
//

import CoreData
import Foundation
import UIKit

@_spi(CastledInternal)

@objc(CastledInboxMO)
public class CastledInboxMO: NSManagedObject {}

public extension CastledInboxMO {
    var actionButtonsArray: [[String: Any]] {
        get {
            if let buttons = actionButtons, let arrayOfDictionaries: [[String: Any]] = buttons.objectFromCastledData() {
                return arrayOfDictionaries
            }
            return [[String: Any]]()
        }
        set {
            if let data = Data.dataFromArrayOrDictionary(newValue) {
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
            if let data = Data.dataFromArrayOrDictionary(newValue) {
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
