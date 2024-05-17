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
            inboxUnreadCountCallback?(inboxUnreadCount)
        }
    }

    var userId = ""
    var inboxUnreadCountCallback: ((Int) -> Void)?
    let castledConfig = Castled.sharedInstance.getCastledConfig()
    private var isInitilized = false

    override private init() {}

    @objc public func initializeAppInbox() {
        if !Castled.sharedInstance.isCastledInitialized() {
            CastledLog.castledLog("Inbox initialization failed: \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        else if isInitilized {
            CastledLog.castledLog("Inbox module already initilized! \(CastledExceptionMessages.notInitialised.rawValue)", logLevel: CastledLogLevel.info)
            return
        }
        isInitilized = true
        CastledInboxController.sharedInstance.initialize()
        CastledLog.castledLog("Inbox module initilized!", logLevel: CastledLogLevel.info)
    }

    /**
     Inbox : Function that will returns the unread message count
     */
    @objc public func observeUnreadCountChanges(listener: @escaping (Int) -> Void) {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        inboxUnreadCountCallback = listener
        inboxUnreadCountCallback?(inboxUnreadCount)
    }

    @objc public func getInboxUnreadCount() -> Int {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return 0
        }
        return inboxUnreadCount
    }

    /**
     Inbox : Function that will returns the Inbox ViewController
     */
    @objc public func getInboxViewController(withUIConfigs config: CastledInboxDisplayConfig?, andDelegate delegate: CastledInboxViewControllerDelegate) -> CastledInboxViewController {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            // throw fatal error
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
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            completion(false, [], CastledExceptionMessages.inboxNotInitialised.rawValue)

            // completion also
            return
        }
        CastledStore.castledStoreQueue.async {
            if !CastledInbox.sharedInstance.castledConfig.enableAppInbox {
                completion(false, [], CastledExceptionMessages.appInboxDisabled.rawValue)
                CastledLog.castledLog("GetInboxItems failed: \(CastledExceptionMessages.appInboxDisabled.rawValue)", logLevel: CastledLogLevel.error)
                return
            }
            if CastledInbox.sharedInstance.userId.isEmpty {
                CastledLog.castledLog("GetInboxItems failed: \(CastledExceptionMessages.userNotRegistered.rawValue)", logLevel: .error)
                completion(false, [], CastledExceptionMessages.userNotRegistered.rawValue)
                return
            }
            DispatchQueue.main.async {
                completion(true, CastledDBManager.shared.getLiveInboxItems(), nil)
            }
        }
    }

    /**
     Inbox : Function to mark inbox items as read
     */
    @objc public func logInboxItemsRead(_ inboxItems: [CastledInboxItem]) {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInboxServices().reportInboxItemsRead(inboxItems: inboxItems, changeReadStatus: true)
    }

    /**
     Inbox : Function to mark inbox item as clicked
     */
    @objc public func logInboxItemClicked(_ inboxItem: CastledInboxItem, buttonTitle: String?) {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInboxServices().reportInboxItemsClicked(inboxObject: inboxItem, buttonTitle: buttonTitle)
    }

    /**
     Inbox : Function to delete an inbox item
     */
    @objc public func deleteInboxItem(_ inboxItem: CastledInboxItem) {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
            return
        }
        CastledInboxServices().reportInboxItemsDeleted(inboxObject: inboxItem)
    }

    /**
     Inbox : Function to dismiss CastledInboxViewController
     */
    @objc public func dismissInboxViewController() {
        if !isInitilized {
            CastledLog.castledLog("Inbox operation failed: \(CastledExceptionMessages.inboxNotInitialised.rawValue)", logLevel: CastledLogLevel.error)
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
