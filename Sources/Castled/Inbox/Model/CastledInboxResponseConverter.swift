//
//  CastledInboxResponseConverter.swift
//  Castled
//
//  Created by antony on 03/10/2023.
//

import Foundation

enum CastledInboxResponseConverter {
    static func convertToInbox(inboxItem: CastledInboxItem) -> CAppInbox {
        let appinbox = CAppInbox()
        appinbox.messageId = inboxItem.messageId
        appinbox.teamID = inboxItem.teamID
        appinbox.startTs = inboxItem.startTs
        appinbox.sourceContext = inboxItem.sourceContext
        appinbox.imageUrl = inboxItem.imageUrl
        appinbox.title = inboxItem.title
        appinbox.body = inboxItem.body
        appinbox.isRead = inboxItem.isRead
        appinbox.isPinned = false
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
