//
//  CastledInboxServices.swift
//  Castled
//
//  Created by antony on 31/08/2023.
//

import UIKit

class CastledInboxServices: NSObject {
    private let backgroundQueue = DispatchQueue(label: "CastledInboxQueue", qos: .background)
    func reportInboxItemsRead(inboxItems: [CastledInboxItem]) {
        if inboxItems.isEmpty {
            return
        }
        backgroundQueue.async { [self] in
            let eventType = "READ"
            var savedEventTypes = [[String: String]]()
            for inboxObject in inboxItems {
                savedEventTypes.append(self.getSendingParametersFrom(eventType, inboxObject, ""))
            }
            if !savedEventTypes.isEmpty {
                self.updateInBoxEvents(savedEventTypes: savedEventTypes) { _, _ in
                }
            }
        }
    }

    func reportInboxItemsClicked(inboxObject: CastledInboxItem, buttonTitle: String?) {
        backgroundQueue.async { [self] in
            let eventType = "CLICKED"
            self.updateInBoxEvents(savedEventTypes: [self.getSendingParametersFrom(eventType, inboxObject, buttonTitle ?? "")]) { _, _ in
            }
        }
    }

    func reportInboxItemsDeleted(inboxObject: CastledInboxItem, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        backgroundQueue.async { [self] in
            let eventType = "DELETED"
            var savedEventTypes = [[String: String]]()
            savedEventTypes.append(self.getSendingParametersFrom(eventType, inboxObject, ""))
            if !savedEventTypes.isEmpty {
                updateInBoxEvents(savedEventTypes: savedEventTypes) { success, error in
                    completion(success, error)
                }
            }
        }
    }

    private func updateInBoxEvents(savedEventTypes: [[String: String]], completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        Castled.updateInboxEvents(params: savedEventTypes, completion: { (response: CastledResponse<[String: String]>) in

//            if response.success {
//                castledLog("updateInBoxEvents succe")
//            }
//            else
//            {
//                castledLog("Error in updating inbox event ")
//            }
            completion(response.success, response.errorMessage)
        })
    }

    private func getSendingParametersFrom(_ eventType: String, _ inboxObject: CastledInboxItem, _ title: String) -> [String: String] {
        let teamId = "\(inboxObject.teamID)"
        let sourceContext = inboxObject.sourceContext
        let timezone = TimeZone.current
        let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
        let epochTime = "\(Int(Date().timeIntervalSince1970))"
        var json = ["ts": "\(epochTime)",
                    "tz": "\(abbreviation)",
                    "teamId": teamId,
                    "eventType": eventType,
                    "sourceContext": sourceContext] as [String: String]
        json[CastledConstants.CastledNetworkRequestTypeKey] = CastledNotificationType.inbox.value()
        json["btnLabel"] = title
        return json
    }
}
