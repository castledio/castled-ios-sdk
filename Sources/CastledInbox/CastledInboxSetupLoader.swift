//
//  CastledInboxLoader.swift
//  CastledInbox
//
//  Created by antony on 24/05/2024.
//

@_spi(CastledInternal) import Castled
import Foundation
import UIKit
@_spi(CastledInternalInterface)

@objc public class CastledInboxSetupLoader: NSObject {
    @objc public static let shared = CastledInboxSetupLoader()
    var isLoaded = false
    override private init() {}

    @objc public func start(sourceClass: AnyClass? = nil) {
        guard let fromClass = sourceClass, String(describing: fromClass) == "CastledInboxLoader",!isLoaded else {
            // If it's not the expected class, return without further execution
            return
        }
        isLoaded = true
        observeForCastled()
    }
}

@_spi(CastledInternal)
extension CastledInboxSetupLoader: CastledModuleListener {
    func observeForCastled() {
        CastledModuleInitManager.sharedInstance.addObserver(self)
    }

    public func castledInitialized() {
        // Add initialization logic here
        CastledInbox.sharedInstance.initializeAppInbox()
    }
}
