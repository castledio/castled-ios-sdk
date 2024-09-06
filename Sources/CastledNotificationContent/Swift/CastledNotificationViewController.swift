//
//  CastledNotificationContent.swift
//  CastledNotificationContent
//
//  Created by antony on 05/09/2024.
//

import Foundation
import UserNotifications
import UserNotificationsUI
@_spi(CastledInternal) import Castled

@objc open class CastledNotificationViewController: UIViewController, UNNotificationContentExtension {
    @objc public lazy var appGroupId = "" {
        didSet {
            if !appGroupId.isEmpty, CastledUserDefaults.isAppGroupIsEnabledFor(appGroupId) {
                CastledShared.sharedInstance.appGroupId = appGroupId
            }
        }
    }

    lazy var childViewController: CastledNotificationContentProtocol? = nil
    @objc static var extensionInstance = CastledNotificationViewController()

    @objc override open func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Do any required interface initialization here.
    }

    @available(iOSApplicationExtension 10.0, *)
    @objc public func didReceive(_ notification: UNNotification) {
        removeChildViewsIfAny()

        CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.pushReceived, logLevel: .info)

        if let customCasledDict = getCastledPushObject(notification.request.content.userInfo) {
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
                            view.addSubview(mediaListVC.view)
                            childViewController = mediaListVC
                            mediaListVC.view.layoutIfNeeded()
                            adjustTemplateViewsContraints(defaultVC: mediaListVC)
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

    @objc open func isCastledPushNotification(_ notification: UNNotification) -> Bool {
        if let customCasledDict = getCastledPushObject(notification.request.content.userInfo), customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String {
            return true
        }
        return false
    }

    @objc override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        if let childVc = childViewController {
            preferredContentSize = CGSize(width: view.frame.size.width, height: childVc.getContentSizeHeight())

        } else {
            preferredContentSize = CGSize.zero
        }
    }

    // Handle next previos action here
    @objc public func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        completion(.dismissAndForwardAction)
    }
}

@objc extension CastledNotificationViewController {
    private func adjustTemplateViewsContraints(defaultVC: UIViewController) {
        defaultVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            defaultVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            defaultVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            defaultVC.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            defaultVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])

        DispatchQueue.main.async { [weak self] in
            self?.preferredContentSize = CGSize(width: self?.view.frame.width ?? 0, height: self?.childViewController?.getContentSizeHeight() ?? 0)
            self?.view.setNeedsUpdateConstraints()
            self?.view.setNeedsLayout()
        }
    }

    private func createDefaultContentView(_ notification: UNNotification) {
        CastledNotificationContentLogManager.logMessage(CastledNotificationContentConstants.likelyTextOrUnsupported, logLevel: .info)
        let defaultVC = UIStoryboard(name: CastledNotificationContentConstants.contentTemplatesStoryBoard, bundle: Bundle.resourceBundle(for: CastledNotificationViewController.self)).instantiateViewController(identifier: CastledNotificationContentConstants.contentTemplatesDefaultVC) as! CastledDefaultViewController
        addChild(defaultVC)
        view.addSubview(defaultVC.view)
        defaultVC.populateDetailsFrom(notificaiton: notification)
        defaultVC.view.layoutIfNeeded()
        childViewController = defaultVC
        adjustTemplateViewsContraints(defaultVC: defaultVC)
    }

    private func setuserDefaults() {
        if !appGroupId.isEmpty {
            childViewController?.userDefaults = UserDefaults(suiteName: appGroupId)
            childViewController?.userDefaults?.removeObject(forKey: CastledPushMediaConstants.CastledClickedNotiContentIndx)
        }
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
            CastledNotificationContentLogManager.logMessage("Failed to decode JSON: \(error)", logLevel: .error)
            return nil
        }
    }

    private func getCastledPushObject(_ userInfo: [AnyHashable: Any]) -> [AnyHashable: Any]? {
        if let customCasledDict = userInfo[CastledConstants.PushNotification.castledKey] as? [AnyHashable: Any] {
            return customCasledDict
        }
        return nil
    }

    private func removeChildViewsIfAny() {
        if let child = childViewController as? UIViewController {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            childViewController = nil
        }
    }

    // Currently not using this method, we can use this  for changing the current inheritance aproach to direct method call
    @objc func handleRichNotification(notification: UNNotification, in viewController: UIViewController) {
        removeChildViewsIfAny()
        viewController.addChild(self)
        viewController.view.addSubview(view)
        didMove(toParent: viewController)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        didReceive(notification)
        DispatchQueue.main.async {
            viewController.preferredContentSize = self.preferredContentSize
        }
    }
}
