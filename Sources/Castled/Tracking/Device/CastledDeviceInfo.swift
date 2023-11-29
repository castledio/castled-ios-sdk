//
//  CastledDeviceInfo.swift
//  Castled
//
//  Created by antony on 01/11/2023.
//

import UIKit

class CastledDeviceInfo: NSObject {
    static let shared = CastledDeviceInfo()
    override private init() {}
    func updateDeviceInfo() {
        guard CastledUserDefaults.shared.userId != nil else {
            return
        }
        Castled.sharedInstance.castledNotificationQueue.async {
            self.checkNotificationPermissions { granted in
                let deviceInfo = ["sdkVersion": self.getSDKVersion(),
                                  "appVersion": self.getAppVersion(),
                                  "model": self.getModelIdentifier(),
                                  "make": self.getMake(),
                                  "osVersion": self.getOSVersion(),
                                  "locale": self.getLocale(),
                                  "deviceId": self.getDeviceId(),
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
                    Castled.reportDeviceInfo(deviceInfo: deviceInfo) { _ in }
                }
            }
        }
    }
}

extension CastledDeviceInfo {
    func checkNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }

    private func getSDKVersion() -> String {
        return CastledCommonClass.getSDKVersion()
    }

    private func getAppVersion() -> String {
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

    private func getDeviceId() -> String {
        if let deviceID = CastledUserDefaults.getString(CastledUserDefaults.kCastledDeviceIddKey) {
            return deviceID
        }
        let random = randomIntString()
        CastledUserDefaults.setString(CastledUserDefaults.kCastledDeviceIddKey, random)
        return random
    }

    private func randomIntString() -> String {
        let randomInt = Int.random(in: 1 ... Int.max)
        return String(randomInt)
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
