//
//  CastledConfigs.swift
//  Castled
//
//  Created by antony on 28/04/2023.
//

import Foundation
@objc public class CastledConfigs: NSObject {
    
    private static var sharedConfig: CastledConfigs?
    internal var instanceId: String = ""

    // MARK: - initialization method
    @objc public static func initialize(withInstanceId instanceId: String) -> CastledConfigs{
        if let existingConfig = CastledConfigs.sharedConfig {
            existingConfig.instanceId = instanceId
        }
        else{
            CastledConfigs.sharedConfig =  CastledConfigs.init(instanceId: instanceId)
        }
        return CastledConfigs.sharedConfig!
    }

    // MARK: - Supporting properites
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


    // MARK: - Supporting private methods
    private init(instanceId: String){
        self.instanceId = instanceId
        super.init()
        if CastledConfigs.sharedConfig == nil{
            CastledConfigs.sharedConfig = self
        }
    }
    static internal var sharedInstance: CastledConfigs {
        guard let sharedConfig = sharedConfig else {
            fatalError("CastledConfigs has not been initialized. Call CastledConfigs.initialize(instanceId:) first.")
        }
        return sharedConfig
    }


    
}
