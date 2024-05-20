//
//  CastledInboxController.swift
//  CastledInbox
//
//  Created by antony on 17/05/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal) import Castled

class CastledInboxController: NSObject, CastledPreferenceStoreListener {
    static var sharedInstance = CastledInboxController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func refreshInbox() {
        print("refreshInbox \(Thread.current)")
        if !CastledInbox.sharedInstance.userId.isEmpty, !isMakingApiCall {
            isMakingApiCall = true
            CastledInboxRepository.fetchInboxItems {
                self.isMakingApiCall = false
            }
        }
    }

    @objc public func appBecomeActive() {
        refreshInbox()
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledInbox.sharedInstance.userId = userId
        refreshInbox()
    }

    func onUserLoggedOut() {}
}
