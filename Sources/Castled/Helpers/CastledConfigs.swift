//
//  CastledConfigs.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation
public class CastledConfigs {
    
    public static var sharedInstance = CastledConfigs()
    
    private init() {
        
    }
    
    public lazy var permittedBGIdentifier: String = {
        return ""
    }()
    
    public lazy var enablePush = false {
        didSet {
            if enablePush == true{
                Castled.sharedInstance?.registerForPushNotifications()
            }
        }
    }
    
    public lazy var disableLog: Bool = {
        return false
    }()
    
    public lazy var enableInApp: Bool = {
        return false
    }()
    
    public lazy var inAppFetchIntervalSec: Int = {
        return 15*60
    }()
    
    public lazy var location: CastledLocation = {
        return CastledLocation.US
    }()
    
}
