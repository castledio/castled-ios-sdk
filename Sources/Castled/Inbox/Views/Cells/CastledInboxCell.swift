//
//  CastledInboxCell.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import SDWebImage
import UIKit

@objc public protocol CastledInboxCellDelegate {
    @objc func didSelectedInboxWith(_ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem)
}

class CastledInboxCell: UITableViewCell {
    static let castledInboxImageAndTitleCell = "CastledInboxImageAndTitleCell"
    var delegate: CastledInboxCellDelegate?
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgBannerLogo: UIImageView!
    @IBOutlet weak var viewLabelContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewIsRead: UIView!
    @IBOutlet weak var viewButtonContainer: UIView!
    @IBOutlet weak var btnLink1: UIButton!
    @IBOutlet weak var imgLinkSeperator: UIImageView!
    @IBOutlet weak var btnLink2: UIButton!
    @IBOutlet weak var btnLink3: UIButton!
    @IBOutlet weak var imgBottomLine: UIImageView!
    @IBOutlet weak var constraintImageHeightRatio: NSLayoutConstraint!
    @IBOutlet weak var constraintButtonContainerHeight: NSLayoutConstraint!
    private var inboxItem: CAppInbox?
    private var actualCoverImageRatioConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        // Initialization code
    }

    func setupViews() {
        actualCoverImageRatioConstraint = constraintImageHeightRatio
        selectionStyle = .none
        viewIsRead.layer.cornerRadius = viewIsRead.frame.size.height / 2
        imgBannerLogo.layer.cornerRadius = 5
        viewContainer.layer.cornerRadius = 10
        viewContainer.layer.masksToBounds = true

        applyShadow(radius: viewContainer.layer.cornerRadius)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCellWith(_ inboxObj: CAppInbox) {
        inboxItem = inboxObj
        viewContainer.backgroundColor = inboxObj.colorContainer
        lblTitle.textColor = inboxObj.colorTitle
        lblDescription.textColor = inboxObj.colorBody
        lblTime.textColor = lblDescription.textColor
        lblTitle.text = inboxObj.title
        lblDescription.text = inboxObj.body
        lblTime.text = inboxObj.addedDate.timeAgo()
        viewIsRead.superview?.isHidden = inboxObj.isRead

        let urlImageString = inboxObj.imageUrl
        var multiplier = inboxObj.aspectRatio
        var imageView: UIImageView?

        switch inboxObj.inboxType {
            case .messageWithMedia:
                imageView = imgCover
                imgCover.isHidden = false
                imgBannerLogo.superview?.isHidden = true
            case .messageBanner:
                multiplier = 0.0
                imageView = imgBannerLogo
                imgCover.isHidden = true
                imgBannerLogo.superview?.isHidden = false

            case .messageBannerNoIcon:
                multiplier = 0.0
                imageView = imgBannerLogo
                imgCover.isHidden = true
                imgBannerLogo.superview?.isHidden = true

            case .other:
                break
        }

        let newConstraint = actualCoverImageRatioConstraint!.constraintWithMultiplier(CGFloat(multiplier))
        imgCover.removeConstraint(constraintImageHeightRatio)
        imgCover.addConstraint(newConstraint)
        constraintImageHeightRatio = newConstraint

        let placeholderImage = UIImage(named: "castled_placeholder", in: Bundle.resourceBundle(for: CastledInboxCell.self), compatibleWith: nil)
        if !urlImageString.isEmpty, let url = URL(string: urlImageString) {
            imageView?.sd_setImage(with: url, placeholderImage: placeholderImage)
        } else {
            imageView?.image = placeholderImage
        }

        configureButtons()
    }

    private func configureButtons() {
        let buttonCount = inboxItem?.actionButtonsArray.count ?? 0
        if buttonCount == 0 {
            constraintButtonContainerHeight.constant = 0
            viewButtonContainer.isHidden = true
        } else {
            constraintButtonContainerHeight.constant = 50
            viewButtonContainer.isHidden = false
        }
        btnLink1.isHidden = buttonCount < 1
        btnLink2.isHidden = buttonCount < 2
        btnLink3.isHidden = buttonCount < 3
        btnLink1.removeTarget(nil, action: nil, for: .allEvents)
        btnLink2.removeTarget(nil, action: nil, for: .allEvents)
        btnLink3.removeTarget(nil, action: nil, for: .allEvents)

        for tg in 0 ..< buttonCount {
            if let button = btnLink1.superview?.viewWithTag(10 + tg) as? UIButton {
                button.setTitle(inboxItem?.actionButtonsArray[tg]["label"] as? String ?? "", for: .normal)
                button.backgroundColor = CastledCommonClass.hexStringToUIColor(hex: (inboxItem?.actionButtonsArray[tg]["buttonColor"] as? String ?? "")) ?? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                let titleColor = CastledCommonClass.hexStringToUIColor(hex: (inboxItem?.actionButtonsArray[tg]["fontColor"] as? String ?? "")) ?? #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                button.setTitleColor(titleColor, for: .normal)
            }
        }
        btnLink1.addTarget(self, action: #selector(actionButtonClicked),
                           for: .touchUpInside)
        btnLink2.addTarget(self, action: #selector(actionButtonClicked),
                           for: .touchUpInside)
        btnLink3.addTarget(self, action: #selector(actionButtonClicked),
                           for: .touchUpInside)
    }

    @objc private func actionButtonClicked(sender: UIButton) {
        delegate?.didSelectedInboxWith(inboxItem?.actionButtonsArray[sender.tag - 10], CastledInboxResponseConverter.convertToInboxItem(appInbox: inboxItem!))
    }
}
