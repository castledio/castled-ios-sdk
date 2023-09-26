//
//  CastledInboxConfig.swift
//  Castled
//
//  Created by antony on 04/09/2023.
//

import UIKit

@objc public class CastledInboxConfig: NSObject {

    @objc public lazy var backgroundColor: UIColor = {
        return .white
    }()

    @objc public lazy var emptyMessageViewText: String = {
        return "We have no updates. Please check again later."
    }()

    @objc public lazy var emptyMessageViewTextColor: UIColor = {
        return .black
    }()

    @objc public lazy var hideCloseButton: Bool = {
        return false
    }()

    @objc public lazy var loaderTintColor: UIColor = {
        return .gray
    }()

    @objc public lazy var navigationBarBackgroundColor: UIColor = {
        return .white
    }()

    @objc public lazy var navigationBarButtonTintColor: UIColor = {
        return .black
    }()

    @objc public lazy var title: String = {
        return "Inbox"
    }()

}
