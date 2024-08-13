//
//  CastledRegionMonitor.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation
 
class CastledRegionMonitor: NSObject {
    private var monitoredRegions: [CLCircularRegion] = []

    private let locationManager: CLLocationManager
    init(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }

    func setupRegionMonitoring() {
        if CastledGeofecerValidations.isRegionMonitoringAvailabele() {
            // Define regions to monitor
            let region1 = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090), radius: 100, identifier: "Region1")
            let region2 = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4090), radius: 100, identifier: "Region2")

            // Add regions to the monitored list
            monitoredRegions = [region1, region2]

            // Start monitoring regions
        }
    }

    func startMonitoringRegions() {
        if !CastledGeofecerValidations.isRegionMonitoringAvailabele() {
            CastledGeofencerUtils.castledLog("Region monitoring is not available on this device.", logLevel: .info)
            return
        }
        for region in monitoredRegions {
            if !locationManager.monitoredRegions.contains(region) {
                locationManager.startMonitoring(for: region)
            }
        }
        CastledGeofencerUtils.castledLog("Started monitoring region.", logLevel: .info)
    }

    func stopMonitoringRegions() {
        if !CastledGeofecerValidations.isRegionMonitoringAvailabele() {
            return
        }
        for region in monitoredRegions {
            if locationManager.monitoredRegions.contains(region) {
                locationManager.stopMonitoring(for: region)
            }
        }
        CastledGeofencerUtils.castledLog("Stopped monitoring region.", logLevel: .info)
    }
}
