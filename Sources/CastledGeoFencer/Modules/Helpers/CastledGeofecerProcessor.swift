//
//  CastledGeofecerProcessor.swift
//  CastledGeoFencer
//
//  Created by antony on 13/08/2024.
//

import CoreLocation
import Foundation

class CastledGeofecerProcessor: NSObject {
    static var lastLocation: CLLocation?
    static func handleVisitUpdate(visit: CLVisit) {}

    static func handleRegionEntry(_ region: CLRegion) {
        let _ = isProcessedRegionEvent(type: CastledGeofencerUtils.VisitedPlaceType.entry.rawValue, regionIdentifier: region.identifier)
    }

    static func handleRegionExit(_ region: CLRegion) {
        //  isProcessedRegionEvent(type: CastledGeofencerUtils.VisitedPlaceType.exit.rawValue, regionIdentifier: region.identifier)
    }

    private static func isProcessedRegionEvent(type: String, regionIdentifier: String) -> Bool {
        defer {
            CastledGeofencerUtils.updateTheVisitWith(id: regionIdentifier, type: type)
        }
        guard let visit = CastledGeofencerUtils.getTheVisitDetailsFromId(id: regionIdentifier) else {
            // not visited yet
            if type == CastledGeofencerUtils.VisitedPlaceType.entry.rawValue {
                // report the first entry event
            }
            return false
        }
        // visited previously
        if !CastledGeofecerValidations.isUpdateIntervalPassedSinceLastVisit(lastVisitedTime: visit.timeStamp) {
            CastledGeofencerUtils.castledLog("recently visited same region.................\(regionIdentifier)", logLevel: .debug)
            return false
        }

        CastledGeoFencerRepository.reportRegionEntry(eventName: regionIdentifier, params: [["timestamp": CastledGeofencerUtils.getCurrentTIme(), "id": regionIdentifier]])
        return true
    }

    static func didLocationUpdate(_ location: CLLocation) {
        if let lastLoc = lastLocation {
            guard location.distance(from: lastLoc) > CastledGeoFencer.sharedInstance.configs.locationFilterDistance,
                  location.timestamp.timeIntervalSince(lastLoc.timestamp) > CastledGeoFencer.sharedInstance.configs.locationUpdateIntervalSec
            else {
                return
            }
        }
        // update user location to this if required
        // below logic is for checking inside the region
        let monitoringRegions = CastledGeofencerUtils.geofenceMonitoringRegions
        monitoringRegions.forEach { region in
            let regionLocation = CLLocation(latitude: region.lat, longitude: region.long)
            if location.distance(from: regionLocation) < region.radius {
                // entered the region
                if CastledGeofecerProcessor.isProcessedRegionEvent(type: CastledGeofencerUtils.VisitedPlaceType.entry.rawValue, regionIdentifier: region.id) {
                    return
                }
            }
        }
    }
}
