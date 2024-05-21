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
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc public func appBecomeActive() {
        for observer in observers {
            observer.appBecomeActive()
        }
        if CastledUserDefaults.shared.userId != nil {
            Castled.sharedInstance.executeBGTasks(isFromBG: true)
        }
    }

    public func addObserver(_ observer: CastledLifeCycleListener) {
        observers.append(observer)
    }
}
