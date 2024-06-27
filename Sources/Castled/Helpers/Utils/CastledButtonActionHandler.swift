//
//  CastledButtonActionHandler.swift
//  Castled
//
//  Created by antony on 09/01/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal)

public class CastledButtonActionHandler {
    public static func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any]?) {
        let clickAction = CastledButtonActionUtils.getButtonActionFrom(type: action, kvPairs: kvPairs)
        if type != .inbox {
            Castled.sharedInstance.delegate?.notificationClicked?(withNotificationType: type, buttonAction: clickAction, userInfo: userInfo ?? [AnyHashable: Any]())
        }

        switch action {
        case .deepLink, .richLanding:
            if let clickActionUrl = clickAction.actionUri, let url = getDeepLinkUrlFrom(url: clickActionUrl, parameters: kvPairs) { CastledButtonActionHandler.openURL(url) }
        case .navigateToScreen:
            break
        case .requestForPush:
            Castled.sharedInstance.requestPushPermission(showSettingsAlert: true)
        case .dismiss:
            // TODO:

            break
        case .custom:
            // TODO:

            break
        default:
            break
        }
    }

    private func handleRichLanding() {}
    /**
     Button action handling
     */

    private static func getDeepLinkUrlFrom(url: String, parameters: [AnyHashable: Any]?) -> URL? {
        // Encode the URL to handle special characters
        guard let formattedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let baseURL = URL(string: formattedUrl)
        else {
            // Log error if the URL is invalid
            CastledLog.castledLog("Invalid Deeplink URL provided", logLevel: CastledLogLevel.error)
            return nil
        }

        // Initialize URLComponents to parse the baseURL
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            // Log error if URLComponents initialization fails
            CastledLog.castledLog("Failed to initialize URL components from base URL.", logLevel: CastledLogLevel.error)
            return baseURL
        }

        var existingQueryItems = components.queryItems ?? []

        // Check if parameters are provided and contain a valid key-value dictionary
        if let parameters = parameters, let keyVals = parameters[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] as? [String: String] {
            // Convert the key-value pairs into URLQueryItem
            let newQueryItems = keyVals.map { URLQueryItem(name: $0.key, value: $0.value) }

            // Append new query items to existing query items, ensuring no duplicates
            for item in newQueryItems {
                // Update existing item if the key matches, or append if new
                if let index = existingQueryItems.firstIndex(where: { $0.name == item.name }) {
                    existingQueryItems[index].value = item.value
                } else {
                    existingQueryItems.append(item)
                }
            }
            components.queryItems = existingQueryItems
            if let finalURL = components.url {
                return finalURL
            } else {
                CastledLog.castledLog("Failed to construct final URL.", logLevel: CastledLogLevel.error)
            }
        }

        // Return the base URL if no additional query parameters are provided
        return baseURL
    }

    private static func openURL(_ url: URL) {
        if CastledConfigsUtils.configs.skipUrlHandling {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
