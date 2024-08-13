//
//  CastledGeoFencerController.swift
//  CastledGeoFencer
//
//  Created by antony on 08/08/2024.
//

import Foundation
@_spi(CastledInternal) import Castled
import CoreLocation

class CastledGeoFencerController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledGeoFencerController()
    private var isMakingApiCall = false
    private var isStarted = false
    private let locationManager = CLLocationManager()
    private var isAuthorizationRequested = false
    private var isAuthorizationGranted = false

    private lazy var visitMonitor = CastledVisitMonitor(locationManager)
    private lazy var locationMonitor = CastledLocationMonitor(locationManager)
    private lazy var regionMonitor = CastledRegionMonitor(locationManager)
    private lazy var headingMonitor = CastledHeadingMonitor(locationManager)

    override private init() {}

    // MARK: - Lifecycle events

    func initialize() {
        locationManager.delegate = self
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
        checkTheStatusAndStartMonitoring(authorizationType: nil)
    }

    func onStoreUserIdSet(_ userId: String) {}

    func onUserLoggedOut() {}

    func appDidBecomeActive() {}

    // MARK: - Public methods

    func startGeofenceMonitoring() {
        if isStarted {
            return
        }
        if !isAuthorizationGranted {
            if !isAuthorizationRequested {
                requestAlwaysAuthorization()
            }
            return
        }
        isStarted = true
        locationManager.delegate = self
        locationMonitor.startMonitoringLocation()
        visitMonitor.startVisitMonitoring()
        regionMonitor.startMonitoringRegions()
        headingMonitor.startHeadingMonitoring()
    }

    func stopGeofenceMonitoring() {
        if !isStarted {
            return
        }
        isStarted = false
        locationManager.delegate = nil
        visitMonitor.stopVisitMonitoring()
        locationMonitor.stopMonitoingLocation()
        regionMonitor.stopMonitoringRegions()
        headingMonitor.stopHeadingMonitoring()
    }

    func requestAlwaysAuthorization() {
        if CastledGeofecerValidations.validatePlistKeys(for: .authorizedAlways) {
            isAuthorizationRequested = true
            checkTheStatusAndStartMonitoring(authorizationType: .authorizedAlways)
        }
    }

    func requestWhenInUseAuthorization() {
        if CastledGeofecerValidations.validatePlistKeys(for: .authorizedWhenInUse) {
            checkTheStatusAndStartMonitoring(authorizationType: .authorizedWhenInUse)
        }
    }

    // MARK: - Helper private methods

    private func checkTheStatusAndStartMonitoring(authorizationType: CLAuthorizationStatus?) {
        let status: CLAuthorizationStatus

        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        // check if services disallowed for this app particularly
        case .restricted, .denied:
            print("No access")

        // check if services are allowed for this app
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access! We're good to go!")
            isAuthorizationGranted = true
            startGeofenceMonitoring()
        // check if we need to ask for access
        case .notDetermined:
            print("asking for access...")
            if authorizationType == .authorizedAlways {
                if CastledGeofecerValidations.isBackgroundLocationEnabled() {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    CastledGeofencerUtils.castledLog("Background location capability is not enabled. Please enable the 'Location updates' background mode in your app target settings.", logLevel: .error)
                }
            } else if authorizationType == .authorizedWhenInUse {
                locationManager.requestWhenInUseAuthorization()
            }

        @unknown default: break
        }
        /*
         // check if location services are enabled at all
         if CLLocationManager.locationServicesEnabled() {
             // location services are disabled on the device entirely!
         } else {
             CastledGeofencerUtils.castledLog("Location services are not enabled on this device. Please enable location services in settings.", logLevel: .error)
         }*/
    }
}

extension CastledGeoFencerController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Authorization granted, start monitoring
            isStarted = false
            isAuthorizationGranted = true
            startGeofenceMonitoring()
        case .notDetermined:
            // Authorization not yet determined, no action needed
            break
        case .restricted, .denied:
            // Authorization denied or restricted, handle accordingly
            print("Authorization denied or restricted.")
        @unknown default:
            print("Unknown authorization status.")
        }
    }

    // MARK: - Location updates

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Pass the locations to the appropriate manager if needed
        print("Updated locations: \(locations)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location or region: \(error.localizedDescription)")
    }

    // MARK: - Visit

    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // visitMonitor.handleVisitUpdate(visit)
    }

    // MARK: - Geofencing

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // regionMonitor.handleRegionEntry(region)
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // regionMonitor.handleRegionExit(region)
    }

    // MARK: - Heading

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //  headingMonitor.handleHeadingUpdate(newHeading)
    }
}
