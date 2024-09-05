//
//  CastledNotificationContent.swift
//  CastledNotificationContent
//
//  Created by Abhilash Thulaseedharan on 11/05/23.
//

import Foundation
import UserNotifications
import UserNotificationsUI
@_spi(CastledInternal) import Castled

@objc open class CastledNotificationViewController: UIViewController, UNNotificationContentExtension {
    @objc public var appGroupId = "" {
        didSet {
            if !appGroupId.isEmpty, CastledUserDefaults.isAppGroupIsEnabledFor(appGroupId) {
                CastledShared.sharedInstance.appGroupId = appGroupId
            }
        }
    }

    @IBOutlet var imageView: UIImageView!
    var childViewController: CastledNotificationContentProtocol?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Do any required interface initialization here.
    }

    @available(iOSApplicationExtension 10.0, *)
    @objc open func didReceive(_ notification: UNNotification) {
        CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.pushReceived, logLevel: .info)
        if let customCasledDict = notification.request.content.userInfo[CastledConstants.PushNotification.castledKey] as? NSDictionary {
            CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.pushFromCastled, logLevel: .info)

            defer {
                CastledShared.sharedInstance.reportCastledPushEventsFromExtension(userInfo: notification.request.content.userInfo)
                setuserDefaults()
            }
            let templateType = customCasledDict[CastledPushMediaConstants.templateType] as? String ?? CastledPushMediaConstants.TemplateType.defaultTemplate.rawValue
            if let msgFramesString = customCasledDict[CastledPushMediaConstants.messageFrames] as? String,
               let convertedAttachments = convertToArray(text: msgFramesString), !convertedAttachments.isEmpty
            {
                switch templateType {
                    case CastledPushMediaConstants.TemplateType.defaultTemplate.rawValue:
                        if let mediaType = convertedAttachments.first?.mediaType,
                           mediaType != CastledNotificationMediaObject.CNMediaType.text_only
                        {
                            let mediaListVC = CastledMediasViewController(mediaObjects: convertedAttachments)
                            addChild(mediaListVC)
                            mediaListVC.view.frame = view.frame
                            view.addSubview(mediaListVC.view)
                            childViewController = mediaListVC
                            mediaListVC.view.layoutIfNeeded()
                            preferredContentSize = mediaListVC.preferredContentSize
                            return
                        }
                    default:
                        break
                }
            }

            createDefaultContentView(notification)
        } else {
            CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.notFromCaslted, logLevel: .info)
        }
    }

    private func createDefaultContentView(_ notification: UNNotification) {
        CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.likelyTextOrUnsupported, logLevel: .info)
        let defaultVC = UIStoryboard(name: CastledNotificationContentConstants.contentTemplatesStoryBoard, bundle: Bundle.resourceBundle(for: CastledNotificationViewController.self)).instantiateViewController(identifier: CastledNotificationContentConstants.contentTemplatesDefaultVC) as! CastledDefaultViewController
        defaultVC.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(defaultVC)
        view.addSubview(defaultVC.view)
        NSLayoutConstraint.activate([
            defaultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            defaultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            defaultVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            defaultVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        defaultVC.populateDetailsFrom(notificaiton: notification)
        defaultVC.view.layoutIfNeeded()
        childViewController = defaultVC
        DispatchQueue.main.async { [weak self] in
            self?.preferredContentSize = CGSize(width: self?.view.frame.width ?? 0, height: self?.childViewController!.getContentSizeHeight() ?? 0)
            self?.view.setNeedsUpdateConstraints()
            self?.view.setNeedsLayout()
        }
    }

    private func setuserDefaults() {
        if !appGroupId.isEmpty {
            childViewController?.userDefaults = UserDefaults(suiteName: appGroupId)
            childViewController?.userDefaults?.removeObject(forKey: CastledPushMediaConstants.CastledClickedNotiContentIndx)
        }
    }

    override open func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        if let childVc = childViewController {
            preferredContentSize = CGSize(width: view.frame.size.width, height: childVc.getContentSizeHeight())

        } else {
            preferredContentSize = CGSize.zero
        }
    }

    // Handle next previos action here
    @objc public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        // Your code implementation here

        completion(.dismissAndForwardAction)
    }

    private func convertToArray(text: String) -> [CastledNotificationMediaObject]? {
        guard let jsonData = text.data(using: .utf8) else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        do {
            let convertedAttachments = try jsonDecoder.decode([CastledNotificationMediaObject].self, from: jsonData)
            return convertedAttachments
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }

    @objc public func isNotificaitonFromCastled(_ notification: UNNotification) -> Bool {
        if let customCasledDict = notification.request.content.userInfo[CastledConstants.PushNotification.castledKey] as? NSDictionary, customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
            return true
        }
        return false
    }
}
