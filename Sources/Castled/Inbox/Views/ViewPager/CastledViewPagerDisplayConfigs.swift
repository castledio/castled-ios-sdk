//
//  CastledViewPagerDisplayConfigs.swift
//  CategoriesTabPOC
//
//  Created by antony on 10/10/2023.
//

import Foundation
import UIKit

class CastledViewPagerDisplayConfigs {
    var isEqualWidth = false
    var disableContainerScroll = true
    var hideTabBar = false

    var tabBarDefaultColor: UIColor = .white
    var tabBarSelectedColor: UIColor = UIColor.white.withAlphaComponent(0.8)
    var tabBarIndicatorBackgroundColor: UIColor = .link

    var tabBarDefaultTextColor: UIColor = .black
    var tabBarSelectedTextColor: UIColor = .black

    var tabBarHeight: CGFloat = 60
    var tabBarTitletFont: UIFont = .systemFont(ofSize: 16, weight: .regular)

    public init() {}
}
