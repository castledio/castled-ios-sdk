//
//  CastledInboxResponseConverter.swift
//  Castled
//
//  Created by antony on 03/10/2023.
//

import Foundation
import RealmSwift

enum CastledInboxResponseConverter {
    static func convertToInbox(inboxItem: CastledInboxItem, realm: Realm? = nil) -> CAppInbox {
        let appinbox = realm?.object(ofType: CAppInbox.self, forPrimaryKey: inboxItem.messageId) ?? CAppInbox()
        if !(appinbox.messageId != 0) {
            appinbox.messageId = inboxItem.messageId
            appinbox.isPinned = false

        }
        appinbox.teamID = inboxItem.teamID
        appinbox.startTs = inboxItem.startTs
        appinbox.sourceContext = inboxItem.sourceContext
        appinbox.imageUrl = inboxItem.imageUrl
        appinbox.title = inboxItem.title
        appinbox.body = inboxItem.body
        appinbox.isRead = inboxItem.isRead
        appinbox.addedDate = inboxItem.addedDate
        appinbox.aspectRatio = Float(inboxItem.aspectRatio)
        appinbox.inboxType = inboxItem.inboxType
        appinbox.actionButtonsArray = inboxItem.actionButtons
        appinbox.messageDictionary = inboxItem.message
        appinbox.titleTextColor = (inboxItem.message["titleFontColor"] as? String) ?? ""
        appinbox.bodyTextColor = (inboxItem.message["bodyFontColor"] as? String) ?? ""
        appinbox.containerBGColor = (inboxItem.message["bgColor"] as? String) ?? ""
        appinbox.dateTextColor = appinbox.bodyTextColor
        return appinbox
    }

    static func convertToInboxItem(appInbox: CAppInbox) -> CastledInboxItem {
        let inboxItem = CastledInboxItem()
        inboxItem.messageId = appInbox.messageId
        inboxItem.teamID = appInbox.teamID
        inboxItem.startTs = appInbox.startTs
        inboxItem.sourceContext = appInbox.sourceContext
        inboxItem.imageUrl = appInbox.imageUrl
        inboxItem.title = appInbox.title
        inboxItem.body = appInbox.body
        inboxItem.isRead = appInbox.isRead
        inboxItem.addedDate = appInbox.addedDate
        inboxItem.aspectRatio = CGFloat(appInbox.aspectRatio)
        inboxItem.inboxType = appInbox.inboxType
        inboxItem.actionButtons = appInbox.actionButtonsArray
        inboxItem.message = appInbox.messageDictionary
        inboxItem.titleTextColor = appInbox.colorTitle
        inboxItem.bodyTextColor = appInbox.colorBody
        inboxItem.containerBGColor = appInbox.colorContainer
        inboxItem.dateTextColor = appInbox.colorBody
        return inboxItem
    }
}
