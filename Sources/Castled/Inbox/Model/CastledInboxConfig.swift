//
//  CastledInboxConfig.swift
//  Castled
//
//  Created by antony on 04/09/2023.
//

import UIKit

@objc public class CastledInboxConfig: NSObject {
    @objc public lazy var backgroundColor: UIColor = {
        .white
    }()

    @objc public lazy var emptyMessageViewText: String = {
        "We have no updates. Please check again later."
    }()

    @objc public lazy var emptyMessageViewTextColor: UIColor = {
        .black
    }()

    @objc public lazy var hideCloseButton: Bool = {
        false
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

    @objc public lazy var title: String = {
        "Inbox"
    }()
}
