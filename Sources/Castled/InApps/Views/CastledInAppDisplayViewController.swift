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

    private var inAppWindow: CastledTouchThroughWindow?
    internal var selectedInAppObject : CastledInAppObject?
    private var isSlideUpInApp = false
    private var autoDismissalWorkItem: DispatchWorkItem?
    var inAppView : (any CIViewProtocol)?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    func showInAppViewControllerFromNotification(inAppObj: CastledInAppObject,inAppDisplaySettings : InAppDisplayConfig) {

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
        guard let window = inAppWindow else{
            return
        }
        selectedInAppObject = inAppObj



        //        let vc112 = CastledCommonClass.loadView(fromNib: "CTCustomView", withType: CTCustomView.self)
        //
        //        let vc11 = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
        //        print(vc11)


        let views = getInappViewFrom(inappAObject: inAppObj)
        inAppView =  views.0
        let containerView = views.1

        if inAppView == nil || containerView == nil{
            return
        }
        containerView?.isHidden = false
        isSlideUpInApp = containerView == viewBannerContainer
        inAppWindow?.shouldPassThrough = isSlideUpInApp //for enabling touch only for banner

        //required properties for population
        inAppView?.parentContainerVC = self
        inAppView?.viewContainer = containerView
        inAppView?.inAppDisplaySettings = inAppDisplaySettings
        inAppView?.selectedInAppObject = selectedInAppObject
        inAppView?.addTheInappViewInContainer(inappView: inAppView as! UIView)



        let inAppParentView = self.view!
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
            
        }) {[weak self] _ in
            self?.view.layoutSubviews()
            CastledInApps.sharedInstance.updateInappEvent(inappObject: inAppObj, eventType: CastledConstants.CastledEventTypes.viewed.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)
            if inAppObj.displayConfig?.autoDismissInterval ?? 0 > 0
            {
                self?.autoDismissalWorkItem?.cancel()
                let requestWorkItem = DispatchWorkItem { [weak self] in
                    self?.hideInAppViewFromWindow(withAnimation: true)
                }
                self?.autoDismissalWorkItem = requestWorkItem
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(inAppObj.displayConfig!.autoDismissInterval),
                                              execute: requestWorkItem)
            }
        }
    }
    
    func hideInAppViewFromWindow(withAnimation : Bool? = true) {
        self.autoDismissalWorkItem?.cancel()
        guard let interstitialView = self.view else {
            return
        }
        if withAnimation == true{
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
                interstitialView.alpha = 0
            }) { [weak self] _ in
                // Remove the interstitial view controller from the view hierarchy
                self?.removeAllViews()
                // Notify the delegate that it should dismiss the interstitial view controller
            }
        }
        else
        {
            removeAllViews()
        }
        
        
    }
    func removeAllViews(){

        inAppWindow?.rootViewController = nil
       // inAppView?.viewContainer?.removeFromSuperview()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        
        inAppWindow?.removeFromSuperview()
        inAppWindow = nil
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if isSlideUpInApp == true{
        //
        //            CastledInApps.sharedInstance.updateInappEvent(inappObject: (selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.discarded.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)
        //
        //            hideInAppViewFromWindow()
        //        }
    }
    
}
extension CastledInAppDisplayViewController{

    fileprivate func getInappViewFrom(inappAObject : CastledInAppObject) -> ((any CIViewProtocol)?,contanerV : UIView?) {

        var inppV : (any CIViewProtocol)?
        var container : UIView?
        switch inappAObject.message?.type.rawValue {
            case CIMessageType.modal.rawValue:
                container = viewModalContainer

                switch inappAObject.message?.modal?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIModalDefaultView", withType: CIModalDefaultView.self)
                        break
                    case CITemplateType.image_buttons.rawValue:
                        break
                    case CITemplateType.text_buttons.rawValue:
                        break
                    case CITemplateType.image_only.rawValue:
                        break
                    case CITemplateType.custom_html.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        break
                    default:
                        break
                }
                break
            case CIMessageType.fs.rawValue:
                container = viewFSContainer

                switch inappAObject.message?.fs?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIFsDefaultView", withType: CIFsDefaultView.self)
                        break
                    case CITemplateType.image_buttons.rawValue:
                        break
                    case CITemplateType.text_buttons.rawValue:
                        break
                    case CITemplateType.image_only.rawValue:
                        break
                    case CITemplateType.custom_html.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        break
                    default:
                        break
                }
                break
            case CIMessageType.banner.rawValue:
                container = viewBannerContainer
                view.restorationIdentifier = "touchdisabled"

                switch inappAObject.message?.banner?.type.rawValue {
                    case CITemplateType.default_template.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIBannerDefaultView", withType: CIBannerDefaultView.self)
                        break
                    case CITemplateType.custom_html.rawValue:
                        inppV  = CastledCommonClass.loadView(fromNib: "CIHTMLView", withType: CIHTMLView.self)
                        break
                    default:
                        break
                }
                break
            default:
                break
        }
//        container = viewBannerContainer
//        inppV  = CastledCommonClass.loadView(fromNib: "CIBannerDefaultView", withType: CIBannerDefaultView.self)

        return (inppV,container)
    }
}


