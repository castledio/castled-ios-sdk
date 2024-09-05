//
//  CastledNotificationServiceMediaHandler.swift
//  CastledNotificationService
//
//  Created by antony on 05/09/2024.
//

import Foundation
import UserNotifications
@_spi(CastledInternal) import Castled

extension CastledNotificationServiceExtension {
    func getAttachments(medias: [[String: Any]], completion: @escaping ([UNNotificationAttachment]) -> Void) {
        var attachments = [UNNotificationAttachment]()
        let dispatchGroup = DispatchGroup() // Use a dispatch group to wait for all downloads to complete

        medias.forEach { media in
            guard let urlString = media[CastledPushMediaConstants.MediaObject.mediaURL.rawValue] as? String,
                  let url = URL(string: urlString)
            else {
                CastledNotificationServiceLogManager.logMessage(" \(CastledNotificationServiceConstants.notDisplayingMediaAttacmentNil)'\(media[CastledPushMediaConstants.MediaObject.mediaURL.rawValue] ?? "")'", logLevel: .debug)
                return
            }

            dispatchGroup.enter()

            UNNotificationAttachment.downloadAndSaveMedia(mediaType: media[CastledPushMediaConstants.MediaObject.mediaType.rawValue] as? String ?? "", from: url) { attachment in
                if let attachment = attachment {
                    attachments.append(attachment)
                } else {
                    CastledNotificationServiceLogManager.logMessage("Failed to create attachment for URL: \(url)", logLevel: .error)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(attachments)
        }
    }

    func setApplicationBadge() {
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
    static func downloadAndSaveMedia(mediaType: String, from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                CastledNotificationServiceLogManager.logMessage("Error downloading media: \(error?.localizedDescription ?? "Unknown error")", logLevel: .error)
                completion(nil)
                return
            }

            let mimeType = response?.mimeType ?? ""
            let fileExtension = getFileExtension(mediaType: mediaType, mimeType: mimeType, remoteURL: url)
            let fileIdentifier = UUID().uuidString + "." + fileExtension

            let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL = tempDirectory.appendingPathComponent(fileIdentifier)
            do {
                try FileManager.default.moveItem(at: location, to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL)
                completion(attachment)
            } catch {
                CastledNotificationServiceLogManager.logMessage("Error saving media to disk: \(error) for URL: \(url)", logLevel: .error)
                completion(nil)
            }
        }

        downloadTask.resume()
    }

    private static func getExtensionFrom(mimeType: String) -> String {
        switch mimeType {
        // Image Types
        case "image/jpeg":
            return "jpg"
        case "image/png":
            return "png"
        case "image/gif":
            return "gif"
        case "image/heic":
            return "heic"

        // Movie Types
        case "video/mp4":
            return "mp4"
        case "video/mpeg":
            return "mpeg"
        case "video/mpeg2":
            return "mpg"
        case "video/avi", "video/x-msvideo":
            return "avi"

        // Audio Types
        case "audio/mpeg", "audio/mp3":
            return "mp3"
        case "audio/aiff", "audio/x-aiff":
            return "aiff"
        case "audio/wav", "audio/x-wav":
            return "wav"
        case "audio/mp4", "audio/aac":
            return "m4a"

        default:
            return ""
        }
    }

    private static func getFileExtension(mediaType: String, mimeType: String, remoteURL: URL) -> String {
        var fileExtension = getExtensionFrom(mimeType: mimeType)
        if fileExtension.isEmpty {
            fileExtension = remoteURL.pathExtension
            if fileExtension.isEmpty {
                switch mediaType {
                case CastledPushMediaConstants.MediaType.image.rawValue:
                    fileExtension = "png"
                case CastledPushMediaConstants.MediaType.video.rawValue:
                    fileExtension = "mp4"
                case CastledPushMediaConstants.MediaType.audio.rawValue:
                    fileExtension = "mp3"
                default:
                    fileExtension = "dat"
                }
            }
        }
        return fileExtension
    }
}
