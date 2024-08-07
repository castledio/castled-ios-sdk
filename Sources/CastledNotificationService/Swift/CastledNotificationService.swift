//
//  CastledNotificationServiceExtension.swift
//  CastledNotificationService
//
//  Created by Abhilash Thulaseedharan on 06/05/23.
//

import Foundation
import UserNotifications
@_spi(CastledInternal) import Castled

open class CastledNotificationServiceExtension: UNNotificationServiceExtension {
    private static let kThumbnailURL = "thumbnail_url"

    private var sharedUserDefaults: UserDefaults?

    @objc public var appGroupId = "" {
        didSet {
            if !appGroupId.isEmpty, CastledUserDefaults.isAppGroupIsEnabledFor(appGroupId) {
                CastledShared.sharedInstance.appGroupId = appGroupId
                sharedUserDefaults = UserDefaults(suiteName: appGroupId)
            }
        }
    }

    @objc public var contentHandler: ((UNNotificationContent) -> Void)?
    @objc public var bestAttemptContent: UNMutableNotificationContent?

    override open func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if bestAttemptContent != nil {
            if let customCasledDict = CastledShared.sharedInstance.getCastledDictionary(userInfo: request.content.userInfo),
               customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String
            {
                defer {
                    CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: request.content.userInfo)
                    setApplicationBadge()
                    contentHandler(bestAttemptContent ?? request.content)
                    contentHandler(request.content)
                }
                guard let urlString = customCasledDict[CastledNotificationServiceExtension.kThumbnailURL] as? String,
                      let fileUrl = URL(string: urlString)
                else {
                    return
                }
                let fileExtension = fileUrl.pathExtension
                let imageFileIdentifier = UUID().uuidString + "." + fileExtension
                guard let imageData = NSData(contentsOf: fileUrl),
                      let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: imageFileIdentifier, data: imageData, options: nil)
                else {
                    return
                }

                bestAttemptContent?.attachments = [attachment]
            }
        }
    }

    override open func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func setApplicationBadge() {
        if let userDefaults = sharedUserDefaults {
            let lastIncrementTimestamp = userDefaults.double(forKey: CastledUserDefaults.kCastledLastBadgeIncrementTimeKey)
            let currentTimestamp = Date().timeIntervalSince1970
            var currentCount: Int = (userDefaults.value(forKey: CastledUserDefaults.kCastledBadgeKey) as? Int) ?? 0
            if currentTimestamp - lastIncrementTimestamp > 2 {
                /* This check is for avoiding the badge increment more than 1, as we are incrementing the count in
                 // Check if it's been more than a certain interval (e.g., 2 sec) since the last increment

                 1. background
                 2. will present
                 3. notification extension */

                currentCount += (bestAttemptContent?.badge ?? NSNumber(value: 0)).intValue
                userDefaults.setValue(currentCount, forKey: CastledUserDefaults.kCastledBadgeKey)
                userDefaults.setValue(currentTimestamp, forKey: CastledUserDefaults.kCastledLastBadgeIncrementTimeKey)
                userDefaults.synchronize()
                bestAttemptContent?.badge = NSNumber(value: currentCount)

            } else {
                if (bestAttemptContent?.badge) != nil {
                    if bestAttemptContent?.badge?.intValue == 0 {
                        bestAttemptContent?.badge = NSNumber(value: 0)

                    } else {
                        bestAttemptContent?.badge = NSNumber(value: currentCount)
                    }
                }
            }
        }
    }
}

@available(iOSApplicationExtension 10.0, *)

extension UNNotificationAttachment {
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject: AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment

        } catch {
            print("error \(error)")
        }
        return nil
    }
}
