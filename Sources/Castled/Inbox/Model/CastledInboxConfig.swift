//
//  CastledInboxConfig.swift
//  Castled
//
//  Created by antony on 04/09/2023.
//

import UIKit

@objc public class CastledInboxDisplayConfig: NSObject {
    @objc public lazy var emptyMessageViewText: String = {
        "We have no updates. Please check again later."
    }()

    @objc public lazy var emptyMessageViewTextColor: UIColor = {
        .black
    }()

    @objc public lazy var hideCloseButton: Bool = {
        false
    }()

    @objc public lazy var inboxViewBackgroundColor: UIColor = {
        .white
    }()

    @objc public lazy var loaderTintColor: UIColor = {
        .gray
    }()

    @objc public lazy var navigationBarBackgroundColor: UIColor = {
        .white
    }()

    @objc public lazy var navigationBarButtonTintColor: UIColor = {
        .black
    }()

    @objc public lazy var navigationBarTitle: String = {
        "App Inbox"
    }()

    // MARK: - Tabbar Configuraitions

    @objc public lazy var showCategoriesTab: Bool = {
        true
    }()

    @objc public lazy var tabBarDefaultBackgroundColor: UIColor = {
        .white
    }()

    @objc public lazy var tabBarSelectedBackgroundColor: UIColor = {
        UIColor.white.withAlphaComponent(0.8)
    }()

    @objc public lazy var tabBarDefaultTextColor: UIColor = {
        .black
    }()

    @objc public lazy var tabBarSelectedTextColor: UIColor = {
        .link
    }()

    @objc public lazy var tabBarIndicatorBackgroundColor: UIColor = {
        .link
    }()
}
