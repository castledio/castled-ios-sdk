//
//  CIViewProtocol.swift
//  Castled-iOS-SDK
//
//  Created by antony on 03/08/2023.
//

import Foundation
import UIKit

protocol CIViewProtocol {
    var parentContainerVC: CastledInAppDisplayViewController? { get set }
    var viewParentContainer: UIView? { get set } // this vwill inside CastledInAppDisplayViewController

    var lblTitle: UILabel? { get set }
    var lblBody: UILabel? { get set }
    var btnPrimary: UIButton? { get set }
    var btnSeondary: UIButton? { get set }
    var imgMedia: UIImageView? { get set }
    var viewButtonContainer: UIView? { get set }
    var viewTitleContainer: UIView? { get set }
    var viewBodyContainer: UIView? { get set }
    var viewInppContainer: UIView? { get set }

    var viewChildViewsContainer: UIView? { get set }
    var selectedInAppObject: CastledInAppObject? { get set }
    var inAppDisplaySettings: InAppDisplayConfig? { get set }
    func configureTheViews()
    func addTheInappViewInContainer(inappView view: UIView)
    func updateheaderAndButtonViews()
}

extension CIViewProtocol {
    func addTheInappViewInContainer(inappView view: UIView) {
        guard let contianer = viewParentContainer else {
            return
        }
        contianer.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contianer.topAnchor),
            view.leadingAnchor.constraint(equalTo: contianer.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contianer.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contianer.trailingAnchor)
        ])

        configureTheViews()
    }

    func updateheaderAndButtonViews() {
        if let lblTitle = lblTitle {
            lblTitle.numberOfLines = 3
            var alignment = NSTextAlignment.center
            if let inapp = selectedInAppObject, inapp.message?.type == CIMessageType.banner {
                alignment = NSTextAlignment.left
            }
            lblTitle.attributedText = getAttributedString(title: inAppDisplaySettings!.title,
                                                          textColr: inAppDisplaySettings!.titleFontColor,
                                                          font: inAppDisplaySettings!.titleFont.withSize(CGFloat(inAppDisplaySettings!.titleFontSize)), alignment: alignment)
        }
        if let lblBody = lblBody {
            lblBody.numberOfLines = 5
            if let inapp = selectedInAppObject, inapp.message?.type == CIMessageType.fs {
                lblBody.numberOfLines = 10
            }
            lblBody.attributedText = getAttributedString(title: inAppDisplaySettings!.body,
                                                         textColr: inAppDisplaySettings!.bodyFontColor,
                                                         font: inAppDisplaySettings!.bodyFont.withSize(CGFloat(inAppDisplaySettings!.bodyFontSize)), alignment: .center)
        }
        if let btnSecondary = btnSeondary { // left button
            btnSecondary.titleLabel?.font = inAppDisplaySettings?.buttonFont.withSize(CGFloat(min(inAppDisplaySettings!.titleFontSize, 16)))
            btnSecondary.setTitleColor(inAppDisplaySettings?.seondaryButtonFontColor, for: .normal)
            btnSecondary.backgroundColor = inAppDisplaySettings?.seondaryButtonColor
            if let color = inAppDisplaySettings?.seondaryButtonBorderColor {
                btnSecondary.layer.borderColor = color.cgColor
                btnSecondary.layer.borderWidth = CGFloat(inAppDisplaySettings!.seondaryButtonBorderWidth)
                btnSecondary.layer.cornerRadius = CGFloat(inAppDisplaySettings!.seondaryButtonCornerRadius)
            }
            btnSecondary.setTitle(inAppDisplaySettings?.seondaryButtonTitle, for: .normal)
            btnSecondary.isHidden = inAppDisplaySettings?.seondaryButtonTitle.count == 0 ? true : false
            btnSecondary.superview!.isHidden = btnSecondary.isHidden
            if let parentVC = parentContainerVC {
                btnSecondary.addTarget(parentVC, action: #selector(parentVC.secondaryButtonClikd(_:)),
                                       for: .touchUpInside)
            }
        }
        if let btnPrimary = btnPrimary { // right button
            btnPrimary.titleLabel?.font = btnSeondary?.titleLabel?.font
            btnPrimary.setTitleColor(inAppDisplaySettings?.primaryButtonFontColor, for: .normal)
            btnPrimary.backgroundColor = inAppDisplaySettings?.primaryButtonColor
            btnPrimary.setTitle(inAppDisplaySettings?.primaryButtonTitle, for: .normal)
            btnPrimary.isHidden = inAppDisplaySettings?.primaryButtonTitle.count == 0 ? true : false
            if let color = inAppDisplaySettings?.primaryButtonBorderColor {
                btnPrimary.layer.borderColor = color.cgColor
                btnPrimary.layer.borderWidth = CGFloat(inAppDisplaySettings!.primaryButtonBorderWidth)
                btnPrimary.layer.cornerRadius = CGFloat(inAppDisplaySettings!.primaryButtonCornerRadius)
            }
            if let parentVC = parentContainerVC {
                btnPrimary.addTarget(parentVC, action: #selector(parentVC.primaryButtonClikd(_:)),
                                     for: .touchUpInside)
            }
        }
        if let imgMedia = imgMedia {
            imgMedia.loadImage(from: inAppDisplaySettings?.imageUrl)
        }
        if let viewMainContainer = viewInppContainer {
            viewMainContainer.layer.cornerRadius = 10
        }
        if let viewTitleContainer = viewTitleContainer {
            viewTitleContainer.backgroundColor = inAppDisplaySettings?.titleBgColor
        }
        if let viewDetailContainer = viewBodyContainer {
            viewDetailContainer.backgroundColor = inAppDisplaySettings?.bodyBgColor
            viewButtonContainer?.backgroundColor = viewDetailContainer.backgroundColor
        }
    }

    private func getAttributedString(title: String, textColr: UIColor, font: UIFont, alignment: NSTextAlignment) -> NSMutableAttributedString {
        let fullString = title

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight

        let attributes = [NSAttributedString.Key.foregroundColor: textColr as Any, .font: font as Any, NSAttributedString.Key.paragraphStyle: paragraphStyle]
        let attrString = NSMutableAttributedString(string: fullString, attributes: attributes as [NSMutableAttributedString.Key: Any])

        return attrString
    }
}
