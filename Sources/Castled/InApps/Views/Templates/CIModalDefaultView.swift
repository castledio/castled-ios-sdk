//
//  CIModalDefaultView.swift
//  SB
//
//  Created by antony on 01/08/2023.
//

import UIKit

class CIModalDefaultView: UIView, CIViewProtocol {
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

    @IBOutlet weak var constraintButtonStackHeight: NSLayoutConstraint!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    func configureTheViews() {
        viewChildViewsContainer = viewInppContainer

        updateheaderAndButtonViews()
        parentContainerVC?.view?.backgroundColor = inAppDisplaySettings?.screenOverlayColor
        if btnSeondary!.superview!.isHidden {
            constraintButtonStackHeight.constant = 0
        }
        viewInppContainer?.backgroundColor = viewBodyContainer?.backgroundColor
    }
}
