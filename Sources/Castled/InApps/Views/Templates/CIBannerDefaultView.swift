//
//  CIBannerDefaultView.swift
//  SB
//
//  Created by antony on 03/08/2023.
//

import UIKit

class CIBannerDefaultView: UIView,CIViewProtocol {

    var parentContainerVC: CastledInAppDisplayViewController?
    var selectedInAppObject: CastledInAppObject?
    var inAppDisplaySettings: InAppDisplayConfig?
    var viewContainer: UIView?
    var mainImage : UIImage?

    @IBOutlet weak var btnDetails: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewMain: UIImageView!
    @IBOutlet weak var viewMainContainer: UIView!



    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */



     func configureTheViews() {

        lblTitle.font = inAppDisplaySettings?.slideUpFont.withSize(CGFloat(inAppDisplaySettings!.slideUpFontSize))
        lblTitle.textColor = inAppDisplaySettings?.slideUpFontColor
        viewMainContainer.backgroundColor = inAppDisplaySettings?.slideUpBgColor
        let detailsArrowImage = btnDetails.imageView?.image?.withRenderingMode(.alwaysTemplate)
        btnDetails.setImage(detailsArrowImage, for: .normal)
        btnDetails.tintColor = .black
        viewMainContainer.layer.cornerRadius = 5
        imgViewMain.layer.cornerRadius = 5

        lblTitle.text = inAppDisplaySettings?.slideUpTitle
        //        if let imageUrl = URL(string:inAppDisplaySettings?.imageUrl ?? ""){
        //            imgViewMain.loadImage(from: imageUrl)
        //
        //        }
        imgViewMain.image = mainImage


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
