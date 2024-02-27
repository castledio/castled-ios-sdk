//
//  CastledButtonClickAction.swift
//  Castled
//
//  Created by antony on 27/02/2024.
//

import Foundation

@objc public class CastledButtonAction: NSObject {
    @objc public var actionType: CastledClickActionType = .none
    @objc public var actionUri: String?
    @objc public var buttonTitle: String?
    @objc public var inboxCopyEnabled = false
    @objc public var keyVals: [String: Any]?
}
