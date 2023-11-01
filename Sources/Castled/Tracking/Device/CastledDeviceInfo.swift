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
        guard let userId = CastledUserDefaults.shared.userId else {
            return
        }
        Castled.sharedInstance?.castledDispatchQueue.async {
            let deviceInfo = ["sdkVersion": self.getSDKVersion(),
                              "appVersion": self.getAppVersion(),
                              "model": self.getModel(),
                              "make": self.getMake(),
                              "osVersion": self.getOSVersion(),
                              "locale": self.getLocale(),
                              "deviceId": self.getDeviceId(),
                              "platform": "MOBILE_IOS",
                              CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.deviceInfoRequest.rawValue]

            if deviceInfo != self.fetchSavedDeviceInfo() {
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(deviceInfo)
                    CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledDeviceInfoKey, data)
                }
                catch {
                    CastledLog.castledLog("Unable to Encode device info (\(error))", logLevel: CastledLogLevel.error)
                }
                Castled.updateDeviceInfo(deviceInfo: deviceInfo) { [weak self] (_: CastledResponse<[String: String]>) in
                }
            }
        }
    }
}

extension CastledDeviceInfo {
    private func getSDKVersion() -> String {
        if let plistPath = Bundle.resourceBundle(for: Castled.self).path(forResource: "Info", ofType: "plist"),
           let infoDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
           let version = infoDict["CFBundleShortVersionString"] as? String
        {
            // 'version' contains the CFBundleShortVersionString value
            return version
        }
        return "0.0.0"
    }

    private func getAppVersion() -> String {
        if let infoDictionary = Bundle.main.infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String
        {
            return version
        }
        return "0.0.0"
    }

    private func getModel() -> String {
        return UIDevice.current.model
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
}
