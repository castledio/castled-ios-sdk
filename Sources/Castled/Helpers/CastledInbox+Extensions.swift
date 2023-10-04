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
    @objc func getInboxUnreadCount(callback: @escaping (Int) -> Void) {
        inboxUnreadCountCallback = callback
        inboxUnreadCountCallback?(inboxUnreadCount)
    }

    @objc func getUnreadMessageCount() -> Int {
        return inboxUnreadCount
    }

    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc func getInboxViewController(with config: CastledInboxConfig?, andDelegate delegate: CastledInboxDelegate) -> CastledInboxViewController {
        let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.inboxConfig = config ?? CastledInboxConfig()
        castledInboxVC.delegate = delegate
        return castledInboxVC
    }

    /**
     Inbox : Function to get inbox items array
     */
    @objc func getInboxItems(completion: @escaping (_ success: Bool, _ items: [CastledInboxItem]?, _ errorMessage: String?) -> Void) {
        CastledStore.castledStoreQueue.async {
            do {
                let backgroundRealm = CastledDBManager.shared.getRealm()
                try backgroundRealm.write {
                    let cachedInboxObjects = backgroundRealm.objects(CAppInbox.self)
                    let liveInboxItems: [CastledInboxItem] = cachedInboxObjects.map {
                        let inboxItem = CastledInboxResponseConverter.convertToInboxItem(appInbox: $0)
                        return inboxItem
                    }
                    DispatchQueue.main.async {
                        completion(true, liveInboxItems, nil)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, [], error.localizedDescription)
                }
            }
        }
    }

    /**
     Inbox : Function to mark inbox items as read
     */
    @objc func logInboxItemsRead(_ inboxItems: [CastledInboxItem]) {
        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems)
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
    @objc func deleteInboxItem(_ inboxItem: CastledInboxItem, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem) { success, errorMessage in
            completion(success, errorMessage)
        }
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
                } else if let inboxViewController = currentViewController as? CastledInboxViewController {
                    // Dismiss the CastledInboxViewController if it's not embedded in a UINavigationController
                    inboxViewController.removeObservers()
                    inboxViewController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    internal func logInboxObjectsRead(readItemsObjects: [CAppInbox]) {
        guard let realm = try? Realm() else { return }
        var readItems = [CastledInboxItem]()
        realm.writeAsync {
            for item in readItemsObjects {
                readItems.append(CastledInboxResponseConverter.convertToInboxItem(appInbox: item))
                item.isRead = true
            }

        } onComplete: { error in
            if !(error != nil) {
                Castled.sharedInstance?.logInboxItemsRead(readItems)
            }
        }
    }

    internal func refreshInboxItems(liveInboxResponse: [CastledInboxItem]) {
        if CastledStore.isInserting {
            return
        }
        CastledStore.isInserting = true
        CastledStore.castledStoreQueue.async {
            guard let backgroundRealm = try? Realm() else { return }
            autoreleasepool {
                try! backgroundRealm.write {
                    // Map live inbox response to Realm objects and add them to the Realm
                    let liveInboxItems = liveInboxResponse.map { responseItem -> CAppInbox in
                        let inboxItem = CastledInboxResponseConverter.convertToInbox(inboxItem: responseItem, realm: backgroundRealm)
                        return inboxItem
                    }
                    backgroundRealm.add(liveInboxItems, update: .modified) // Insert or update as necessary
                    let cachedInboxItems = backgroundRealm.objects(CAppInbox.self)
                    let liveInboxItemIds = Set(liveInboxItems.map { $0.messageId })
                    let expiredInboxItems = cachedInboxItems.filter { !liveInboxItemIds.contains($0.messageId) }
                    backgroundRealm.delete(expiredInboxItems)
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    self.inboxUnreadCount = backgroundRealm.objects(CAppInbox.self)
                        .filter("isRead == false")
                        .count
                    CastledStore.isInserting = false
                }
            }
        }
    }
}
