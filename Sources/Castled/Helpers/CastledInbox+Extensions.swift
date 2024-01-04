//
//  Castled+Inbox.swift
//  Castled
//
//  Created by antony on 31/08/2023.
//

import Foundation
import RealmSwift
import UIKit

public extension Castled {
    /**
     Inbox : Function that will returns the unread message count
     */
    @objc func observeUnreadCountChanges(listener: @escaping (Int) -> Void) {
        inboxUnreadCountCallback = listener
        inboxUnreadCountCallback?(inboxUnreadCount)
    }

    @objc func getInboxUnreadCount() -> Int {
        return inboxUnreadCount
    }

    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc func getInboxViewController(withUIConfigs config: CastledInboxDisplayConfig?, andDelegate delegate: CastledInboxViewControllerDelegate) -> CastledInboxViewController {
        let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.inboxConfig = config ?? CastledInboxDisplayConfig()
        castledInboxVC.delegate = delegate
        return castledInboxVC
    }

    /**
     Inbox : Function to get inbox items array
     */
    @objc func getInboxItems(completion: @escaping (_ success: Bool, _ items: [CastledInboxItem]?, _ errorMessage: String?) -> Void) {
        CastledStore.castledStoreQueue.async {
            if Castled.sharedInstance.instanceId.isEmpty {
                completion(false, [], CastledExceptionMessages.notInitialised.rawValue)
                CastledLog.castledLog("GetInboxItems failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: .error)
                return
            }
            else if !CastledConfigs.sharedInstance.enableAppInbox {
                completion(false, [], CastledExceptionMessages.appInboxDisabled.rawValue)
                CastledLog.castledLog("GetInboxItems failed: \(CastledExceptionMessages.appInboxDisabled.rawValue)", logLevel: .error)
                return
            }
            guard let _ = CastledUserDefaults.shared.userId else {
                CastledLog.castledLog("GetInboxItems failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
                completion(false, [], CastledExceptionMessages.userNotRegistered.rawValue)
                return
            }
            do {
                let backgroundRealm = CastledDBManager.shared.getRealm()
                let cachedInboxObjects = backgroundRealm.objects(CAppInbox.self).filter("isDeleted == false")

                let liveInboxItems: [CastledInboxItem] = cachedInboxObjects.map {
                    let inboxItem = CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                    return inboxItem
                }
                DispatchQueue.main.async {
                    completion(true, liveInboxItems, nil)
                }
            }
        }
    }

    /**
     Inbox : Function to mark inbox items as read
     */
    @objc func logInboxItemsRead(_ inboxItems: [CastledInboxItem]) {
        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems, changeReadStatus: true)
    }

    /**
     Inbox : Function to mark inbox item as clicked
     */
    @objc func logInboxItemClicked(_ inboxItem: CastledInboxItem, buttonTitle: String?) {
        CastledInboxServices().reportInboxItemsClicked(inboxObject: inboxItem, buttonTitle: buttonTitle)
    }

    /**
     Inbox : Function to delete an inbox item
     */
    @objc func deleteInboxItem(_ inboxItem: CastledInboxItem) {
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem)
    }

    /**
     Inbox : Function to dismiss CastledInboxViewController
     */
    @objc func dismissInboxViewController() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow })
        {
            if let topViewController = window.rootViewController {
                var currentViewController = topViewController
                while let presentedViewController = currentViewController.presentedViewController {
                    currentViewController = presentedViewController
                }

                // Check if the topmost view controller is a UINavigationController
                if let navigationController = currentViewController as? UINavigationController {
                    // Check if the top view controller of the navigation stack is a CastledInboxViewController
                    if let inboxViewController = navigationController.topViewController as? CastledInboxViewController {
                        // Pop to the root view controller of the navigation stack
                        inboxViewController.removeObservers()
                        inboxViewController.navigationController?.popViewController(animated: true)
                    }
                }
                else if let tabBarController = currentViewController as? UITabBarController {
                    if let selectedNavigationController = tabBarController.selectedViewController as? UINavigationController, let inboxViewController = selectedNavigationController.topViewController as? CastledInboxViewController {
                        inboxViewController.removeObservers()
                        inboxViewController.navigationController?.popViewController(animated: true)
                    }
                }
                else if let inboxViewController = currentViewController as? CastledInboxViewController {
                    // Dismiss the CastledInboxViewController if it's not embedded in a UINavigationController
                    inboxViewController.removeObservers()
                    inboxViewController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
