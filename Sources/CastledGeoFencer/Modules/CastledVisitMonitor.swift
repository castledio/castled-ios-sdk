//
//  CastledVisitMonitor.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation

class CastledVisitMonitor: NSObject {
    private let locationManager: CLLocationManager
    init(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    // MARK: - Visit Monitoring

    func startVisitMonitoring() {
        // Start monitoring visits
        locationManager.startMonitoringVisits()
        CastledGeofencerUtils.castledLog("Started monitoring visits.", logLevel: .info)
    }

    func stopVisitMonitoring() {
        // Stop monitoring visits
        locationManager.stopMonitoringVisits()
        CastledGeofencerUtils.castledLog("Stopped monitoring visits.", logLevel: .info)
    }
}
