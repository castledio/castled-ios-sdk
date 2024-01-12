//
//  CastledInAppJSBridge.swift
//  CastledInAppHTMLPOC
//
//  Created by antony on 27/07/2023.
//

import Foundation
import WebKit

protocol CastledInAppJSBridgeDelegate: AnyObject {
    func castledInAppDidRecevedClickActionWith(_ params: NSDictionary)
}

class CastledInAppJSBridge: NSObject, WKScriptMessageHandler {
    weak var webView: WKWebView?
    weak var delegate: CastledInAppJSBridgeDelegate?
    private let messageHandler = "castled"

    override init() {
        super.init()
    }

    func getWebViewConfiguration() -> WKWebViewConfiguration {
        let userController = WKUserContentController()

        let javaScript = getJSInterface()
        let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        userController.addUserScript(script)
        userController.add(self, name: messageHandler)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userController
        return configuration
    }

    private func getJSInterface() -> String {
        var js = ""
        if let jsPathURL = Bundle.resourceBundle(for: Self.self).url(forResource: "CastledBridge", withExtension: "js") {
            do {
                js = try String(contentsOf: jsPathURL, encoding: .utf8)
            } catch {
                CastledLog.castledLog("Unable to get the file CastledBridge.js.", logLevel: CastledLogLevel.error)
            }
        }
        return js
    }

    private func getClickActionFrom(_ action: String) -> CastledClickActionType {
        var clickAction: CastledClickActionType = .custom
        switch action {
            case CastledConstants.PushNotification.ClickActionType.deepLink.rawValue:
                clickAction = .deepLink
            case CastledConstants.PushNotification.ClickActionType.richLanding.rawValue:
                clickAction = .richLanding
            case CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue:
                clickAction = .navigateToScreen

            case CastledConstants.PushNotification.ClickActionType.requestPushPermission.rawValue:
                clickAction = .requestForPush
            case CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue:
                clickAction = .dismiss
            case CastledConstants.PushNotification.ClickActionType.custom.rawValue:
                clickAction = .custom
            default:
                clickAction = .custom
        }
        return clickAction
    }

    // MARK: - Delegate method to handle the script message from JavaScript

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        if message.name == messageHandler, let messageBody = message.body as? [String: Any] {
            // Here you can handle the JavaScript event data
//            if   let clickAction = messageBody["clickAction"]  as? String{
//                let optional_params : [String: Any]?
//                if let params = messageBody["custom_params"] as? [String: Any] {
//                    optional_params = params
//                }
//            }
            delegate?.castledInAppDidRecevedClickActionWith(messageBody as NSDictionary)
        }
    }
}
