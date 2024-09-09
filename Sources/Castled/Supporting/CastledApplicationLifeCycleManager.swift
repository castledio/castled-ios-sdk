//
//  CastledLifeCycleObserver.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit
@_spi(CastledInternal)

public class CastledLifeCycleManager: NSObject {
    public static var sharedInstance = CastledLifeCycleManager()
    private var observers: [CastledLifeCycleListener] = []

    override private init() {}

    func start() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc public func appWillResignActive() {
        CastledUserDefaults.shared.isAppInForeground = false
        for observer in observers {
            if let observerMethod = observer.appWillResignActive {
                observerMethod()
            }
        }
    }

    @objc public func didEnterBackground() {
        CastledUserDefaults.shared.isAppInForeground = false
        for observer in observers {
            if let observerMethod = observer.appDidEnterBackground {
                observerMethod()
            }
        }
    }

    @objc public func appWillEnterForeground() {
        //  CastledUserDefaults.shared.isAppInForeground = true
    }

    @objc public func appDidBecomeActive() {
        CastledUserDefaults.shared.isAppInForeground = true
        for observer in observers {
            observer.appDidBecomeActive()
        }
        if let _ = CastledUserDefaults.shared.userId {
            CastledRetryHandler.shared.retrySendingAllFailedEvents(completion: {})
        }
    }

    public func addObserver(_ observer: CastledLifeCycleListener) {
        observers.append(observer)
    }
}
