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
        UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)

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

    lazy var defaultClickAction: String = {
        ""
    }()

    lazy var defaultClickActionUri: String = {
        ""
    }()

    /**
     Left Button
     */
    lazy var seondaryButtonTitle: String = {
        ""
    }()

    lazy var seondaryButtonClickAction: String = {
        ""
    }()

    lazy var seondaryButtonClickActionUri: String = {
        ""
    }()

    lazy var seondaryButtonColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    lazy var seondaryButtonFontColor: UIColor = {
        #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)

    }()

    var seondaryButtonBorderColor: UIColor?

    lazy var seondaryButtonBorderWidth: Double = {
        1
    }()

    lazy var seondaryButtonCornerRadius: Int = {
        5
    }()

    /**
     Right Button
     */
    lazy var primaryButtonTitle: String = {
        ""
    }()

    lazy var primaryButtonClickAction: String = {
        ""
    }()

    lazy var primaryButtonClickActionUri: String = {
        ""
    }()

    lazy var primaryButtonColor: UIColor = {
        #colorLiteral(red: 0.137254902, green: 0.1019607843, blue: 0.3960784314, alpha: 1)

    }()

    lazy var primaryButtonFontColor: UIColor = {
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    }()

    var primaryButtonBorderColor: UIColor?

    lazy var primaryButtonBorderWidth: Double = {
        1
    }()

    lazy var primaryButtonCornerRadius: Int = {
        5
    }()

    func populateConfigurationsFrom(inAppObject: CastledInAppObject) {
        if let message = inAppObject.message {
            switch message.type {
                case CIMessageType.modal:
                    populateModalWith(message: message)
                case CIMessageType.fs:
                    populateFSWith(message: message)
                case CIMessageType.banner:
                    populateBannerWith(message: message)
            }
        }
    }

    private func populateModalWith(message: CIMessage) {
        // title
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.modal?.titleFontColor ?? "") {
            titleFontColor = color
        }
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.modal?.titleBgColor ?? "") {
            titleBgColor = color
        }
        titleFontSize = message.modal?.titleFontSize ?? 18
        title = message.modal?.title ?? ""
        body = message.modal?.body ?? ""
        imageUrl = message.modal?.imageURL ?? ""

        // body
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.modal?.bodyFontColor ?? "") {
            bodyFontColor = color
        }
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.modal?.bodyBgColor ?? "") {
            bodyBgColor = color
        }
        bodyFontSize = message.modal?.bodyFontSize ?? 14

        if let color = CastledCommonClass.hexStringToUIColor(hex: message.modal?.screenOverlayColor ?? "") {
            screenOverlayColor = color
        }

        if let actionButtons = message.modal?.actionButtons {
            if !actionButtons.isEmpty {
                seondaryButtonTitle = actionButtons[0].label
                seondaryButtonClickAction = actionButtons[0].clickAction.rawValue
                seondaryButtonClickActionUri = actionButtons[0].url

                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor) {
                    seondaryButtonColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor) {
                    seondaryButtonFontColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor) {
                    seondaryButtonBorderColor = color
                }
            }
            if actionButtons.count > 1 {
                primaryButtonTitle = actionButtons[1].label
                primaryButtonClickAction = actionButtons[1].clickAction.rawValue
                primaryButtonClickActionUri = actionButtons[1].url

                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor) {
                    primaryButtonColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor) {
                    primaryButtonFontColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor) {
                    primaryButtonBorderColor = color
                }
            }
        }
    }

    private func populateBannerWith(message: CIMessage) {
        title = message.banner?.body ?? ""
        imageUrl = message.banner?.imageURL ?? ""
        defaultClickAction = message.banner?.clickAction.rawValue ?? ""
        defaultClickActionUri = message.banner?.url ?? ""
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.banner?.bgColor ?? "") {
            titleBgColor = color
        }
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.banner?.fontColor ?? "") {
            titleFontColor = color
        }
        titleFontSize = message.banner?.fontSize ?? 16
    }

    private func populateFSWith(message: CIMessage) {
        // title
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.fs?.titleFontColor ?? "") {
            titleFontColor = color
        }
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.fs?.titleBgColor ?? "") {
            titleBgColor = color
        }
        titleFontSize = message.fs?.titleFontSize ?? 18
        title = message.fs?.title ?? ""
        body = message.fs?.body ?? ""
        imageUrl = message.fs?.imageURL ?? ""
        // body
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.fs?.bodyFontColor ?? "") {
            bodyFontColor = color
        }
        if let color = CastledCommonClass.hexStringToUIColor(hex: message.fs?.bodyBgColor ?? "") {
            bodyBgColor = color
        }
        bodyFontSize = message.fs?.bodyFontSize ?? 14

        if let color = CastledCommonClass.hexStringToUIColor(hex: message.fs?.screenOverlayColor ?? "") {
            screenOverlayColor = color
        }

        if let actionButtons = message.fs?.actionButtons {
            if !actionButtons.isEmpty {
                seondaryButtonTitle = actionButtons[0].label
                seondaryButtonClickAction = actionButtons[0].clickAction.rawValue
                seondaryButtonClickActionUri = actionButtons[0].url

                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor) {
                    seondaryButtonColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor) {
                    seondaryButtonFontColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor) {
                    seondaryButtonBorderColor = color
                }
            }
            if actionButtons.count > 1 {
                primaryButtonTitle = actionButtons[1].label
                primaryButtonClickAction = actionButtons[1].clickAction.rawValue
                primaryButtonClickActionUri = actionButtons[1].url

                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor) {
                    primaryButtonColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor) {
                    primaryButtonFontColor = color
                }
                if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor) {
                    primaryButtonBorderColor = color
                }
            }
        }
    }
}
