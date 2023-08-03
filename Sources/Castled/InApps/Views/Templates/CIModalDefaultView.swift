//
//  CIModalDefaultView.swift
//  SB
//
//  Created by antony on 01/08/2023.
//

import UIKit

class CIModalDefaultView : UIView,CIViewProtocol {

    var parentContainerVC: CastledInAppDisplayViewController?
    var selectedInAppObject: CastledInAppObject?
    var inAppDisplaySettings: InAppDisplayConfig?
    var viewContainer: UIView?
    var mainImage : UIImage?
    
    @IBOutlet weak var viewMainContainer: UIView!
    @IBOutlet weak var viewImageContainer: UIView!
    @IBOutlet weak var imgViewMain: UIImageView!
    @IBOutlet weak var viewTitleContainer: UIView!
    @IBOutlet weak var lblMessageTitle: UILabel!
    @IBOutlet weak var viewDetailContainer: UIView!
    @IBOutlet weak var lblMessageSubTitle: UILabel!
    @IBOutlet weak var constraintActionButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var viewActionButtonContainer: UIView!
    @IBOutlet weak var btnLeftOfView: UIButton!
    @IBOutlet weak var btnRightOfView: UIButton!

    var titleString = ""
    override func awakeFromNib() {
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    func setupViews(){
        self.lblMessageTitle.text = titleString
        
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

    func configureTheViews() {


        lblMessageTitle.font = inAppDisplaySettings?.titleFont.withSize(CGFloat(inAppDisplaySettings!.titleFontSize))
        lblMessageSubTitle.font = inAppDisplaySettings?.bodyFont.withSize(CGFloat(inAppDisplaySettings!.bodyFontSize))
        btnLeftOfView.titleLabel?.font = inAppDisplaySettings?.buttonFont.withSize(CGFloat(inAppDisplaySettings!.bodyFontSize - 1))
        btnRightOfView.titleLabel?.font = btnLeftOfView.titleLabel?.font

        viewMainContainer.layer.cornerRadius = 5
        lblMessageTitle.textColor = inAppDisplaySettings?.titleFontColor
        lblMessageSubTitle.textColor = inAppDisplaySettings?.bodyFontColor
        btnLeftOfView.setTitleColor(inAppDisplaySettings?.leftButtonFontColor, for: .normal)
        btnLeftOfView.backgroundColor = inAppDisplaySettings?.leftButtonColor
        btnRightOfView.setTitleColor(inAppDisplaySettings?.rightButtonFontColor, for: .normal)
        btnRightOfView.backgroundColor = inAppDisplaySettings?.rightButtonColor
        viewTitleContainer.backgroundColor = inAppDisplaySettings?.titleBgColor
        viewDetailContainer.backgroundColor = inAppDisplaySettings?.bodyBgColor
        viewActionButtonContainer.backgroundColor = viewDetailContainer.backgroundColor
        parentContainerVC?.view?.backgroundColor = inAppDisplaySettings?.screenOverlayColor


        imgViewMain.image = mainImage


        if let color = inAppDisplaySettings?.leftButtonBorderColor{
            btnLeftOfView.layer.borderColor = color.cgColor
            btnLeftOfView.layer.borderWidth = CGFloat(inAppDisplaySettings!.leftButtonBorderWidth)
            btnLeftOfView.layer.cornerRadius = CGFloat(inAppDisplaySettings!.leftButtonCornerRadius)

        }

        if let color = inAppDisplaySettings?.rightButtonBorderColor{
            btnRightOfView.layer.borderColor = color.cgColor
            btnRightOfView.layer.borderWidth = CGFloat(inAppDisplaySettings!.rightButtonBorderWidth)
            btnRightOfView.layer.cornerRadius = CGFloat(inAppDisplaySettings!.rightButtonCornerRadius)

        }

        lblMessageTitle.text = inAppDisplaySettings?.title
        lblMessageSubTitle.text = inAppDisplaySettings?.body

        btnLeftOfView.setTitle(inAppDisplaySettings?.leftButtonTitle, for: .normal)
        btnRightOfView.setTitle(inAppDisplaySettings?.rightButtonTitle, for: .normal)

    }

    @IBAction func hideInAppView(_ sender: Any) {


        CastledInApps.sharedInstance.updateInappEvent(inappObject: (selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.discarded.rawValue, actionType: nil, btnLabel: nil, actionUri: nil)

        parentContainerVC?.hideInAppViewFromWindow(withAnimation: true)


    }

    @IBAction func rightButtonClikdAction(_ sender: Any) {

        CastledInApps.sharedInstance.updateInappEvent(inappObject: (selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue,actionType: inAppDisplaySettings?.rightButtonClickAction, btnLabel:inAppDisplaySettings?.rightButtonTitle, actionUri: inAppDisplaySettings?.rightButtonUri)
        CastledInApps.sharedInstance.performButtonActionFor(buttonAction:selectedInAppObject?.message?.modal?.actionButtons.last)

        parentContainerVC?.hideInAppViewFromWindow(withAnimation: true)


    }

    @IBAction func leftButtonClikdAction(_ sender: Any) {
        CastledInApps.sharedInstance.updateInappEvent(inappObject: (selectedInAppObject)!, eventType: CastledConstants.CastledEventTypes.cliked.rawValue,actionType: inAppDisplaySettings?.leftButtonClickAction, btnLabel:inAppDisplaySettings?.leftButtonTitle, actionUri: inAppDisplaySettings?.leftButtonUri)
        CastledInApps.sharedInstance.performButtonActionFor(buttonAction:selectedInAppObject?.message?.modal?.actionButtons.first)

        parentContainerVC?.hideInAppViewFromWindow(withAnimation: true)
    }
}


