//
//  CastledInAppDisplayConfigs.swift
//  Castled
//
//  Created by antony on 13/04/2023.
//

import Foundation
import UIKit

internal class InAppDisplayConfig {
    
    /**
     Settings for modal and full screen
     */
    internal lazy var imageUrl: String = {
        return ""
    }()
    
    internal lazy var title: String = {
        return ""
    }()
    
    internal lazy var titleFontColor: UIColor = {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }()
    
    internal lazy var titleBgColor: UIColor = {
        return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        
    }()
    
    internal lazy var titleFontSize: Int = {
        return 18
    }()
    
    internal lazy var titleFont: UIFont = {
        return UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
    }()
    
    internal lazy var body: String = {
        return ""
    }()
    
    internal lazy var bodyFontColor: UIColor = {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
    }()
    
    internal lazy var bodyBgColor: UIColor = {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }()
    
    internal lazy var bodyFontSize: Int = {
        return 14
    }()
    
    internal lazy var bodyFont: UIFont = {
        return UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        
    }()
    
    internal lazy var screenOverlayColor: UIColor = {
        return #colorLiteral(red: 1, green: 0.9098039216, blue: 0.9098039216, alpha: 1)
    }()
    
    internal lazy var buttonFont: UIFont = {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        
    }()
    /**
     Left Button
     */
    internal lazy var leftButtonTitle: String = {
        return ""
    }()
    
    internal lazy var leftButtonClickAction: String = {
        return ""
    }()
    
    internal lazy var leftButtonUri: String = {
        return ""
    }()
    
    internal lazy var leftButtonColor: UIColor = {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }()
    
    internal lazy var leftButtonFontColor: UIColor = {
        return #colorLiteral(red: 0.4862745098, green: 0.4862745098, blue: 0.4862745098, alpha: 1)
        
    }()
    
    internal var leftButtonBorderColor: UIColor?
    
    internal lazy var leftButtonBorderWidth: Double = {
        return 1
    }()
    
    internal lazy var leftButtonCornerRadius: Int = {
        return 5
    }()
    /**
     Right Button
     */
    internal lazy var rightButtonTitle: String = {
        return ""
    }()
    
    internal lazy var rightButtonClickAction: String = {
        return ""
    }()
    
    internal lazy var rightButtonUri: String = {
        return ""
    }()
    
    internal lazy var rightButtonColor: UIColor = {
        return #colorLiteral(red: 0.137254902, green: 0.1019607843, blue: 0.3960784314, alpha: 1)
        
    }()
    
    internal lazy var rightButtonFontColor: UIColor = {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }()
    
    internal var rightButtonBorderColor: UIColor?
    
    internal lazy var rightButtonBorderWidth: Double = {
        return 1
    }()
    
    internal lazy var rightButtonCornerRadius: Int = {
        return 5
    }()
    /**
     Settings for Slide Up
     */
    internal lazy var slideUpTitle: String = {
        return ""
    }()
    
    internal lazy var slideUpClickAction: String = {
        return ""
    }()
    
    internal lazy var slideUpUri: String = {
        return ""
    }()
    
    internal lazy var slideUpBgColor: UIColor = {
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
    }()
    
    internal lazy var slideUpFontSize: Int = {
        return 16
    }()
    
    internal lazy var slideUpFont: UIFont = {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        
    }()
    
    internal lazy var slideUpFontColor: UIColor = {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }()
    
    internal func populateConfigurationsFrom(inAppObject : CastledInAppObject){
        
        if inAppObject.message?.type.rawValue ==
            CIMessageType.modal.rawValue {
            
            //title
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.titleFontColor ?? "")   {
                
                titleFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.titleBgColor ?? "")   {
                
                titleBgColor = color
            }
            titleFontSize = inAppObject.message?.modal?.titleFontSize ?? 18
            title = inAppObject.message?.modal?.title ?? ""
            body = inAppObject.message?.modal?.body ?? ""
            imageUrl = inAppObject.message?.modal?.imageURL ?? ""
            
            //body
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.bodyFontColor ?? "")   {
                
                bodyFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.bodyBgColor ?? "")   {
                
                bodyBgColor = color
            }
            bodyFontSize = inAppObject.message?.modal?.bodyFontSize ?? 14
            
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.modal?.screenOverlayColor ?? "")   {
                
                screenOverlayColor = color
            }
            
            if let actionButtons = inAppObject.message?.modal?.actionButtons{
                if actionButtons.count > 0{
                    leftButtonTitle = actionButtons[0].label
                    leftButtonClickAction = actionButtons[0].clickAction.rawValue
                    leftButtonUri = actionButtons[0].url
                    
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor)   {
                        
                        leftButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor)   {
                        leftButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor)   {
                        leftButtonBorderColor = color
                    }
                    
                }
                if actionButtons.count > 1{
                    
                    rightButtonTitle = actionButtons[1].label
                    rightButtonClickAction = actionButtons[1].clickAction.rawValue
                    rightButtonUri = actionButtons[1].url
                    
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor)   {
                        
                        rightButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor)   {
                        
                        rightButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor)   {
                        rightButtonBorderColor = color
                    }
                    
                }
            }
        }
        else if inAppObject.message?.type.rawValue == CIMessageType.fs.rawValue {
            //title
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.titleFontColor ?? "")   {
                
                titleFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.titleBgColor ?? "")   {
                
                titleBgColor = color
            }
            titleFontSize = inAppObject.message?.fs?.titleFontSize ?? 18
            title = inAppObject.message?.fs?.title ?? ""
            body = inAppObject.message?.fs?.body ?? ""
            imageUrl = inAppObject.message?.fs?.imageURL ?? ""
            //body
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.bodyFontColor ?? "")   {
                
                bodyFontColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.bodyBgColor ?? "")   {
                
                bodyBgColor = color
            }
            bodyFontSize = inAppObject.message?.fs?.bodyFontSize ?? 14
            
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.fs?.screenOverlayColor ?? "")   {
                
                screenOverlayColor = color
            }
            
            if let actionButtons = inAppObject.message?.fs?.actionButtons{
                if actionButtons.count > 0{
                    
                    leftButtonTitle = actionButtons[0].label
                    leftButtonClickAction = actionButtons[0].clickAction.rawValue
                    leftButtonUri = actionButtons[0].url
                    
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].buttonColor)   {
                        
                        leftButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].fontColor)   {
                        leftButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[0].borderColor)   {
                        leftButtonBorderColor = color
                    }
                    
                }
                if actionButtons.count > 1{
                    rightButtonTitle = actionButtons[1].label
                    rightButtonClickAction = actionButtons[1].clickAction.rawValue
                    rightButtonUri = actionButtons[1].url
                    
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].buttonColor)   {
                        
                        rightButtonColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].fontColor)   {
                        
                        rightButtonFontColor = color
                    }
                    if let color = CastledCommonClass.hexStringToUIColor(hex: actionButtons[1].borderColor)   {
                        rightButtonBorderColor = color
                    }
                    
                }
            }
            
        } else if inAppObject.message?.type.rawValue == CIMessageType.banner.rawValue {
            
            slideUpTitle = inAppObject.message?.banner?.body ?? ""
            imageUrl = inAppObject.message?.banner?.imageURL ?? ""
            slideUpClickAction = inAppObject.message?.banner?.clickAction.rawValue ?? ""
            slideUpUri = inAppObject.message?.banner?.url ?? ""
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.banner?.bgColor ?? "")   {
                
                slideUpBgColor = color
            }
            if let color = CastledCommonClass.hexStringToUIColor(hex: inAppObject.message?.banner?.fontColor ?? "")   {
                
                slideUpFontColor = color
            }
            slideUpFontSize = inAppObject.message?.banner?.fontSize ?? 16
        }
    }
}
