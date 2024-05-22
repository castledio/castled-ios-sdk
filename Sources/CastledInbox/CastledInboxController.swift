//
//  CastledInboxController.swift
//  CastledInbox
//
//  Created by antony on 17/05/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal) import Castled

class CastledInboxController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledInboxController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
    }

    private func refreshInbox() async {
        if !CastledInbox.sharedInstance.userId.isEmpty, !isMakingApiCall {
            isMakingApiCall = true
            CastledInboxRepository.fetchInboxItems {
                self.isMakingApiCall = false
            }
        }
    }

    func appBecomeActive() {
        Task {
            await refreshInbox()
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledInbox.sharedInstance.userId = userId
        Task {
            await refreshInbox()
        }
    }

    func onUserLoggedOut() {
        CastledDBManager.shared.clearTables()
        CastledInbox.sharedInstance.userId = ""
    }
}
