//
//  CastledCommonClass.swift
//  Castled
//
//  Created by Castled Data on 01/12/2022.
//
import Foundation
import UIKit

public class CastledCommonClass {
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                CastledLog.castledLog(error.localizedDescription, logLevel: CastledLogLevel.error)
            }
        }
        return nil
    }

    static func getCastledPushNotificationId(dict: [AnyHashable: Any]) -> String? {
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? NSDictionary,
              let notificationId = customDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String
        else {
            return nil
        }
        return notificationId
    }

    static func getActionDetails(dict: [AnyHashable: Any], actionType: String) -> [String: Any]? {
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? NSDictionary,
              let notification = dict[CastledConstants.PushNotification.apsKey] as? NSDictionary,
              let category = notification[CastledConstants.PushNotification.ApsProperties.category] as? String,
              let categoryJsonString = customDict[CastledConstants.PushNotification.CustomProperties.categoryActions] as? String,
              let deserializedDict = CastledCommonClass.convertToDictionary(text: categoryJsonString),
              let actionsArray = deserializedDict[CastledConstants.PushNotification.CustomProperties.Category.actionComponents] as? [[String: Any]]
        else {
            return nil
        }

        for action in actionsArray {
            if let identifier = action[CastledConstants.PushNotification.CustomProperties.Category.Action.actionId] as? String, identifier == actionType {
                let keyVals = action[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] as? NSDictionary ?? [:]
                return [
                    CastledConstants.PushNotification.ApsProperties.category: category,
                    CastledConstants.PushNotification.CustomProperties.Category.Action.actionId: identifier,
                    CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction: action[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String ?? "",
                    CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl: action[CastledConstants.PushNotification.CustomProperties.Category.Action.url] as? String ?? "",
                    CastledConstants.PushNotification.CustomProperties.Category.Action.buttonTitle: action[CastledConstants.PushNotification.CustomProperties.Category.Action.actionId] as? String ?? "",
                    CastledConstants.PushNotification.inboxCopyEnabled: isInboxCopyEnabled(customDict: customDict as? [String: Any] ?? [:]),
                    CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals: keyVals,
                    CastledConstants.PushNotification.CustomProperties.Category.Action.useWebView: action[CastledConstants.PushNotification.CustomProperties.Category.Action.useWebView] as? Bool ?? false
                ]
            }
        }
        return nil
    }

    static func getDefaultActionDetails(dict: [AnyHashable: Any], index: Int? = 0) -> [String: Any]? {
        guard let customDict = dict[CastledConstants.PushNotification.customKey] as? [String: Any]
        else {
            return nil
        }
        if let msgFramesString = customDict["msg_frames"] as? String,
           let detailsArray = CastledCommonClass.convertToArray(text: msgFramesString) as? [Any],
           detailsArray.count > index!,
           var selectedCategory = detailsArray[index!] as? [String: Any]
        {
            selectedCategory[CastledConstants.PushNotification.inboxCopyEnabled] = isInboxCopyEnabled(customDict: customDict)
            return selectedCategory
        }
        return nil
    }

    private static func isInboxCopyEnabled(customDict: [String: Any]) -> Bool {
        if let i_cp = customDict["i_cp"] as? String, i_cp == "true" {
            return true
        }
        return false
    }

    static func convertToArray(text: String) -> Any? {
        guard let data = text.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    public static func hexStringToUIColor(hex: String) -> UIColor? {
        return UIColor(hexString: hex)
    }

    static func instantiateFromNib<T: UIViewController>(vc: T.Type) -> T {
        return T(nibName: String(describing: T.self), bundle: Bundle.resourceBundle(for: Self.self))
    }

    static func loadView<T: UIView>(fromNib name: String, withType type: T.Type) -> T? {
        let bundle = Bundle.resourceBundle(for: Self.self)
        if let view = UINib(
            nibName: name,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? T {
            return view
        }
        if let view = bundle.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        return nil
    }

    static func getSDKVersion() -> String {
        if let plistPath = Bundle.resourceBundle(for: Castled.self).path(forResource: "Info", ofType: "plist"),
           let infoDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
           let version = infoDict["CFBundleShortVersionString"] as? String
        {
            // 'version' contains the CFBundleShortVersionString value
            return version
        }
        return ""
    }
}
