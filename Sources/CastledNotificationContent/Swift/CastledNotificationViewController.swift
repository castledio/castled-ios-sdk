//
//  CastledNotificationContent.swift
//  CastledNotificationContent
//
//  Created by Abhilash Thulaseedharan on 11/05/23.
//

import Foundation
import UserNotifications
import UserNotificationsUI

@objc open class CastledNotificationViewController: UIViewController, UNNotificationContentExtension {
    @objc public var appGroupId = "" {
        didSet {
            if let mediaVC = childViewController as? CastledMediasViewController {
                mediaVC.setUserdefaults(FromAppgroup: appGroupId)
            }
        }
    }

    private static let kCustomKey = "castled"
    private static let kMsg_frames = "msg_frames"
    private static let kNotificationId = "castled_notification_id"

    @IBOutlet var imageView: UIImageView!
    var childViewController: UIViewController?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Do any required interface initialization here.
    }

    @available(iOSApplicationExtension 10.0, *)
    @objc open func didReceive(_ notification: UNNotification) {
        if let customCasledDict = notification.request.content.userInfo[CastledNotificationViewController.kCustomKey] as? NSDictionary {
            if let msgFramesString = customCasledDict[CastledNotificationViewController.kMsg_frames] as? String {
                // type =  carousel
                if let convertedAttachments = convertToArray(text: msgFramesString) {
                    let mediaListVC = CastledMediasViewController(mediaObjects: convertedAttachments)
                    addChild(mediaListVC)
                    mediaListVC.view.frame = view.frame
                    view.addSubview(mediaListVC.view)
                    if !appGroupId.isEmpty {
                        mediaListVC.setUserdefaults(FromAppgroup: appGroupId)
                    }
                    childViewController = mediaListVC
                    mediaListVC.view.layoutIfNeeded()
                    preferredContentSize = mediaListVC.preferredContentSize
                }
            }
            // other types
        }
    }

    override open func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        preferredContentSize = childViewController?.preferredContentSize ?? CGSize.zero
    }

    // Handle next previos action here
    @objc public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        // Your code implementation here

        completion(.dismissAndForwardAction)
    }

    private func convertToArray(text: String) -> [CastledNotificationMediaObject]? {
        // Convert the string to data
        guard let jsonData = text.data(using: .utf8) else {
            return nil
        }
        let jsonDecoder = JSONDecoder()
        let convertedAttachments = try? jsonDecoder.decode([CastledNotificationMediaObject].self, from: jsonData)
        return convertedAttachments
    }

    @objc func isPushFromCastled(userInfo: [AnyHashable: Any]) -> Bool {
        if let customCasledDict = userInfo[CastledNotificationViewController.kCustomKey] as? NSDictionary, customCasledDict[CastledNotificationViewController.kNotificationId] is String {
            return true
        }
        return false
    }
}
