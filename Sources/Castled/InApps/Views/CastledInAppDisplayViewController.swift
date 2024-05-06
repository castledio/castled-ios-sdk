//
//  CastledBaseViewController.swift
//  Castled
//
//  Created by Castled Data on 12/12/2022.
//

import UIKit

class CastledInAppDisplayViewController: UIViewController {
    @IBOutlet weak var viewModalContainer: UIView!
    @IBOutlet weak var viewFSContainer: UIView!
    @IBOutlet weak var viewBannerContainer: UIView!
    @IBOutlet weak var constraintBannerBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintBannerTop: NSLayoutConstraint!

    @IBOutlet weak var constraintCloseTrialing: NSLayoutConstraint!
    @IBOutlet weak var constraintCloseTop: NSLayoutConstraint!
    @IBOutlet weak var dismissView: CastledDismissButton!
    private var inAppWindow: CastledTouchThroughWindow?
    var selectedInAppObject: CastledInAppObject?
    private var isSlideUpInApp = false
    private var isDefaultActionTriggered = false
    private var autoDismissalWorkItem: DispatchWorkItem?
    var inAppView: (any CIViewProtocol)?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showInAppViewControllerFromNotification(inAppObj: CastledInAppObject, inAppDisplaySettings: InAppDisplayConfig) -> Bool {
        if #available(iOS 13, tvOS 13.0, *) {
            let connectedScenes = UIApplication.shared.connectedScenes
            for scene in connectedScenes {
                if scene.activationState == .foregroundActive && (scene is UIWindowScene) {
                    let windowScene = scene as? UIWindowScene
                    inAppWindow = CastledTouchThroughWindow(
                        frame: windowScene?.coordinateSpace.bounds ?? CGRect.zero)
                    inAppWindow?.windowScene = windowScene
                }
            }
        } else {
            inAppWindow = CastledTouchThroughWindow(
                frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        }
        guard let window = inAppWindow else {
            return false
        }
        selectedInAppObject = inAppObj
        let items = getInappViewFrom(inappAObject: inAppObj)
        inAppView = items.0
        let containerView = items.1

        if inAppView == nil || containerView == nil {
            return false
        }

        containerView?.isHidden = false
        isSlideUpInApp = containerView == viewBannerContainer
        inAppWindow?.shouldPassThrough = isSlideUpInApp // for enabling touch only for banner
        isDefaultActionTriggered = false
        // required properties for population
        inAppView?.parentContainerVC = self
        inAppView?.viewParentContainer = containerView
        inAppView?.inAppDisplaySettings = inAppDisplaySettings
        inAppView?.selectedInAppObject = selectedInAppObject
        inAppView?.addTheInappViewInContainer(inappView: inAppView as! UIView)
        arrangeDismissButton(containerView: containerView!)
        if let html = items.2 {
            let htmlView = inAppView as! CIHTMLView
            if let decodedData = Data(base64Encoded: html) {
                htmlView.htmlString = String(data: decodedData, encoding: .utf8) ?? html
            } else {
                htmlView.htmlString = html
            }
            htmlView.loadHtmlString()
        }

        let inAppParentView = view!
        inAppParentView.frame = window.bounds
        window.backgroundColor = .clear
        window.windowLevel = .normal
        window.isHidden = false
        window.makeKeyAndVisible()
        window.rootViewController = self
        window.makeKeyAndVisible()

        inAppParentView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            inAppParentView.alpha = 1

        }) { [weak self] _ in
            self?.view.layoutSubviews()
            CastledInApps.sharedInstance.reportInAppEvent(inappObject: inAppObj, eventType: CastledConstants.CastledEventTypes.viewed.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)
            if inAppObj.displayConfig?.autoDismissInterval ?? 0 > 0 {
                self?.autoDismissalWorkItem?.cancel()
                let requestWorkItem = DispatchWorkItem { [weak self] in
                    self?.hideInAppViewFromWindow(withAnimation: true)
                }
                self?.autoDismissalWorkItem = requestWorkItem
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(inAppObj.displayConfig!.autoDismissInterval),
                                              execute: requestWorkItem)
            }
        }
        return true
    }

    func hideInAppViewFromWindow(withAnimation: Bool? = true) {
        autoDismissalWorkItem?.cancel()
        guard let interstitialView = view else {
            return
        }
        if withAnimation == true {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                interstitialView.alpha = 0
            }) { [weak self] _ in
                // Remove the interstitial view controller from the view hierarchy
                CastledInApps.sharedInstance.isCurrentlyDisplaying = false
                CastledInApps.sharedInstance.checkPendingNotificationsIfAny()
                self?.removeAllViews()
                // Notify the delegate that it should dismiss the interstitial view controller
            }
        } else {
            removeAllViews()
        }
    }

    func removeAllViews() {
        inAppWindow?.rootViewController = nil
        // inAppView?.viewContainer?.removeFromSuperview()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        inAppWindow?.removeFromSuperview()
        inAppWindow = nil
    }

    private func dismissButtonClicked(_ sender: Any) {
        CastledInApps.sharedInstance.reportInAppEvent(inappObject: selectedInAppObject!, eventType: CastledConstants.CastledEventTypes.discarded.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)
        hideInAppViewFromWindow(withAnimation: true)
    }

    private func arrangeDismissButton(containerView: UIView) {
        // we are resetting the constrionts after adding to the new contianer, removing this to prevent the stretiching issue
        dismissView.superview?.removeConstraint(constraintCloseTop)
        dismissView.superview?.removeConstraint(constraintCloseTrialing)

        if containerView == viewFSContainer {
            let safeArea = view.safeAreaLayoutGuide
            dismissView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10).isActive = true
            dismissView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0).isActive = true

        } else {
            var buttonParentView = containerView
            var trailingAnchor = 5
            var topAnchor = -5

            if let childContainer = inAppView?.viewChildViewsContainer {
                // modal
                trailingAnchor = 0
                topAnchor = 0
                buttonParentView = childContainer
                childContainer.superview!.addSubview(dismissView)
            }
            dismissView.trailingAnchor.constraint(equalTo: buttonParentView.trailingAnchor, constant: CGFloat(trailingAnchor)).isActive = true
            dismissView.topAnchor.constraint(equalTo: buttonParentView.topAnchor, constant: CGFloat(topAnchor)).isActive = true
        }
        let action = DismissViewActions(dismissBtnClickedAction: dismissButtonClicked)
        dismissView.initialiseActions(actions: action)
    }

    private func getActionbuttons() -> [CIActionButton]? {
        return selectedInAppObject?.message?.type == CIMessageType.modal ? selectedInAppObject?.message?.modal?.actionButtons : selectedInAppObject?.message?.fs?.actionButtons
    }

    @objc func primaryButtonClikd(_ sender: UIButton) {
        if let actionButtons = getActionbuttons() {
            CastledInApps.sharedInstance.reportInAppEvent(inappObject: selectedInAppObject!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue, actionType: inAppView?.inAppDisplaySettings?.primaryButtonClickAction, btnLabel: inAppView?.inAppDisplaySettings?.primaryButtonTitle, actionUri: inAppView?.inAppDisplaySettings?.primaryButtonClickActionUri)
            CastledInApps.sharedInstance.performButtonActionFor(buttonAction: actionButtons.last)
        }
        hideInAppViewFromWindow(withAnimation: true)
    }

    @objc func secondaryButtonClikd(_ sender: UIButton) {
        if let actionButtons = getActionbuttons() {
            CastledInApps.sharedInstance.reportInAppEvent(inappObject: selectedInAppObject!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue, actionType: inAppView?.inAppDisplaySettings?.seondaryButtonClickAction, btnLabel: inAppView?.inAppDisplaySettings?.seondaryButtonTitle, actionUri: inAppView?.inAppDisplaySettings?.seondaryButtonClickActionUri)
            CastledInApps.sharedInstance.performButtonActionFor(buttonAction: actionButtons.first)
        }

        hideInAppViewFromWindow(withAnimation: true)
    }

    @objc func touchesEndedOnContainerView(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended, !isDefaultActionTriggered {
            // Tap gesture ended
            if let inappObject = selectedInAppObject, inappObject.message?.type != CIMessageType.banner, let defaultAction = inappObject.message?.fs?.defaultClickAction ?? inappObject.message?.modal?.defaultClickAction, defaultAction != .none {
                isDefaultActionTriggered = true

                let url = inappObject.message?.modal?.url ?? inappObject.message?.fs?.url ?? ""
                var params = [String: Any]()
                params[CastledConstants.PushNotification.CustomProperties.Category.Action.clickActionUrl] = url
                params[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] = defaultAction.rawValue
                if let keyvals = inappObject.message?.modal?.keyVals ?? inappObject.message?.fs?.keyVals {
                    params[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] = keyvals
                }

                CastledInApps.sharedInstance.reportInAppEvent(inappObject: selectedInAppObject!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue, actionType: defaultAction.rawValue, btnLabel: "", actionUri: url)
                CastledInApps.sharedInstance.performButtonActionFor(webParams: params)
                hideInAppViewFromWindow(withAnimation: true)
            }
        }
    }
}

private extension CastledInAppDisplayViewController {
    func getInappViewFrom(inappAObject: CastledInAppObject) -> ((any CIViewProtocol)?, contanerV: UIView?, htmlString: String?) {
        var inppV: (any CIViewProtocol)?
        var container: UIView?
        var html: String?
        switch inappAObject.message?.type.rawValue {
            case CIMessageType.modal.rawValue:
                container = viewModalContainer
                switch inappAObject.message?.modal?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIModalDefaultView", withType: CIModalDefaultView.self)
                    case CITemplateType.image_buttons.rawValue:
                        break
                    case CITemplateType.text_buttons.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIModalTextAndButtons", withType: CIModalTextAndButtons.self)
                    case CITemplateType.img_text_buttons.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIModalImageBodyAndButtons", withType: CIModalImageBodyAndButtons.self)
                    case CITemplateType.image_only.rawValue:
                        break
                    case CITemplateType.custom_html.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        html = inappAObject.message?.modal?.html

                    default:
                        break
                }
            case CIMessageType.fs.rawValue:
                container = viewFSContainer
                switch inappAObject.message?.fs?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIFsDefaultView", withType: CIFsDefaultView.self)
                    case CITemplateType.image_buttons.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIFsImageAndButtons", withType: CIFsImageAndButtons.self)
                    case CITemplateType.text_buttons.rawValue:
                        break
                    case CITemplateType.image_only.rawValue:
                        break
                    case CITemplateType.custom_html.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        html = inappAObject.message?.fs?.html
                    default:
                        break
                }
            case CIMessageType.banner.rawValue:
                container = viewBannerContainer
                view.restorationIdentifier = "touchdisabled"
                switch inappAObject.message?.banner?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIBannerDefaultView", withType: CIBannerDefaultView.self)
                    case CITemplateType.custom_html.rawValue:
                        inppV = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        html = inappAObject.message?.banner?.html

                    default:
                        break
                }
            default:
                break
        }
        return (inppV, container, html)
    }
}
