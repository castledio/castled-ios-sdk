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
        guard let customDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: dict),
              let notificationId = customDict[CastledConstants.PushNotification.CustomProperties.notificationId] as? String
        else {
            return nil
        }
        return notificationId
    }

    static func getActionDetails(dict: [AnyHashable: Any], actionType: String) -> [String: Any]? {
        guard let customDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: dict),
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
        guard let customDict = CastledPushNotification.sharedInstance.getCastledDictionary(userInfo: dict)
        else {
            return nil
        }

        if let msgFramesString = customDict[CastledPushMediaConstants.messageFrames] as? String,
           let detailsArray = CastledPushMediaConstants.getMediaArrayFrom(messageFrames: msgFramesString),
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

    private static func randomIntString() -> String {
        let randomInt = Int.random(in: 1 ... Int.max)
        return String(randomInt)
    }

    static func getUniqueString() -> String {
        CastledCommonClass.getBase64UUID(uuid: UUID())
    }

    static func getBase64UUID(uuid: UUID) -> String {
        // Convert UUID to 16-byte binary representation
        var uuidBytes = uuid.uuid
        let data = Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))

        // Encode the data to a Base64 string
        let base64String = data.base64EncodedString()

        // Remove the padding characters to get 22 characters instead of 24
        let trimmedBase64String = base64String.trimmingCharacters(in: CharacterSet(charactersIn: "="))

        return trimmedBase64String
    }

    static func getUUIDString() -> String {
        return UUID().uuidString
    }
}
