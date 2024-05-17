//
//  View+Extensions.swift
//  Castled
//
//  Created by antony on 30/11/2023.
//

import Foundation
import UIKit
@_spi(CastledInternal)

public extension UIView {
    func addShadow(radius: CGFloat, opacity: Float, offset: CGSize, color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }

    func applyShadow(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = false
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 5)
    }
}
