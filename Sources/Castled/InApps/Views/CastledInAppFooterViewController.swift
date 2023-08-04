//
//  CastledInAppFooterViewController.swift
//  Castled
//
//  Created by Faisal Azeez on 12/12/2022.
//

import UIKit

class CastledInAppFooterViewController: UIViewController {
    var parentContainerVC: CastledInAppDisplayViewController?
    var inAppDisplaySettings : InAppDisplayConfig?

    @IBOutlet weak var imgClose: UIImageView!
    @IBOutlet weak var btnDetails: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewMain: UIImageView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnCloseView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    /**
     Popultaing the contents and UI
     */
    private func setupViews() {
        
        lblTitle.font = inAppDisplaySettings?.slideUpFont.withSize(CGFloat(inAppDisplaySettings!.slideUpFontSize))
        lblTitle.textColor = inAppDisplaySettings?.slideUpFontColor
        viewContainer.backgroundColor = inAppDisplaySettings?.slideUpBgColor
        let detailsArrowImage = btnDetails.imageView?.image?.withRenderingMode(.alwaysTemplate)
        btnDetails.setImage(detailsArrowImage, for: .normal)
        btnDetails.tintColor = .black
        viewContainer.layer.cornerRadius = 5
        imgViewMain.layer.cornerRadius = 5
        
        lblTitle.text = inAppDisplaySettings?.slideUpTitle
        //        if let imageUrl = URL(string:inAppDisplaySettings?.imageUrl ?? ""){
        //            imgViewMain.loadImage(from: imageUrl)
        //
        //        }
        imgViewMain.loadImage(from: inAppDisplaySettings?.imageUrl)

        let closeImage = imgClose.image?.withRenderingMode(.alwaysTemplate)
        imgClose.image = closeImage
        imgClose.tintColor = .white
        imgClose.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        imgClose.layer.cornerRadius = imgClose.frame.size.height/2
        imgClose.addShadow(radius: 5, opacity: 0.6, offset: CGSize(width: 0, height: 2), color: UIColor.black)
    }
    
    @IBAction func hideInAppView(_ sender: Any) {
        
        
        CastledInApps.sharedInstance.updateInappEvent(inappObject: (parentContainerVC?.selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.discarded.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)
        
        parentContainerVC?.hideInAppViewFromWindow(withAnimation: true)
    }
    
    @IBAction func detailsButtonClikd(_ sender: Any) {
        
        CastledInApps.sharedInstance.updateInappEvent(inappObject: (parentContainerVC?.selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue,actionType: inAppDisplaySettings?.slideUpClickAction, btnLabel:inAppDisplaySettings?.slideUpTitle, actionUri: inAppDisplaySettings?.slideUpUri)
        CastledInApps.sharedInstance.performButtonActionFor(slide: (parentContainerVC?.selectedInAppObject)!.message?.banner)
        
        parentContainerVC?.hideInAppViewFromWindow()
    }
}
