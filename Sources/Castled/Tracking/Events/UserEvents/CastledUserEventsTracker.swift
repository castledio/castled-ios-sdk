//
//  CastledUserEventsTracker.swift
//  Castled
//
//  Created by antony on 30/11/2023.
//

import UIKit

class CastledUserEventsTracker: NSObject {
    static let shared = CastledUserEventsTracker()
    static let kUserEventInstallationDate = "_casltledInstallationDate_"
    static let kUserEventNumberOfFreshSessions = "_casltledNumberOfSessions_"
    static let kUserEventNumberOfSessionFromBG = "_casltledNumberOfSessionsFromBG_"
    static let kUserEventLastFreshLaunch = "_casltledLastFreshLaunch_"
    static let kUserEventLastOpendFromBG = "_casltledLastOpendFromBG_"
    static let kUserEventCurrentAppVersion = "_casltledCurrentAppVersion_"
    static let kUserEventCurrentAppVersionChangeDate = "_casltledAppVersionChangeDate_"
    static let kUserEventDetails = "_casltledUserEventDetails_"

    var isEventsPrefetched = false

    var installationDate = ""
    var freshSessionsCount = ""
    var bgSessionCount = ""
    var lastFreshLaunchDate = ""
    var lastOpenedFromBGDate = ""
    var version = ""
    var versionChangeDate = ""

    override private init() {}
    func updateUserEvents() {
        if !CastledConfigsUtils.enableTracking {
            return
        }
        guard let userId = CastledUserDefaults.shared.userId, CastledConfigsUtils.enableTracking, isEventsPrefetched, !installationDate.isEmpty else {
            return
        }

        return;

        Castled.sharedInstance.castledEventsTrackingQueue.async(flags: .barrier) {
            let userEvents = ["installationDate": self.installationDate,
                              "freshSessionsCount": self.freshSessionsCount,
                              "bgSessionCount": self.bgSessionCount,
                              "lastFreshLaunch": self.lastFreshLaunchDate,
                              "lastOpenedFromBG": self.lastOpenedFromBGDate,
                              "version": self.version,
                              "versionChangeDate": self.versionChangeDate,
                              "platform": "MOBILE_IOS",
                              "userId": userId,
                              "deviceId": CastledDeviceInfo.shared.getDeviceId(),
                              CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.userEventRequest.rawValue]
            if userEvents != self.fetchUserEventsInfo() {
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(userEvents)
                    CastledUserDefaults.setObjectFor(CastledUserEventsTracker.kUserEventDetails, data)
                } catch {
                    CastledLog.castledLog("Unable to Encode userevents info (\(error))", logLevel: CastledLogLevel.error)
                }
                //   Castled.reportDeviceInfo(deviceInfo: userEvents) { _ in }
            }
        }

        // converting to [String:String], otherwise it will crash for the dates and other non supported non serialized items
//        let stringDict = params.compactMapValues { "\($0)" }
//        let trackParams: [String: Any] = ["type": "track",
//                                          "event": eventName,
//                                          "userId": userId,
//                                          "properties": stringDict,
//                                          "timestamp": Date().string(),
//                                          CastledConstants.CastledNetworkRequestTypeKey: CastledConstants.CastledNetworkRequestType.userEventRequest.rawValue]
//        Castled.reportCustomEvents(params: [trackParams]) { _ in
//        }
    }

    func setTheUserEventsFromBG() {
        isEventsPrefetched = false
        Castled.sharedInstance.castledEventsTrackingQueue.async(flags: .barrier) {
            self.lastOpenedFromBGDate = Date().string()
            CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventLastOpendFromBG, self.lastOpenedFromBGDate)
            var numberOfSessions = Int64(CastledUserDefaults.getString(CastledUserEventsTracker.kUserEventNumberOfSessionFromBG) ?? "0") ?? 0
            numberOfSessions += 1
            self.bgSessionCount = String(numberOfSessions)
            CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventNumberOfSessionFromBG, String(self.bgSessionCount))
            self.isEventsPrefetched = true
            self.updateUserEvents()
        }
    }

    func setInitialLaunchEventDetails() {
        Castled.sharedInstance.castledEventsTrackingQueue.async(flags: .barrier) {
            if let installDate = CastledUserDefaults.getString(CastledUserEventsTracker.kUserEventInstallationDate) {
                self.installationDate = installDate
            } else {
                self.installationDate = Date().string()
                CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventInstallationDate, self.installationDate)
            }
            self.lastFreshLaunchDate = Date().string()
            CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventLastFreshLaunch, self.lastFreshLaunchDate)

            var numberOfSessions = Int64(CastledUserDefaults.getString(CastledUserEventsTracker.kUserEventNumberOfFreshSessions) ?? "0") ?? 0
            numberOfSessions += 1
            self.freshSessionsCount = String(numberOfSessions)
            CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventNumberOfFreshSessions, self.freshSessionsCount)

            let versionString = CastledUserDefaults.getString(CastledUserEventsTracker.kUserEventCurrentAppVersion)
            let curVersion = CastledDeviceInfo.shared.getAppVersion()
            if curVersion != versionString {
                CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventCurrentAppVersion, curVersion)
                self.versionChangeDate = Date().string()
                CastledUserDefaults.setString(CastledUserEventsTracker.kUserEventCurrentAppVersionChangeDate, self.versionChangeDate)

            } else {
                self.versionChangeDate = CastledUserDefaults.getString(CastledUserEventsTracker.kUserEventCurrentAppVersionChangeDate) ?? ""
            }
            self.version = curVersion
        }
    }

    private func fetchUserEventsInfo() -> [String: String]? {
        if let savedItems = CastledUserDefaults.getDataFor(CastledUserEventsTracker.kUserEventDetails) {
            let decoder = JSONDecoder()
            if let loadedItems = try? decoder.decode([String: String].self, from: savedItems) {
                return loadedItems
            }
        }
        return nil
    }
}
