//
//  CastledTouchThroughWindow.swift
//  Castled
//
//  Created by antony on 11/05/2023.
//

import Foundation
import UIKit

class CastledTouchThroughWindow: UIWindow {
    var shouldPassThrough = false
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if (view == self && shouldPassThrough == false) || view?.restorationIdentifier != nil {
            return nil // allow touch events to pass through to the underlying views
        }
        return view // handle touch events for the subviews normally
    }
}
