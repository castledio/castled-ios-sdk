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
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight

        let attributes = [NSAttributedString.Key.foregroundColor: textColr as Any, .font: font as Any, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attrString = NSMutableAttributedString(string: fullString, attributes: attributes as [NSMutableAttributedString.Key: Any])

        return attrString
    }
}
