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
        //  Calling this method with a delay to ensure that the in-app display state value is set if the user sets discard/suspended in-app state at app launch
        perform(#selector(appBecomeActiveWithDelay), with: nil, afterDelay: 0.3)
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

    @objc private func appBecomeActiveWithDelay() {
        Task {
            await refreshInapps(isFromBG: true)
        }
    }
}
