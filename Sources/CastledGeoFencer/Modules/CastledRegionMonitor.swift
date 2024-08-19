//
//  CastledRegionMonitor.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation

class CastledRegionMonitor: NSObject {
    private let locationManager: CLLocationManager
    private var isMonitoring = false

    init(_ locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()
    }

    func initilizeMonitoring() {
        if !CastledGeofecerValidations.isRegionMonitoringAvailabele() {
            CastledGeofencerUtils.castledLog("Region monitoring is not available on this device.", logLevel: .info)
            return
        }
        if isMonitoring {
            return
        }
        isMonitoring = true
        // make api call
        // Example usage with a new API response
        let apiResponse: [[String: Any]] = [
            ["id": "chrysalis", "lat": 12.970323244842623, "long": 77.74890921843459, "radius": 1000],
            ["id": "kavalam", "lat": 9.477801601203003, "long": 76.46768721497936, "radius": 1000],
            ["id": "kurisummood", "lat": 9.46471425251982, "long": 76.55659640883553, "radius": 1000],
            ["id": "chry_railway", "lat": 9.559796404461709, "long": 76.52919945855054, "radius": 1000],
            ["id": "chry_kavala", "lat": 9.446594062887202, "long": 76.54019134796623, "radius": 1000],
            ["id": "thuruthy", "lat": 9.478623057690246, "long": 76.52762251648811, "radius": 1000],
            ["id": "asramam", "lat": 9.47169485120913, "long": 76.46211157297881, "radius": 1000]
        ]

        CastledGeofencerUtils.updateGeofences(with: apiResponse)
    }

    func beginRegionMonitoring() {
        DispatchQueue.main.async { [weak self] in
            self?.resetRegionMonitoring()

            let monitoredRegions = CastledGeofencerUtils.geofenceMonitoringRegions
            for region in monitoredRegions {
                let regionToBe = CLCircularRegion(center: CLLocationCoordinate2D(latitude: region.lat, longitude: region.long), radius: region.radius, identifier: region.id)
                self?.locationManager.startMonitoring(for: regionToBe)
            }
            self?.isMonitoring = false

            print("monitoredRegions are  \(self?.locationManager.monitoredRegions)")

            CastledGeofencerUtils.castledLog("Started monitoring region.", logLevel: .info)
        }
    }

    func stopMonitoringRegions() {
        if !CastledGeofecerValidations.isRegionMonitoringAvailabele() {
            return
        }
        resetRegionMonitoring()
        CastledGeofencerUtils.castledLog("Stopped monitoring region.", logLevel: .info)
    }

    private func resetRegionMonitoring() {
        let currentRegions = locationManager.monitoredRegions
        currentRegions.forEach { region in
            locationManager.stopMonitoring(for: region)
        }
    }
}
