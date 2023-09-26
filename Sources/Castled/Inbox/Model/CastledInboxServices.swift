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
            var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingInboxEvents) as? [[String: String]]) ?? [[String: String]]()
            for inboxObject in inboxItems {
                if let json = self.getSendingParametersFrom(savedEventTypes, eventType, inboxObject, "") {
                    savedEventTypes.append(json)
                }
            }
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingInboxEvents, savedEventTypes)
            if !savedEventTypes.isEmpty {
                updateInBoxEvents(savedEventTypes: savedEventTypes) { _, _ in
                }
            }
        }
    }

    func reportInboxItemsClicked(inboxObject: CastledInboxItem, buttonTitle: String?) {
        backgroundQueue.async { [self] in
            let eventType = "CLICKED"
            var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingInboxEvents) as? [[String: String]]) ?? [[String: String]]()
            if let json = self.getSendingParametersFrom(savedEventTypes, eventType, inboxObject, buttonTitle ?? "") {
                savedEventTypes.append(json)
            }
            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingInboxEvents, savedEventTypes)
            if !savedEventTypes.isEmpty {
                updateInBoxEvents(savedEventTypes: savedEventTypes) { _, _ in
                }
            }
        }
    }

    func reportInboxItemsDeleted(inboxObject: CastledInboxItem, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        backgroundQueue.async { [self] in
            let eventType = "DELETED"
            var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingInboxEvents) as? [[String: String]]) ?? [[String: String]]()

            if let json = self.getSendingParametersFrom(savedEventTypes, eventType, inboxObject, "") {
                savedEventTypes.append(json)
            }

            CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingInboxEvents, savedEventTypes)
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
//                castledLog(response.result as Any)
//            }
//            else
//            {
//                castledLog("Error in updating inbox event ")
//            }
            completion(response.success, response.errorMessage)
        })
    }

    private func getSendingParametersFrom(_ savedEventTypes: [[String: String]], _ eventType: String, _ inboxObject: CastledInboxItem, _ title: String) -> [String: String]? {
        let teamId = "\(inboxObject.teamID)"
        let sourceContext = inboxObject.sourceContext
        let existingEvents = savedEventTypes.filter { $0["eventType"] == eventType &&
            $0["btnLabel"] == title &&
            $0["sourceContext"] == sourceContext &&
            $0[CastledConstants.CastledSlugValueIdentifierKey] == CastledNotificationType.inbox.value()
        }

        if existingEvents.isEmpty {
            let timezone = TimeZone.current
            let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
            let epochTime = "\(Int(Date().timeIntervalSince1970))"

            var json = ["ts": "\(epochTime)",
                        "tz": "\(abbreviation)",
                        "teamId": teamId,
                        "eventType": eventType,
                        "sourceContext": sourceContext] as [String: String]
            json["btnLabel"] = title
            return json
        }
        return nil
    }
}
