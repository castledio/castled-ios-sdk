//
//  CastledConfigs.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation
@objc public class CastledConfigs: NSObject {
    
    @objc public static var sharedInstance = CastledConfigs()
    
    private override init() {
        
    }
    @objc public lazy var instanceId: String = {
        return ""
    }()
    @objc public lazy var permittedBGIdentifier: String = {
        return ""
    }()
    
    @objc public lazy var enablePush = false {
        didSet {
            if enablePush == true{
                Castled.sharedInstance?.registerForPushNotifications()
            }
        }
    }
    
    @objc public lazy var disableLog: Bool = {
        return false
    }()
    
    @objc public lazy var enableInApp: Bool = {
        return false
    }()
    
    @objc public lazy var inAppFetchIntervalSec: Int = {
        return 15*60
    }()
    
    @objc public lazy var location: CastledLocation = {
        return CastledLocation.TEST
    }()
    
}
