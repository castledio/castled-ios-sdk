//
//  CastledNotificationService.swift
//  Castled
//
//  Created by Abhilash Thulaseedharan on 05/05/23.
//

import Foundation
import UserNotifications

open class CastledNotificationService : UNNotificationServiceExtension{
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        print("coming here 2")
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        /*
         if let bestAttemptContent = bestAttemptContent {
         // Modify the notification content here...
         bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
         
         contentHandler(bestAttemptContent)
         }*/
        
        
        if let customCasledDict = request.content.userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary{
            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String{
                defer {
                    contentHandler(bestAttemptContent ?? request.content)
                }
                
                guard let attachment = request.attachment else { return }
                
                bestAttemptContent?.attachments = [attachment]
            }
        }
        
        /**if let customCasledDict = request.content.userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary{
            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String{
                defer {
                    contentHandler(bestAttemptContent ?? request.content)
                }
                
                guard let mediaURLString = customCasledDict[CastledConstants.PushNotification.CustomProperties.mediaURL] as? String,
                      let mediaURL = URL(string:mediaURLString)else {return}
                
                let task = URLSession.shared.downloadTask(with: mediaURL) { temporaryFileLocation, response, error in
                    if let error = error {
                        print("Error downloading attachment: \(error.localizedDescription)")
                        self.contentHandler?(self.bestAttemptContent ?? request.content)
                    }
                    else if let temporaryFileLocation = temporaryFileLocation, let response = response {
                        
                        let fileManager = FileManager.default
                        let attachmentIdentifier = UUID().uuidString
                        
                        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
                        let attachmentURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)
                        
                        
                        do {
                            try fileManager.moveItem(at: temporaryFileLocation, to: attachmentURL!)
                            let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier, url: attachmentURL!, options: nil)
                            self.bestAttemptContent?.attachments = [attachment]
                        } catch {
                            print("Error creating attachment: \(error.localizedDescription)")
                        }
                        self.contentHandler?(self.bestAttemptContent ?? request.content)
                    }
                    else {
                        self.contentHandler?(self.bestAttemptContent ?? request.content)
                    }
                }
                task.resume()
            }**/
       // }
        
    }
    
    open override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

extension UNNotificationRequest {
    var attachment: UNNotificationAttachment? {
        guard let customCasledDict = content.userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary, let attachmentURL = customCasledDict[CastledConstants.PushNotification.CustomProperties.mediaURL] as? String,let imageData = try? Data(contentsOf: URL(string: attachmentURL)!) else {
            return nil
        }
        return try? UNNotificationAttachment(data: imageData, options: nil)
    }
}

extension UNNotificationAttachment {

    convenience init(data: Data, options: [NSObject: AnyObject]?) throws {
        let fileManager = FileManager.default
        let temporaryFolderName = ProcessInfo.processInfo.globallyUniqueString
        let temporaryFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(temporaryFolderName, isDirectory: true)

        try fileManager.createDirectory(at: temporaryFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = UUID().uuidString + ".jpg"
        let fileURL = temporaryFolderURL.appendingPathComponent(imageFileIdentifier)
        try data.write(to: fileURL)
        try self.init(identifier: imageFileIdentifier, url: fileURL, options: options)
    }
}
