//
//  CastledButtonActionUtils.swift
//  Castled
//
//  Created by antony on 27/02/2024.
//

import Foundation
@_spi(CastledInternal)

public enum CastledButtonActionUtils {
    public static func getButtonActionFrom(type: CastledClickActionType, kvPairs: [AnyHashable: Any]?) -> CastledButtonAction {
        let action = CastledButtonAction()
        action.actionType = type
        if let kvPairs = kvPairs {
            if let clickActionUrl = CastledButtonActionUtils.getClickActionUrlFrom(kvPairs: kvPairs) {
                action.actionUri = clickActionUrl
            }
            if let inboxCopyEnabled = kvPairs[CastledConstants.PushNotification.inboxCopyEnabled] as? Bool {
                action.inboxCopyEnabled = inboxCopyEnabled
            }
            if let title = kvPairs[CastledConstants.PushNotification.CustomProperties.Category.Action.buttonTitle] as? String ?? kvPairs[CastledConstants.PushNotification.CustomProperties.Category.Action.label] as? String {
                action.buttonTitle = title
            }
            if let keyVals = kvPairs[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] as? [String: Any] {
                action.keyVals = keyVals
            }
        }
        return action
    }

    static func getClickActionUrlFrom(kvPairs: [AnyHashable: Any]?) -> String? {
        let clickActionUrl = kvPairs?[CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl] as? String ?? kvPairs?[CastledConstants.PushNotification.CustomProperties.Category.Action.url] as? String
        return clickActionUrl
    }
}
