//
//  String+Extensions.swift
//  Castled
//
//  Created by antony on 08/11/2023.
//

import Foundation
import UIKit

extension String {
    func getAttributedStringFrom(textColr: UIColor, font: UIFont, alignment: NSTextAlignment) -> NSMutableAttributedString {
        let fullString = self

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight

        let attributes = [NSAttributedString.Key.foregroundColor: textColr as Any, .font: font as Any, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attrString = NSMutableAttributedString(string: fullString, attributes: attributes as [NSMutableAttributedString.Key: Any])

        return attrString
    }

    func getCastledClickActionType() -> CastledClickActionType {
        var pushActionType = CastledClickActionType.none
        switch self {
            case CastledConstants.PushNotification.ClickActionType.deepLink.rawValue:
                pushActionType = CastledClickActionType.deepLink
            case CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue:
                pushActionType = CastledClickActionType.navigateToScreen
            case CastledConstants.PushNotification.ClickActionType.richLanding.rawValue:
                pushActionType = CastledClickActionType.richLanding
            case CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue:
                pushActionType = CastledClickActionType.dismiss
            case CastledConstants.PushNotification.ClickActionType.requestPushPermission.rawValue:
                pushActionType = CastledClickActionType.requestForPush
            case CastledConstants.PushNotification.ClickActionType.custom.rawValue:
                pushActionType = CastledClickActionType.custom
            default:
                break
        }
        return pushActionType
    }
}
