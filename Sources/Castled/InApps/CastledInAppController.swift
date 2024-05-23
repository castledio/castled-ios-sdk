//
//  CastledInAppController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledInAppController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledInAppController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
    }

    private func refreshInapps(isFromBG: Bool) async {
        if !CastledUserDefaults.shared.isAppInForeground {
            return
        }
        if !CastledInApp.sharedInstance.userId.isEmpty, !isMakingApiCall {
            isMakingApiCall = true
            CastledInAppRepository.fetchInAppItems {
                self.isMakingApiCall = false
                if isFromBG {
                    CastledInApp.sharedInstance.logAppOpenedEventIfAny()
                }
            }
        }
    }

    func appDidBecomeActive() {
        Task {
            await refreshInapps(isFromBG: true)
        }
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledInApp.sharedInstance.userId = userId
        Task {
            await refreshInapps(isFromBG: false)
        }
    }

    func onUserLoggedOut() {
        CastledInApp.sharedInstance.userId = ""
    }
}
