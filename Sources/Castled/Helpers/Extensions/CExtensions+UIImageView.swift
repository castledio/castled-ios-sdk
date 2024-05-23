//
//  UIImageView+Extension.swift
//  Castled
//
//  Created by antony on 04/08/2023.
//

import Foundation
import SDWebImage
import UIKit
@_spi(CastledInternal)

public extension UIImageView {
    func loadImage(from url: String?) {
        let placeholderImage = UIImage(named: "castled_placeholder", in: Bundle.resourceBundle(for: Castled.self), compatibleWith: nil)
        if let imageUrl = URL(string: url ?? "") {
            self.sd_setImage(with: imageUrl, placeholderImage: placeholderImage)
        } else {
            self.image = placeholderImage
        }
    }
}
