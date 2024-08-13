//
//  CastledGeoFencer.swift
//  CastledGeoFencer
//
//  Created by antony on 08/08/2024.
//

@_spi(CastledInternal) import Castled
import Foundation
import UIKit

@objc public class CastledGeoFencer: NSObject {
    @objc public static var sharedInstance = CastledGeoFencer()

    var userId = ""
    var enableGeofencing: Bool { CastledShared.sharedInstance.getCastledConfig().enableGeofencing }
    var instanceId: String { CastledShared.sharedInstance.getCastledConfig().instanceId }

    var isInitilized = false

    override private init() {}

    func initializeGeofencing() {
        if !enableGeofencing {
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Geofencer module already initialized..", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.geoFencingRequest.rawValue, handler: CastledGeoFencerRequestHandler.self)

        CastledGeoFencerController.sharedInstance.initialize()
        isInitilized = true
        CastledLog.castledLog("Geofencer module initialized..", logLevel: CastledLogLevel.info)
    }

    private func isValidated() -> Bool {
        if !enableGeofencing {
            CastledLog.castledLog("Geofencer operation failed: \(CastledExceptionMessages.appInboxDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
//        else if userId.isEmpty {
//            CastledLog.castledLog("Geofencer operation failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
//            return false
//        }
        else if !isInitilized {
            CastledLog.castledLog("Geofencer operation failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }

        return true
    }

    @objc public func startGeofenceMonitoring() {
        if !isValidated() {
            return
        }
        CastledGeoFencerController.sharedInstance.startGeofenceMonitoring()
    }

    @objc public func stopGeofenceMonitoring() {
        if !isValidated() {
            return
        }
        CastledGeoFencerController.sharedInstance.stopGeofenceMonitoring()
    }

    @objc public func requestAlwaysAuthorization() {
        if !isValidated() {
            return
        }
        CastledGeoFencerController.sharedInstance.requestAlwaysAuthorization()
    }

    @objc public func requestWhenInUseAuthorization() {
        if !isValidated() {
            return
        }
        CastledGeoFencerController.sharedInstance.requestWhenInUseAuthorization()
    }
}
