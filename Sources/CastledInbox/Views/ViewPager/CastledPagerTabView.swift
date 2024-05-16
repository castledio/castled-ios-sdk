//
//  CastledPagerTabView.swift
//  CategoriesTabPOC
//
//  Created by antony on 10/10/2023.
//

import Foundation
import UIKit

class CastledViewPagerTabView: UIView {
    var lblTitle: UILabel?

    var width: CGFloat = 0

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(tab: String, config: CastledViewPagerDisplayConfigs) {
        setupTabView(config: config, tab: tab)
    }

    private func setupTabView(config: CastledViewPagerDisplayConfigs, tab: String) {
        setupTitleLabel(withOptions: config, text: tab)

        setupForAutolayout(view: lblTitle)
        lblTitle?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lblTitle?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lblTitle?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lblTitle?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        let padding: CGFloat = 15.0
        let labelWidth = lblTitle!.intrinsicContentSize.width + 2 * padding
        width = labelWidth
    }

    // MARK: - Helper Method

    private func setupTitleLabel(withOptions options: CastledViewPagerDisplayConfigs, text: String) {
        lblTitle = UILabel()
        lblTitle?.textAlignment = .center
        lblTitle?.textColor = options.tabBarDefaultTextColor
        lblTitle?.numberOfLines = 1
        lblTitle?.adjustsFontSizeToFitWidth = false
        lblTitle?.font = options.tabBarTitletFont
        lblTitle?.text = text
    }

    func addHighlight(config: CastledViewPagerDisplayConfigs) {
        backgroundColor = config.tabBarSelectedColor
        lblTitle?.textColor = config.tabBarSelectedTextColor
    }

    func removeHighlight(config: CastledViewPagerDisplayConfigs) {
        backgroundColor = config.tabBarDefaultColor
        lblTitle?.textColor = config.tabBarDefaultTextColor
    }

    func setupForAutolayout(view: UIView?) {
        guard let v = view else { return }

        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
    }
}
