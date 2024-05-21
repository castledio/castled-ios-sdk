//
//  CastledDeviceInfoController.swift
//  Castled
//
//  Created by antony on 21/05/2024.
//

import Foundation
import UIKit

class CastledDeviceInfoController: NSObject, CastledPreferenceStoreListener, CastledLifeCycleListener {
    static var sharedInstance = CastledDeviceInfoController()
    private var isMakingApiCall = false
    private var isStarted = false
    override private init() {}

    func initialize() {
        CastledUserDefaults.shared.addObserver(self)
        CastledLifeCycleManager.sharedInstance.addObserver(self)
    }

    func appBecomeActive() {
        updateDeviceInfo()
    }

    func onStoreUserIdSet(_ userId: String) {
        CastledDeviceInfo.sharedInstance.userId = userId
        updateDeviceInfo()
    }

    func onUserLoggedOut() {}

    func updateDeviceInfo() {
        if CastledDeviceInfo.sharedInstance.userId.isEmpty {
            return
        }
        Castled.sharedInstance.castledCommonQueue.async {
            self.checkNotificationPermissions { granted in
                let deviceInfo = ["sdkVersion": self.getSDKVersion(),
                                  "appVersion": self.getAppVersion(),
                                  "model": self.getModelIdentifier(),
                                  "make": self.getMake(),
                                  "osVersion": self.getOSVersion(),
                                  "locale": self.getLocale(),
                                  "deviceId": CastledCommonClass.getDeviceId(),
                                  "timeZone": self.getTimeZone(),
                                  "pushPermission": granted ? "1" : "0",
                                  "platform": "MOBILE_IOS",
                                  CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue]

                if deviceInfo != self.fetchSavedDeviceInfo() {
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(deviceInfo)
                        CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledDeviceInfoKey, data)
                    } catch {
                        CastledLog.castledLog("Unable to Encode device info (\(error))", logLevel: CastledLogLevel.error)
                    }
                    CastledDeviceInfoRepository.reportDeviceInfoEvents(params: deviceInfo)
                }
            }
        }
    }
}

extension CastledDeviceInfoController {
    private func checkNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }

    private func getSDKVersion() -> String {
        return CastledCommonClass.getSDKVersion()
    }

    func getAppVersion() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String
        {
            return version
        }
        return "0.0.0"
    }

    private func getModelIdentifier() -> String {
        if ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] != nil {
            return "Simulator"
        }
        var sysinfo = utsname()
        uname(&sysinfo)
        if let identifier = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) {
            return identifier.isEmpty ? UIDevice.current.model : identifier
        } else {
            return UIDevice.current.model
        }
    }

    private func getMake() -> String {
        return "Apple"
    }

    private func getOSVersion() -> String {
        return UIDevice.current.systemVersion
    }

    private func getLocale() -> String {
        return Locale.current.identifier
    }

    private func fetchSavedDeviceInfo() -> [String: String]? {
        if let savedItems = CastledUserDefaults.getDataFor(CastledUserDefaults.kCastledDeviceInfoKey) {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([String: String].self, from: savedItems) {
                return loadedItems
            }
        }
        return nil
    }

    private func getAppName() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Castled"
    }

    private func getTimeZone() -> String {
        let timezone = TimeZone.current
        return timezone.abbreviation(for: Date()) ?? "GMT"
    }

    private func getBundleId() -> String {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            // Now, 'bundleIdentifier' contains the bundle ID of your application
            return bundleIdentifier
        }
        return ""
    }
}
