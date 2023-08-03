//
//  CIWebView.swift
//  SB
//
//  Created by antony on 02/08/2023.
//

import UIKit
import WebKit

class CIHTMLView: UIView,CIViewProtocol {

    var mainImage: UIImage?
    var parentContainerVC: CastledInAppDisplayViewController?
    var selectedInAppObject: CastledInAppObject?
    var inAppDisplaySettings: InAppDisplayConfig?
    var viewContainer: UIView?

    @IBOutlet weak var viewMainContainer: UIView!
    var htmlString = ""
    var webView: WKWebView!
    var webViewBridge: CastledInAppJSBridge! // Declare the bridge instance as a property


    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupWKWebview()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWKWebview()
    }
    func configureTheViews() {

    }

    private func setupWKWebview() {

        // Initialize the bridge class with the WKWebView
        webViewBridge = CastledInAppJSBridge()
        webViewBridge.delegate = self // Set the delegate

        let configuration = webViewBridge.getWebViewConfiguration()
        self.webView = WKWebView(
            frame: self.bounds,
            configuration:configuration
        )
        addSubview(self.webView)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.webView.topAnchor.constraint(equalTo: self.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

    }

    func loadHtmlString(){
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
extension CIHTMLView : CastledInAppJSBridgeDelegate{
    func castledInAppDidRecevedClickActionWith(_ params: NSDictionary) {
        print(params)

    }

}
