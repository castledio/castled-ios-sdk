//
//  CastledGeofecerValidations.swift
//  CastledGeoFencer
//
//  Created by antony on 12/08/2024.
//

import CoreLocation
import Foundation

class CastledGeofecerValidations: NSObject {
    static func isSignificantLocationChangeAvailable() -> Bool {
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }

    static func isHeadingAvailable() -> Bool {
        return CLLocationManager.headingAvailable()
    }

    static func isRegionMonitoringAvailabele() -> Bool {
        CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    }

    static func isKeyPresent(_ key: String) -> Bool {
        guard let infoPlist = Bundle.main.infoDictionary else {
            return false
        }
        return infoPlist[key] != nil
    }

    static func validatePlistKeys(for authorizationType: CLAuthorizationStatus) -> Bool {
        var missingKeys: [String] = []

        switch authorizationType {
        case .authorizedAlways:
            if !isKeyPresent("NSLocationAlwaysUsageDescription") {
                missingKeys.append("NSLocationAlwaysUsageDescription")
            }
            if !isKeyPresent("NSLocationAlwaysAndWhenInUseUsageDescription") {
                missingKeys.append("NSLocationAlwaysAndWhenInUseUsageDescription")
            }
        case .authorizedWhenInUse:
            if !isKeyPresent("NSLocationWhenInUseUsageDescription") {
                missingKeys.append("NSLocationWhenInUseUsageDescription")
            }
        default:
            break
        }

        if !missingKeys.isEmpty {
            let missingKeysString = missingKeys.joined(separator: ", ")
            CastledGeofencerUtils.castledLog("The following plist keys are missing: \(missingKeysString). Please ensure that the necessary keys are included in your Info.plist", logLevel: .error)
            return false
        }

        return true
    }

    static func isBackgroundLocationEnabled() -> Bool {
        guard let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String] else {
            return false
        }
        return backgroundModes.contains("location")
    }

    static func isUpdateIntervalPassedSinceLastVisit(lastVisitedTime: TimeInterval) -> Bool {
        return (CastledGeofencerUtils.getCurrentTIme() - lastVisitedTime) > CastledGeoFencer.sharedInstance.configs.locationUpdateIntervalSec
    }
}
