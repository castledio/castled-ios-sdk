//
//  CastledNotificationServiceExtension.swift
//  CastledNotificationService
//
//  Created by Abhilash Thulaseedharan on 06/05/23.
//

import Foundation
import UserNotifications

@objc open class CastledNotificationServiceExtension: UNNotificationServiceExtension {
    
    
    private static let kCustomKey        = "castled"
    private static let kApsKey           = "aps"
    private static let kThumbnailURL     = "thumbnail_url"
    private static let kMediaType        = "media_type"
    private static let kNotificationId   = "castled_notification_id"
    
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if bestAttemptContent != nil {
            
            if let customCasledDict = request.content.userInfo[CastledNotificationServiceExtension.kCustomKey] as? NSDictionary{
                if customCasledDict[CastledNotificationServiceExtension.kNotificationId] is String{
                    defer {
                        contentHandler(bestAttemptContent ?? request.content)
                    }
                    //
                    guard let urlString = customCasledDict[CastledNotificationServiceExtension.kThumbnailURL] as? String,
                          let fileUrl = URL(string: urlString) else {
                        return
                    }
                    
                    let fileExtension = fileUrl.pathExtension
                    let imageFileIdentifier = UUID().uuidString + "." + fileExtension
                    
                    //let options = [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeGIF as String] as? [NSObject : AnyObject]
                    
                    guard let imageData = NSData(contentsOf: fileUrl),
                          let attachment = UNNotificationAttachment.saveImageToDisk(fileIdentifier: imageFileIdentifier, data: imageData, options: nil) else {
                        print("Error in UNNotificationAttachment.saveImageToDisk()")
                        return
                    }
                    
                    bestAttemptContent?.attachments = [attachment]
                }
            }
            contentHandler(request.content)
        }
    }
    
    open override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}


@available(iOSApplicationExtension 10.0, *)

extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
            
        } catch let error {
            print("error \(error)")
        }
        return nil
    }
}




