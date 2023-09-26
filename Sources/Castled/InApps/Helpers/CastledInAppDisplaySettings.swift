//
//  CastledInAppDisplayConfigs.swift
//  Castled
//
//  Created by antony on 13/04/2023.
//

import Foundation
import UIKit

class InAppDisplayConfig {
    /**
     Settings for modal and full screen
     */
    lazy var imageUrl: String = {
        ""
    }()

    lazy var title: String = {
        ""
    }()

    lazy var titleFontColor: UIColor = {
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    }()

    lazy var titleBgColor: UIColor = {
        #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)

    }()

    lazy var titleFontSize: Int = {
        18
    }()

    lazy var titleFont: UIFont = {
        UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)

    }()

    lazy var body: String = {
        ""
    }()

    lazy var bodyFontColor: UIColor = {
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    }()

    lazy var bodyBgColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    lazy var bodyFontSize: Int = {
        14
    }()

    lazy var bodyFont: UIFont = {
        UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)

    }()

    lazy var screenOverlayColor: UIColor = {
        #colorLiteral(red: 1, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
    }()

    lazy var buttonFont: UIFont = {
        UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)

    }()

    /**
     Left Button
     */
    lazy var leftButtonTitle: String = {
        ""
    }()

    lazy var leftButtonClickAction: String = {
        ""
    }()

    lazy var leftButtonUri: String = {
        ""
    }()

    lazy var leftButtonColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    lazy var leftButtonFontColor: UIColor = {
        #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)

    }()

    var leftButtonBorderColor: UIColor?

    lazy var leftButtonBorderWidth: Double = {
        1
    }()

    lazy var leftButtonCornerRadius: Int = {
        5
    }()

    /**
     Right Button
     */
    lazy var rightButtonTitle: String = {
        ""
    }()

    lazy var rightButtonClickAction: String = {
        ""
    }()

    lazy var rightButtonUri: String = {
        ""
    }()

    lazy var rightButtonColor: UIColor = {
        #colorLiteral(red: 0.137254902, green: 0.1019607843, blue: 0.3960784314, alpha: 1)

    }()

    lazy var rightButtonFontColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    var rightButtonBorderColor: UIColor?

    lazy var rightButtonBorderWidth: Double = {
        1
    }()

    lazy var rightButtonCornerRadius: Int = {
        5
    }()

    /**
     Settings for Slide Up
     */
    lazy var slideUpTitle: String = {
        ""
    }()

    lazy var slideUpClickAction: String = {
        ""
    }()

    lazy var slideUpUri: String = {
        ""
    }()

    lazy var slideUpBgColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    lazy var slideUpFontSize: Int = {
        16
    }()

    lazy var slideUpFont: UIFont = {
        UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)

    }()

    lazy var slideUpFontColor: UIColor = {
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }()

    func populateConfigurationsFrom(inAppObject: CastledInAppObject) {
        if inAppObject.message?.type.rawValue ==
            CIMessageType.modal.rawValue
        {
            // title
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.titleFontColor ?? "") {
                titleFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.titleBgColor ?? "") {
                titleBgColor = color
            }
            titleFontSize = inAppObject.message?.modal?.titleFontSize ?? 18
            title = inAppObject.message?.modal?.title ?? ""
            body = inAppObject.message?.modal?.body ?? ""
            imageUrl = inAppObject.message?.modal?.imageURL ?? ""

            // body
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.bodyFontColor ?? "") {
                bodyFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.bodyBgColor ?? "") {
                bodyBgColor = color
            }
            bodyFontSize = inAppObject.message?.modal?.bodyFontSize ?? 14

            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.screenOverlayColor ?? "") {
                screenOverlayColor = color
            }

            if let actionButtons = inAppObject.message?.modal?.actionButtons {
                if !actionButtons.isEmpty {
                    leftButtonTitle = actionButtons[0].label
                    leftButtonClickAction = actionButtons[0].clickAction.rawValue
                    leftButtonUri = actionButtons[0].url

                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor) {
                        leftButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor) {
                        leftButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor) {
                        leftButtonBorderColor = color
                    }
                }
                if actionButtons.count > 1 {
                    rightButtonTitle = actionButtons[1].label
                    rightButtonClickAction = actionButtons[1].clickAction.rawValue
                    rightButtonUri = actionButtons[1].url

                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor) {
                        rightButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor) {
                        rightButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor) {
                        rightButtonBorderColor = color
                    }
                }
            }
        } else if inAppObject.message?.type.rawValue == CIMessageType.fs.rawValue {
            // title
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.titleFontColor ?? "") {
                titleFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.titleBgColor ?? "") {
                titleBgColor = color
            }
            titleFontSize = inAppObject.message?.fs?.titleFontSize ?? 18
            title = inAppObject.message?.fs?.title ?? ""
            body = inAppObject.message?.fs?.body ?? ""
            imageUrl = inAppObject.message?.fs?.imageURL ?? ""
            // body
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.bodyFontColor ?? "") {
                bodyFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.bodyBgColor ?? "") {
                bodyBgColor = color
            }
            bodyFontSize = inAppObject.message?.fs?.bodyFontSize ?? 14

            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.screenOverlayColor ?? "") {
                screenOverlayColor = color
            }

            if let actionButtons = inAppObject.message?.fs?.actionButtons {
                if !actionButtons.isEmpty {
                    leftButtonTitle = actionButtons[0].label
                    leftButtonClickAction = actionButtons[0].clickAction.rawValue
                    leftButtonUri = actionButtons[0].url

                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor) {
                        leftButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor) {
                        leftButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor) {
                        leftButtonBorderColor = color
                    }
                }
                if actionButtons.count > 1 {
                    rightButtonTitle = actionButtons[1].label
                    rightButtonClickAction = actionButtons[1].clickAction.rawValue
                    rightButtonUri = actionButtons[1].url

                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor) {
                        rightButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor) {
                        rightButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor) {
                        rightButtonBorderColor = color
                    }
                }
            }

        } else if inAppObject.message?.type.rawValue == CIMessageType.banner.rawValue {
            slideUpTitle = inAppObject.message?.banner?.body ?? ""
            imageUrl = inAppObject.message?.banner?.imageURL ?? ""
            slideUpClickAction = inAppObject.message?.banner?.clickAction.rawValue ?? ""
            slideUpUri = inAppObject.message?.banner?.url ?? ""
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.banner?.bgColor ?? "") {
                slideUpBgColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.banner?.fontColor ?? "") {
                slideUpFontColor = color
            }
            slideUpFontSize = inAppObject.message?.banner?.fontSize ?? 16
        }
    }
}
