//
//  CastledInAppController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledInAppController: NSObject, CastledPreferenceStoreListener {
    static var sharedInstance = CastledInAppController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func refreshInapps() {
        print("refreshInapps \(Thread.current)")
        if !CastledInApp.sharedInstance.userId.isEmpty, !isMakingApiCall {
            isMakingApiCall = true
            CastledInAppRepository.fetchInAppItems {
                self.isMakingApiCall = false
            }
        }
    }

    @objc public func appBecomeActive() {
        refreshInapps()
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledInApp.sharedInstance.userId = userId
        refreshInapps()
    }

    func onUserLoggedOut() {}
}
