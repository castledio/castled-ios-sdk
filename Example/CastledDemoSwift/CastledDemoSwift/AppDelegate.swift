//
//  AppDelegate.swift
//  CastledDemo
//
//  Created by Antony Joe Mathew.
//

import Castled
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config = CastledConfigs.initialize(appId: "718c38e2e359d94367a2e0d35e1fd4df")
        config.enableAppInbox = true
        config.enablePush = true
        config.enableInApp = true
        config.enableTracking = true
        config.enableSessionTracking = true
        config.skipUrlHandling = false
        config.sessionTimeOutSec = 60
        config.location = CastledLocation.US
        config.logLevel = CastledLogLevel.debug
        config.appGroupId = "group.com.castled.CastledPushDemo.Castled"
        // Register the custom category
        Castled.initialize(withConfig: config, andDelegate: self)
//        Castled.sharedInstance.setUserId("antony@castled.io", userToken: nil)
        registerForPush()

        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = .link
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).standardAppearance = navBarAppearance
            UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self]).scrollEdgeAppearance = navBarAppearance
        }
        let notificationCategories = getNotificationCategories()
        Castled.sharedInstance.setNotificationCategories(withItems: notificationCategories)
        window?.makeKeyAndVisible()
        Castled.sharedInstance.setLaunchOptions(launchOptions)
        return true
    }

    func getNotificationCategories() -> Set<UNNotificationCategory> {
        // Create the custom actions
        let action1 = UNNotificationAction(identifier: "ACCEPT", title: "Accept", options: UNNotificationActionOptions.foreground)
        let action2 = UNNotificationAction(identifier: "DECLINE", title: "Decline", options: UNNotificationActionOptions.foreground)

        // Create the category with the custom actions
        let customCategory1 = UNNotificationCategory(identifier: "ACCEPT_DECLINE", actions: [action1, action2], intentIdentifiers: [], options: [])

        let action3 = UNNotificationAction(identifier: "YES", title: "Yes", options: [UNNotificationActionOptions.foreground])
        let action4 = UNNotificationAction(identifier: "NO", title: "No", options: [])

        // Create the category with the custom actions
        let customCategory2 = UNNotificationCategory(identifier: "YES_NO", actions: [action3, action4], intentIdentifiers: [], options: [])

        let categoriesSet = Set([customCategory1, customCategory2])

        return categoriesSet
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // code to handle the URL

        if url.scheme == "com.castled" {
            let host = url.host
            // let pathComponents = url.pathComponents
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print("url is -- > \(url)")
            print("host  -- > \(String(describing: host))")
            print("parameters  -- > \(parameters)")
            let queryString = queryString(from: parameters)
            print("queryString  -- > \(queryString)")

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "DeeplinkViewController") as? DeeplinkViewController {
                guard let rootViewController = window?.rootViewController else {
                    return false
                }
                vc.params = parameters
                // If the root view controller is a navigation controller, push the view controller onto its stack
                if let navigationController = rootViewController as? UINavigationController {
                    navigationController.pushViewController(vc, animated: true)
                } else {
                    // If the root view controller is not a navigation controller, present the view controller modally
                    rootViewController.present(vc, animated: true, completion: nil)
                }
            }
        }

        return true
    }

    func queryString(from parameters: [String: String]) -> String {
        var components = URLComponents()
        components.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return components.percentEncodedQuery ?? ""
    }

    func topController() -> UIViewController {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), var topController = keyWindow.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController)!
    }
}

// MARK: - CastledNotification Delegate Methods

extension AppDelegate: CastledNotificationDelegate {
    func registerForPush() {
        UNUserNotificationCenter.current().delegate = self
        Castled.sharedInstance.promptForPushNotification()
    }

    func notificationClicked(withNotificationType type: CastledNotificationType, action: CastledClickActionType, kvPairs: [AnyHashable: Any]?, userInfo: [AnyHashable: Any]) {
        let inboxCopyEnabled = kvPairs?["inboxCopyEnabled"] as? Bool ?? false

        print("type \(type.rawValue) action \(action.rawValue) kvPairs \(kvPairs)\n*****************inboxCopyEnabled \(inboxCopyEnabled)")
        switch action {
            case .deepLink:
                if let details = kvPairs, let value = details["clickActionUrl"] as? String, let url = URL(string: value) {
                    handleDeepLink(url: url)
                }

            case .navigateToScreen:
                if let details = kvPairs, let screenName = details["clickActionUrl"] as? String {
                    handleNavigateToScreen(screenName: screenName)
                }
            case .richLanding:
                // TODO:

                break
            case .requestForPush:
                // TODO:

                break
            case .dismiss:
                // TODO:

                break
            case .custom:
                // TODO:

                break
            default:
                break
        }
    }

    func didReceiveCastledRemoteNotification(withInfo userInfo: [AnyHashable: Any]) {
        //  print("didReceiveCastledRemoteNotification \(userInfo)")
    }
}

// MARK: - Push Notification Delegate Methods

extension AppDelegate: UNUserNotificationCenterDelegate {
    /*************************************************************IMPPORTANT*************************************************************/
    // If you disabled the swizzling in plist you should call the required functions in the delegate methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Castled.sharedInstance.setPushToken(deviceTokenString, CastledPushTokenType.apns)
        print("APNs token \(deviceTokenString) \(description)")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications \(error.localizedDescription)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the click events
        Castled.sharedInstance.userNotificationCenter(center, didReceive: response)
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Castled.sharedInstance.userNotificationCenter(center, willPresent: notification)
        completionHandler([.alert, .badge, .sound])
    }

    /*   func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
         Castled.sharedInstance.didReceiveRemoteNotification(inApplication: application, withInfo: userInfo, fetchCompletionHandler: { response in
             completionHandler(response)

         })
     }*/
}

// MARK: - Supporting Methods for CastledPusherExample

private extension AppDelegate {
    func handleDeepLink(url: URL?) {
        guard let url = url else { return }
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let scheme = components?.scheme // "com.castled"
        let path = components?.path // "/deeplinkvc"
        let host = components?.host
        print("Path \(String(describing: path))")
        guard scheme == "com.castled", path == "/deeplinkvc" || host == "deeplinkvc" else { return }

        // Instantiate the deeplink view controller and pass the query parameters
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DeeplinkViewController") as? DeeplinkViewController else { return }

        presentViewController(vc)
    }

    func handleNavigateToScreen(screenName: String?) {
        guard let screenName = screenName else { return }
        guard let vc = instantiateViewController(screenName: screenName) else {
            return
        }
        presentViewController(vc)
    }

    func handleRichLanding(screenName: String?) {}

    func getVisibleViewController(from viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return getVisibleViewController(from: navigationController.visibleViewController ?? navigationController)
        } else if let tabBarController = viewController as? UITabBarController {
            return getVisibleViewController(from: tabBarController.selectedViewController ?? tabBarController)
        } else if let presentedViewController = viewController.presentedViewController {
            return getVisibleViewController(from: presentedViewController)
        } else {
            return viewController
        }
    }

    func presentViewController(_ viewController: UIViewController) {
        guard let rootViewController = getRootViewController() else { return }
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            rootViewController.present(viewController, animated: true, completion: nil)
        }
    }

    func getRootViewController() -> UIViewController? {
        if #available(iOS 13, *) {
            guard let scene = UIApplication.shared.connectedScenes.first,
                  let sceneDelegate = scene.delegate as? SceneDelegate,
                  let window = sceneDelegate.window
            else {
                return nil
            }
            return window.rootViewController
        } else {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }

    func instantiateViewController(screenName: String) -> UIViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch screenName {
            case "DeeplinkViewController":
                guard let vc = storyboard.instantiateViewController(withIdentifier: "DeeplinkViewController") as? DeeplinkViewController else {
                    return nil
                }
                return vc
            case "SecondViewController":
                guard let vc = storyboard.instantiateViewController(withIdentifier: "SecondViewController") as? SecondViewController else {
                    return nil
                }
                return vc
            default:
                return nil
        }
    }
}
