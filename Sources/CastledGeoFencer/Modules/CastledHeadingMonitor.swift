//
//  CastledHeadingMonitor.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation

class CastledHeadingMonitor: NSObject {
    private let locationManager: CLLocationManager
    init(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    func startHeadingMonitoring() {
        // Check if heading updates are available and start monitoring
        if CastledGeofecerValidations.isHeadingAvailable() {
            locationManager.startUpdatingHeading()
            CastledGeofencerUtils.castledLog("Started monitoring heading.", logLevel: .info)

        } else {
            CastledGeofencerUtils.castledLog("Heading updates are not available on this device.", logLevel: .info)
        }
    }

    func stopHeadingMonitoring() {
        if !CastledGeofecerValidations.isHeadingAvailable() {
            return
        }
        // Stop monitoring heading updates
        locationManager.stopUpdatingHeading()
        CastledGeofencerUtils.castledLog("Stopped monitoring heading.", logLevel: .info)
    }
}
