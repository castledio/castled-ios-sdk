//
//  Castled+Inbox.swift
//  Castled
//
//  Created by antony on 31/08/2023.
//

import Foundation
import UIKit

extension Castled {

    /**
     Inbox : Function that will returns the unread message count
     */
    @objc public func setInboxUnreadCount(callback: @escaping (Int) -> Void) {
        inboxUnreadCountCallback = callback
    }
    @objc public func getUnreadMessageCount() -> Int {

        return inboxUnreadCount
    }
    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc public func getInboxViewController(with config: CastledInboxConfig?, andDelegate delegate: CastledInboxDelegate) -> CastledInboxViewController {
          let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.inboxConfig = config ?? CastledInboxConfig()
        castledInboxVC.delegate = delegate
        castledInboxVC.inboxItems.append(contentsOf: inboxItemsArray)
        return castledInboxVC

    }
    /**
     Inbox : Function to get inbox items array
     */
    @objc public func getInboxItems(completion: @escaping (_ success: Bool, _ items: [CastledInboxItem]?, _ errorMessage: String?) -> Void) {
        Castled.fetchInboxItems {[weak self] response in
            if response.success {
                self?.inboxItemsArray.removeAll()
                self?.inboxItemsArray.append(contentsOf: response.result ?? [])
                self?.inboxUnreadCount =  self?.inboxItemsArray.filter({ $0.isRead == true }).count ?? 0
            }
            completion(response.success, response.result, response.errorMessage)
        }
    }
    /**
     Inbox : Function to mark inbox items as read
     */
    @objc public func logInboxItemsRead(_ inboxItems: [CastledInboxItem]) {
        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems)
    }
    /**
     Inbox : Function to mark inbox item as clicked
     */
    @objc public func logInboxItemClicked(_ inboxItem: CastledInboxItem, buttonTitle: String?) {
        CastledInboxServices().reportInboxItemsClicked(inboxObject: inboxItem, buttonTitle: buttonTitle)
    }
    /**
     Inbox : Function to delete an inbox item
     */
    @objc public func deleteInboxItem(_ inboxItem: CastledInboxItem, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem) { success, errorMessage in
            completion(success, errorMessage)
        }
    }
    /**
     Inbox : Function to dismiss CastledInboxViewController
     */
    @objc  public func dismissInboxViewController() {

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first(where: { $0.isKeyWindow }) {
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
                        inboxViewController.navigationController?.popViewController(animated: true)

                    }
                } else if let inboxViewController = currentViewController as? CastledInboxViewController {
                    // Dismiss the CastledInboxViewController if it's not embedded in a UINavigationController
                    inboxViewController.dismiss(animated: true, completion: nil)
                }
            }
        }

    }
}
