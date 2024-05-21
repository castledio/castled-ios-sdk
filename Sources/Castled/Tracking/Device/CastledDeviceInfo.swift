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
            CastledLog.castledLog("Device Info already initilized! \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.info)
            return
        }
        isInitilized = true
        CastledRequestHelper.sharedInstance.requestHandlerRegistry[CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue] = CastledDeviceInfoRequestHandler.self
        CastledDeviceInfoController.sharedInstance.initialize()
    }

    func updateDeviceInfo() {
        if !isInitilized {
            return
        }
        CastledDeviceInfoController.sharedInstance.updateDeviceInfo()
    }
}
