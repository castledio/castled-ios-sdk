//
//  CastledLocationMonitor.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation

class CastledLocationMonitor: NSObject {
    private let locationManager: CLLocationManager
    init(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    func startMonitoringLocation() {
        locationManager.startUpdatingLocation()
        if CastledGeofecerValidations.isSignificantLocationChangeAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            CastledGeofencerUtils.castledLog("Significant location change monitoring is not available on this device", logLevel: .info)
        }
        CastledGeofencerUtils.castledLog("Started monitoring location.", logLevel: .info)
    }

    func stopMonitoingLocation() {
        // locationManager.stopUpdatingLocation()
        if CastledGeofecerValidations.isSignificantLocationChangeAvailable() {
            //   locationManager.stopMonitoringSignificantLocationChanges()
        }
    }
}
