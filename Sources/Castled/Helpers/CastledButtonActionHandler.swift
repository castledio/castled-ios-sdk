//
//  CastledButtonActionHandler.swift
//  Castled
//
//  Created by antony on 09/01/2024.
//

import Foundation
import UIKit

class CastledButtonActionHandler {
    static func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any]) {
        switch action {
            case .deepLink:
                if let details = kvPairs, let clickActionUrl = details["clickActionUrl"] as? String, let url = getDeepLinkUrlFrom(url: clickActionUrl, parameters: kvPairs) { CastledButtonActionHandler.openURL(url) }
            case .navigateToScreen:
                break
            case .richLanding:
                if let details = kvPairs, let clickActionUrl = details["clickActionUrl"] as? String, let url = URL(string: clickActionUrl) { CastledButtonActionHandler.openURL(url) }
            case .requestForPush:
                // TODO:

                break
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
        // Define the base URL for your deep link
        guard let baseURL = URL(string: url) else {
            CastledLog.castledLog("Invalid Deeplink URL provided", logLevel: CastledLogLevel.error)
            return nil
        }
        var queryString = ""
        // Create a dictionary of query parameters
        if let params = parameters, let keyVals = params["keyVals"] as? [String: String] {
            // Convert the query parameters to a query string
            queryString = keyVals.map { key, value in
                "\(key)=\(value)"
            }.joined(separator: "&")
        }
        // Construct the final deep link URL with query parameters
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.query = queryString

        if let deepLinkURL = components.url {
            // deepLinkURL now contains the complete deep link URL with query parameters
            return deepLinkURL
        } else {
            CastledLog.castledLog("Invalid Deeplink URL provided", logLevel: CastledLogLevel.error)
        }
        return nil
    }

    private static func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            CastledLog.castledLog("Cannot open URL \(url)", logLevel: CastledLogLevel.error)
        }
    }
}
