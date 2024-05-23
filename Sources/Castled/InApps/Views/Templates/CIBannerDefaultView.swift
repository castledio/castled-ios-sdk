//
//  CIBannerDefaultView.swift
//  SB
//
//  Created by antony on 03/08/2023.
//

import UIKit

class CIBannerDefaultView: UIView, CIViewProtocol {
    @IBOutlet weak var imgMedia: UIImageView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblBody: UILabel?
    @IBOutlet weak var btnPrimary: UIButton?
    @IBOutlet weak var btnSeondary: UIButton?
    @IBOutlet weak var viewButtonContainer: UIView?
    @IBOutlet weak var viewTitleContainer: UIView?
    @IBOutlet weak var viewBodyContainer: UIView?
    @IBOutlet weak var viewInppContainer: UIView?
    var viewParentContainer: UIView?

    var viewChildViewsContainer: UIView?
    var parentContainerVC: CastledInAppDisplayViewController?
    var selectedInAppObject: CastledInAppObject?
    var inAppDisplaySettings: InAppDisplayConfig?

    @IBOutlet weak var btnDetails: UIButton!

    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    func configureTheViews() {
        updateheaderAndButtonViews()

        viewInppContainer?.backgroundColor = inAppDisplaySettings?.titleBgColor
        let detailsArrowImage = btnDetails?.imageView?.image?.withRenderingMode(.alwaysTemplate)
        btnDetails?.setImage(detailsArrowImage, for: .normal)
        btnDetails?.tintColor = .black
        imgMedia?.layer.cornerRadius = 5
    }

    @IBAction func detailsButtonClikd(_ sender: Any) {
        CastledInAppsDisplayController.sharedInstance.reportInAppEvent(inappObject: (parentContainerVC?.selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue, actionType: inAppDisplaySettings?.defaultClickAction, btnLabel: inAppDisplaySettings?.title, actionUri: inAppDisplaySettings?.defaultClickActionUri)
        CastledInAppsDisplayController.sharedInstance.performButtonActionFor(slide: (parentContainerVC?.selectedInAppObject)!.message?.banner)
        parentContainerVC?.hideInAppViewFromWindow()
    }
}
