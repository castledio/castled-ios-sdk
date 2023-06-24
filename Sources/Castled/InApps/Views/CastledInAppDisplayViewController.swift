//
//  CastledBaseViewController.swift
//  Castled
//
//  Created by Castled Data on 12/12/2022.
//

import UIKit

class CastledInAppDisplayViewController: UIViewController {
    
    private var inAppWindow: CastledTouchThroughWindow?
    internal var selectedInAppObject : CastledInAppObject?
    private var childViewFrame : CGRect?
    private weak var castledChildViewController : UIViewController?
    private var isSlideUpInApp = false
    private var autoDismissalWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func instantiateFromNib<T: UIViewController>(vc : T.Type) -> T {
        //        return T.init(nibName: String(describing: T.self), bundle:Bundle(identifier:"com.castled.pusherswift.Castled"))
        
        return T.init(nibName: String(describing: T.self), bundle:Bundle.resourceBundle(for: Self.self))
    }
    
    func showInAppViewControllerFromNotification(inAppObj: CastledInAppObject,inAppDisplaySettings : InAppDisplayConfig,image : UIImage) {
        selectedInAppObject = inAppObj
        var childVC : UIViewController?
        
        if selectedInAppObject?.message?.type.rawValue == CIMessageType.modal.rawValue {
            
            let vc = instantiateFromNib(vc: CastledInAppModalViewController.self)
            vc.parentContainerVC = self
            vc.inAppDisplaySettings = inAppDisplaySettings
            vc.mainImage = image
            
            childVC = vc
            
            childViewFrame = CGRect(x: 20, y: 20, width: 200, height: 200)
        }
        else if selectedInAppObject?.message?.type.rawValue == CIMessageType.fs.rawValue {
            let vc = instantiateFromNib(vc: CastledInAppFullScreenViewController.self)
            vc.parentContainerVC = self
            vc.inAppDisplaySettings = inAppDisplaySettings
            vc.mainImage = image
            
            childVC = vc
            
            
            
        } else if selectedInAppObject?.message?.type.rawValue == CIMessageType.banner.rawValue {
            let vc = instantiateFromNib(vc: CastledInAppFooterViewController.self)
            vc.parentContainerVC = self
            vc.inAppDisplaySettings = inAppDisplaySettings
            vc.mainImage = image
            childVC = vc
            isSlideUpInApp = true
        }
        
        guard let castledChildVC = childVC else{
            
            return
        }
        
        castledChildViewController = castledChildVC
        
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
            castledChildViewController = nil
            return
        }
        inAppWindow?.shouldPassThrough = isSlideUpInApp
        
        /* if isSlideUpInApp == true{
         
         if #available(iOS 13.0, *) {
         let height = 120
         let  bottomPadding = Int(inAppWindow?.safeAreaInsets.bottom ?? 0)
         let calculatedYpos = CGFloat(Int((inAppWindow?.bounds.height ?? 0)) - Int(bottomPadding) - height)
         inAppWindow?.frame = CGRect(x: (inAppWindow?.bounds.origin.x)!, y: calculatedYpos , width: (inAppWindow?.bounds.size.width)!, height: CGFloat(height))
         
         }
         
         }*/
        let inAppParentView = self.view!
        inAppParentView.backgroundColor = .clear
        inAppParentView.frame = window.bounds
        
        addChild(castledChildViewController!)
        castledChildViewController!.view.frame = window.bounds
        view.addSubview(castledChildViewController!.view)
        castledChildViewController!.didMove(toParent: self)
        
        window.backgroundColor = .clear
        window.windowLevel = .alert
        window.isHidden = false
        window.makeKeyAndVisible()
        window.rootViewController = self
        window.makeKeyAndVisible()
        
        inAppParentView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            inAppParentView.alpha = 1
            
        }) {[weak self] _ in
            self?.castledChildViewController?.view.layoutSubviews()
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
        
        castledChildViewController?.removeFromParent()
        castledChildViewController?.view.removeFromSuperview()
        castledChildViewController?.willMove(toParent: nil)
        castledChildViewController = nil
        
        inAppWindow?.rootViewController = nil
        
        
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

extension Bundle {
    
    static func resourceBundle(for bundleClass: AnyClass) -> Bundle {
        
        let mainBundle = Bundle.main
        let sourceBundle = Bundle(for: bundleClass)
        guard let moduleName = String(reflecting: bundleClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(bundleClass)")
        }
        // SPM
        var bundle: Bundle?
        if let bundlePath = mainBundle.path(forResource: "\(bundleClass)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(moduleName)_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "castled-ios-sdk_Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "castled-ios-sdk_CastledNotificationContent", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = sourceBundle.path(forResource: "\(bundleClass)-Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = sourceBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        else if bundle == nil,let bundlePath = mainBundle.path(forResource: "Castled", ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        // CocoaPods (static)
        else if bundle == nil, let staticBundlePath = mainBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: staticBundlePath)
        }
        
        // CocoaPods (framework)
        else if bundle == nil, let frameworkBundlePath = sourceBundle.path(forResource: moduleName, ofType: "bundle") {
            bundle = Bundle(path: frameworkBundlePath)
        }
        return bundle ?? sourceBundle
    }
}


