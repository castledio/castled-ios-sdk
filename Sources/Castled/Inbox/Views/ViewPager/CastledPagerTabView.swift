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

    func setup(tab: CastledViewPagerTabItem, options: CastledViewPagerDisplayConfigs) {
        setupTabView(options: options, tab: tab)
    }

    private func setupTabView(options: CastledViewPagerDisplayConfigs, tab: CastledViewPagerTabItem) {
        setupTitleLabel(withOptions: options, text: tab.title)

        setupForAutolayout(view: lblTitle)
        lblTitle?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        lblTitle?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        lblTitle?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        lblTitle?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        let padding: CGFloat = 15.0
        let labelWidth = lblTitle!.intrinsicContentSize.width + 2 * padding
        width = labelWidth
    }

    // MARK: - Helpers

    private func setupTitleLabel(withOptions options: CastledViewPagerDisplayConfigs, text: String) {
        lblTitle = UILabel()
        lblTitle?.textAlignment = .center
        lblTitle?.textColor = options.tabBarDefaultTextColor
        lblTitle?.numberOfLines = 2
        lblTitle?.adjustsFontSizeToFitWidth = true
        lblTitle?.font = options.tabBarTitletFont
        lblTitle?.text = text
    }

    func addHighlight(options: CastledViewPagerDisplayConfigs) {
        backgroundColor = options.tabBarSelectedColor
        lblTitle?.textColor = options.tabBarSelectedTextColor
    }

    func removeHighlight(options: CastledViewPagerDisplayConfigs) {
        backgroundColor = options.tabBarDefaultColor
        lblTitle?.textColor = options.tabBarDefaultTextColor
    }

    func setupForAutolayout(view: UIView?) {
        guard let v = view else { return }

        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
    }
}
