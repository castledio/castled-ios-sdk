//
//  CastledDeviceInfo.swift
//  Castled
//
//  Created by antony on 01/11/2023.
//

import UIKit

class CastledDeviceInfo: NSObject {
    static let sharedInstance = CastledDeviceInfo()
    var userId = ""
    private var isInitilized = false

    override private init() {}
    func initializeDeviceInfo() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("Device Info initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Device Info already initialized..", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue, handler: CastledDeviceInfoRequestHandler.self)
        isInitilized = true
        CastledDeviceInfoController.sharedInstance.initialize()
    }

    func updateDeviceInfo() {
        if !isInitilized {
            return
        }
        CastledDeviceInfoController.sharedInstance.updateDeviceInfo()
    }
}
