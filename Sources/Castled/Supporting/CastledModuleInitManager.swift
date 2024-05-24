//
//  CastledAppCycleManager.swift
//  Castled
//
//  Created by antony on 24/05/2024.
//

import Foundation
@_spi(CastledInternal)

public class CastledModuleInitManager: NSObject {
    public static var sharedInstance = CastledModuleInitManager()
    private var observers: [CastledModuleListener] = []

    override private init() {}

    public func addObserver(_ observer: CastledModuleListener) {
        observers.append(observer)
    }

    func notifiyListeners() {
        for observer in observers {
            observer.castledInitialized()
        }
    }
}
