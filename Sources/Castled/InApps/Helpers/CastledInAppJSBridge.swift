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
        if let jsPathURL = Bundle.main.url(forResource: "CastledBridge", withExtension: "js"){
            do {
                js = try String(contentsOf: jsPathURL, encoding: .utf8)
            } catch  {
                print("Unable to get the file.")
            }
        }
        return js
    }

    // MARK: - Delegate method to handle the script message from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received event from JavaScript: \(message.body)")

        if message.name == messageHandler, let messageBody = message.body as? Dictionary<String, Any> {
            // Here you can handle the JavaScript event data
            delegate?.castledInAppDidRecevedClickActionWith(messageBody as NSDictionary)

        }
    }
}
