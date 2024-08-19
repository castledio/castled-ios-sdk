//
//  CastledGeofencerUtils.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import Foundation
@_spi(CastledInternal) import Castled

class CastledGeofencerUtils: NSObject {
    static var userDefaults: UserDefaults = CastledUserDefaults.getUserDefaults()
    private static let geoloactionQueue = DispatchQueue(label: "CastledGeoLocationQueue", attributes: .concurrent)

    static var geofenceMonitoringRegions: [CastledGeofeceObject] = {
        CastledUserDefaults.getObjectFor(CastledGeofencerUtils.GeofenceConstants.geoCastledLocations, as: [CastledGeofeceObject].self) ?? [CastledGeofeceObject]()

    }()

    private static var visitedRegionDetails: [String: CastledVisitedPlacesDetails] = {
        CastledUserDefaults.getObjectFor(CastledGeofencerUtils.GeofenceConstants.geoVisitedPlaceDetails, as: [String: CastledVisitedPlacesDetails].self) ?? [:]
    }()

    static func castledLog(_ item: Any, logLevel: CastledLogLevel, separator: String = " ", terminator: String = "\n") {
        CastledLog.castledLog(item, logLevel: logLevel)
    }

    static func updateGeofences(with newGeofences: [[String: Any]]) {
        geoloactionQueue.async(flags: .barrier) {
            geofenceMonitoringRegions = newGeofences.decode(CastledGeofeceObject.self)
            var visitedPlaces = visitedRegionDetails
            let newGeofenceIDs = Set(newGeofences.compactMap { $0[CastledGeofencerUtils.GeofenceConstants.geoId] as? String })
            let existingGeofenceIds = Set(visitedPlaces.keys)

            // Determine which geofences are no longer present in the new response
            let idsToRemove = existingGeofenceIds.subtracting(newGeofenceIDs)

            // Remove old geofences and their corresponding dictionaries
            for id in idsToRemove {
                visitedPlaces.removeValue(forKey: id)
            }
            visitedRegionDetails = visitedPlaces

            print("visitedPlacesDetails  after\(visitedPlaces)")
            print("idsToRemove \(idsToRemove)")

            CastledUserDefaults.setObject(geofenceMonitoringRegions, as: [CastledGeofeceObject].self, forKey: CastledGeofencerUtils.GeofenceConstants.geoCastledLocations)
            CastledUserDefaults.setObject(visitedPlaces, as: [String: CastledVisitedPlacesDetails].self, forKey: CastledGeofencerUtils.GeofenceConstants.geoVisitedPlaceDetails)
            CastledGeoFencerController.sharedInstance.regionMonitor.beginRegionMonitoring()
        }
    }

    static func updateTheVisitWith(id: String, type: String) {
        geoloactionQueue.async(flags: .barrier) {
            var visit = visitedRegionDetails[id] ?? CastledVisitedPlacesDetails()
            visit.timeStamp = getCurrentTIme()
            visit.type = type
            visitedRegionDetails[id] = visit
            CastledUserDefaults.setObject(visitedRegionDetails, as: [String: CastledVisitedPlacesDetails].self, forKey: CastledGeofencerUtils.GeofenceConstants.geoVisitedPlaceDetails)
        }
    }

    static func updateGeofenceConfigs(configs: CastledGeofenceConfigs) {
        geoloactionQueue.async(flags: .barrier) {
            print("saving geo configs before\(configs)")
            CastledUserDefaults.setObject(configs, as: CastledGeofenceConfigs.self, forKey: CastledGeofencerUtils.GeofenceConstants.geoConfigs)
        }
    }

    static func getTheVisitDetailsFromId(id: String) -> CastledVisitedPlacesDetails? {
        geoloactionQueue.sync {
            visitedRegionDetails[id]
        }
    }

    static func getCurrentTIme() -> Double {
        return Date().timeIntervalSince1970
    }
}

extension CastledGeofencerUtils {
    enum GeofenceConstants {
        static let geoId = "id"
        static let geoCastledLocations = "_castledGeoLocations_"
        static let geoVisitedPlaceDetails = "_castledVisitedPlaces_"
        static let geoConfigs = "_castledConfigs_"
    }

    enum VisitedPlaceType: String {
        case entry
        case exit
    }
}
