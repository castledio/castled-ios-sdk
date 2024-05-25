//
//  CastledInbox.swift
//  CastledInbox
//
//  Created by antony on 16/05/2024.
//

@_spi(CastledInternal) import Castled
import Foundation
import UIKit

@objc public class CastledInbox: NSObject {
    @objc public static var sharedInstance = CastledInbox()

    lazy var inboxUnreadCount: Int = {
        CastledStore.getInboxUnreadCount()

    }() {
        didSet {
            if oldValue != inboxUnreadCount {
                inboxUnreadCountCallback?(inboxUnreadCount)
            }
        }
    }

    var userId = ""
    var inboxUnreadCountCallback: ((Int) -> Void)?
    let castledConfig = CastledShared.sharedInstance.getCastledConfig()
    var isInitilized = false

    override private init() {}

    func initializeAppInbox() {
        if !castledConfig.enableAppInbox {
            return
        }
        if isInitilized {
            CastledLog.castledLog("Inbox module already initialized.. \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.info)
            return
        }
        CastledRequestHelper.sharedInstance.registerHandlerWith(key: CastledConstants.CastledNetworkRequestType.inboxRequest.rawValue, handler: CastledInboxRequestHandler.self)
        CastledInboxController.sharedInstance.initialize()
        isInitilized = true
        CastledLog.castledLog("Inbox module initialized..", logLevel: CastledLogLevel.info)
    }

    private func isValidated() -> Bool {
        if !castledConfig.enableAppInbox {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.appInboxDisabled.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
        else if userId.isEmpty {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }
        else if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return false
        }

        return true
    }

    /**
     Inbox : Function that will returns the unread message count
     */
    @objc public func observeUnreadCountChanges(listener: @escaping (Int) -> Void) {
        if !isValidated() {
            return
        }
        inboxUnreadCountCallback = listener
        inboxUnreadCountCallback?(inboxUnreadCount)
    }

    @objc public func getInboxUnreadCount() -> Int {
        if !isValidated() {
            return 0
        }
        return inboxUnreadCount
    }

    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc public func getInboxViewController(withUIConfigs config: CastledInboxDisplayConfig?, andDelegate delegate: CastledInboxViewControllerDelegate) -> CastledInboxViewController {
        if !isValidated() {
            CastledLog.castledLog("Unable to initilize CastledInboxViewController!!!", logLevel: .error)
        }
        let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: CastledInbox.self)).instantiateViewController(identifier: "CastledInboxViewController") as! CastledInboxViewController
        castledInboxVC.inboxConfig = config ?? CastledInboxDisplayConfig()
        castledInboxVC.delegate = delegate
        return castledInboxVC
    }

    /**
     Inbox : Function to get inbox items array
     */
    @objc public func getInboxItems(completion: @escaping (_ success: Bool, _ items: [CastledInboxItem]?, _ errorMessage: String?) -> Void) {
        if !isValidated() {
            completion(false, [], CastledExceptionMessages.notInitialised.rawValue)
            return
        }
        CastledStore.castledStoreQueue.async {
            DispatchQueue.main.async {
                completion(true, CastledDBManager.shared.getLiveInboxItems(), nil)
            }
        }
    }

    /**
     Inbox : Function to mark inbox items as read
     */
    @objc public func logInboxItemsRead(_ inboxItems: [CastledInboxItem]) {
        if !isValidated() {
            return
        }
        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems, changeReadStatus: true)
    }

    /**
     Inbox : Function to mark inbox item as clicked
     */
    @objc public func logInboxItemClicked(_ inboxItem: CastledInboxItem, buttonTitle: String?) {
        if !isValidated() {
            return
        }
        CastledInboxServices().reportInboxItemsClicked(inboxObject: inboxItem, buttonTitle: buttonTitle)
    }

    /**
     Inbox : Function to delete an inbox item
     */
    @objc public func deleteInboxItem(_ inboxItem: CastledInboxItem) {
        if !isValidated() {
            return
        }
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem)
    }

    /**
     Inbox : Function to dismiss CastledInboxViewController
     */
    @objc public func dismissInboxViewController() {
        if !isValidated() {
            return
        }
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
