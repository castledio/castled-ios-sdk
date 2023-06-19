//
//  Castled.swift
//  CastledPusher
//
//  Created by Antony Joe Mathew.
//

import Foundation
import UserNotifications
import UIKit


@objc public protocol CastledNotificationDelegate  {
    
    @objc optional func registerForPush()
    
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    
    @objc optional func castled_userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    
    @objc optional func castled_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    
    @objc optional func castled_application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    
    @objc optional func navigateToScreen(scheme: String?, viewControllerName: String?)
    
    @objc optional func handleDeepLink(url: URL?, useWebview: Bool , additionalData: [String: Any]?)
    
    @objc optional func handleNavigateToScreen(screenName: String?, useWebview: Bool , additionalData: [String: Any]?)
    
    @objc optional func handleRichLanding(screenName: String?, useWebview: Bool , additionalData: [String: Any]?)
    
}

extension CastledNotificationDelegate {
    // without the completion parameter
    func navigateToScreen(scheme: String, viewControllerName: String) {
        navigateToScreen?(scheme: nil, viewControllerName: nil)
    }
}

@objc public class Castled : NSObject
{
    @objc public static var sharedInstance: Castled?
    //private var appDelegate: UIApplicationDelegate
    //private var application: UIApplication
    private var shouldClearDeliveredNotifications = true
    var instanceId: String
    let delegate: CastledNotificationDelegate
    var clientRootViewController: UIViewController?
    
    //Create a dispatch queue
    private let castledDispatchQueue = DispatchQueue(label: "CastledQueue", qos: .background)
    internal let castledNotificationQueue = DispatchQueue(label: "CastledNotificationQueue", qos: .background)
    
    //Create a semaphore
    private let castledSemaphore = DispatchSemaphore(value: 1)
    
    /**
     Static method for conguring the Castled framework.
     */
    @objc static public func configure(registerIn application: UIApplication,launchOptions : [UIApplication.LaunchOptionsKey: Any]?,
                                       instanceId: String,delegate: CastledNotificationDelegate){
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = Castled.init(registerIn: application, launchOptions: launchOptions, instanceId: instanceId, delegate: delegate)
        }
    }
    
    
    private init(registerIn application: UIApplication,launchOptions : [UIApplication.LaunchOptionsKey: Any]? ,instanceId: String,delegate: CastledNotificationDelegate,clearNotifications : NSNumber? = 1) {
        
        //self.application = application
        //self.appDelegate = application.delegate!
        self.instanceId  = instanceId
        self.delegate    = delegate
        
        super.init()
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = self
        }
        
        shouldClearDeliveredNotifications = ((clearNotifications?.boolValue) != nil)
        CastledSwizzler.enableSwizzlingForNotifications()
        
        let config = CastledConfigs.sharedInstance
        
        if config.enablePush == true || CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledEnablePushNotificationKey) == true{
            registerForPushNotifications()
        }
        initialSetup()
    }
    
    private func initialSetup(){
        
        UIViewController.swizzleViewDidAppear()
        CastledBGManager.sharedInstance.registerBackgroundTasks()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc public func appBecomeActive() {
        Castled.sharedInstance?.logAppOpenedEventIfAny()
        Castled.sharedInstance?.processAllDeliveredNotifications(shouldClear: false)
        if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) != nil {
            perform(#selector(executeBGTaskWithDelay), with: nil, afterDelay: 2.5)
        }
    }
    
    @objc private func executeBGTaskWithDelay(){
        CastledBGManager.sharedInstance.executeBackgroundTask {
        }
    }
    
    // MARK: - Private
    // Method to register for push notification
    internal func registerForPushNotifications() {
        CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledEnablePushNotificationKey, true)
        Castled.sharedInstance?.delegate.registerForPush?()
    }
    
    /**
     Function that allows users to set the badge on the app icon manually.
     */
    public func setBadge(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    /**
     InApps : Function that allows to display page view inapp
     */
    public func logPageViewedEventIfAny(context : UIViewController,showLog : Bool? = false) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: CIEventType.page_viewed.rawValue, params: ["name" : String(describing: type(of: context))],showLog: showLog)
    }
    
    /**
     InApps : Function that allows to display custom inapp
     */
    public func logCustomAppEvent(context : UIViewController,eventName : String,params : [String : Any],showLog : Bool? = true) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: eventName, params: params,showLog: showLog)
    }
    
    
    internal func logAppOpenedEventIfAny(showLog : Bool? = false) {
        if CastledConfigs.sharedInstance.enableInApp == false{
            return;
        }
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil,showLog: showLog)
    }
    
    @objc public  func swizzled_application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        castledLog("didRegisterForRemoteNotificationsWithDeviceToken swizzled \(self) \(deviceToken.debugDescription)")
        
        Castled.sharedInstance?.setDeviceToken(deviceToken: deviceToken)
        Castled.sharedInstance?.delegate.castled_application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    @objc public func swizzled_application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        castledLog("Failed to register: \(error)")
        Castled.sharedInstance?.delegate.castled_application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    @objc public func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                                      willPresentNotification notification: UNNotification,
                                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        castledLog("willPresent swizzled")
        
        Castled.sharedInstance?.handleNotificationInForeground(notification: notification)
        guard (Castled.sharedInstance?.delegate.castled_userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)) != nil else{
            castledLog("willPresent  not implemented")
            completionHandler( [[.alert, .badge, .sound]])
            return
        }
    }
    
    @objc public func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                                      didReceiveNotificationResponse response: UNNotificationResponse,
                                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        castledLog("didReceive swizzled")
        
        Castled.sharedInstance?.handleNotificationAction(response: response)
        guard (Castled.sharedInstance?.delegate.castled_userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)) != nil else{
            castledLog("didReceive  not implemented")
            completionHandler()
            return
        }
    }
    
    
    @objc public func setDeviceToken(deviceToken : Data){
        let deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        castledLog("deviceTokenString  \(deviceTokenString)")
        
        let oldToken = CastledUserDefaults.getString(CastledUserDefaults.kCastledAPNsTokenKey) ?? ""
        if oldToken != deviceTokenString || CastledUserDefaults.getBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey) == false{
            CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledIsTokenRegisteredKey, false)
            CastledUserDefaults.setString(CastledUserDefaults.kCastledAPNsTokenKey, deviceTokenString)
            if let uid = CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey)
            {
                Castled.registerUser(userId: uid, apnsToken: deviceTokenString)
            }
        }
    }
    
    @objc public func handleNotificationInForeground(notification: UNNotification){
        processCastledPushEvents(userInfo: notification.request.content.userInfo, isForeGround: true)
        
        //Castled.sharedInstance?.registerNotificationCategories(userInfo: notification.request.content.userInfo)
        castledLog("notification userInfo \(notification.request.content.userInfo)")
    }
    
    
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @objc public func handleNotificationAction(response: UNNotificationResponse){
        // Returning the same options we've requested
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier{
            if let defaultActionDetails : [String : Any] = CastledCommonClass.getDefaultActionDetails(dict: userInfo){
                let defaultAction = defaultActionDetails["default_action"] as! String,
                    defaultActionURL = defaultActionDetails["default_action_url"] as? String,
                    url = URL(string: defaultActionURL ?? "")
                
                if defaultAction == CastledConstants.PushNotification.ActionType.deepLink.rawValue{
                    Castled.sharedInstance?.delegate.handleDeepLink?(url: url, useWebview: false, additionalData: nil)
                }
                //Navigate to screen
                else if defaultAction == CastledConstants.PushNotification.ActionType.navigateToScreen.rawValue{
                    Castled.sharedInstance?.delegate.handleNavigateToScreen?(screenName: defaultActionURL, useWebview: false, additionalData: nil)
                }
                else if defaultAction == CastledConstants.PushNotification.ActionType.richLanding.rawValue{
                    Castled.sharedInstance?.delegate.handleRichLanding?(screenName: defaultActionURL, useWebview: false, additionalData: nil)
                }
                else if defaultAction == CastledConstants.PushNotification.ActionType.discardNotification.rawValue{
                    castledLog("discard")
                }
                processCastledPushEvents(userInfo: userInfo,isOpened: true)
            }
            
        }
        else if response.actionIdentifier == UNNotificationDismissActionIdentifier{
            processCastledPushEvents(userInfo: userInfo,isDismissed: true)
        }
        else {
            if let actionDetails : [String: Any] = CastledCommonClass.getActionDetails(dict: userInfo, actionType: response.actionIdentifier){
                let clickAction = actionDetails["clickAction"] as! String,
                    url = actionDetails["url"] as! String,
                    useWebView = actionDetails["useWebview"] as! Bool
                
                //Deeplink
                if clickAction == CastledConstants.PushNotification.ActionType.deepLink.rawValue{
                    castledLog("Deeplink")
                    //Castled.sharedInstance?.delegate.navigateToScreen(scheme:url, viewControllerName: nil)
                    if let url = URL(string: url) {
                        //UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        Castled.sharedInstance?.delegate.handleDeepLink?(url: url, useWebview: useWebView, additionalData: nil)
                    }
                    
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.kCastledPushActionTypeDeeplink)
                }
                //Navigate to screen
                else if clickAction == CastledConstants.PushNotification.ActionType.navigateToScreen.rawValue{
                    castledLog("navigatetoscreen")
                    Castled.sharedInstance?.delegate.handleNavigateToScreen?(screenName: url, useWebview: useWebView, additionalData: nil)
                    
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.kCastledPushActionTypeNavigate)
                }
                //Richlanding
                else if clickAction == CastledConstants.PushNotification.ActionType.richLanding.rawValue{
                    castledLog("richlanding")
                    Castled.sharedInstance?.delegate.handleRichLanding?(screenName: url, useWebview: useWebView, additionalData: nil)
                    
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.kCastledPushActionTypeRichLanding)
                }
                //Discard
                else if clickAction == CastledConstants.PushNotification.ActionType.discardNotification.rawValue{
                    castledLog("discard")
                    processCastledPushEvents(userInfo: userInfo,isDiscardedRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.kCastledPushActionTypeDiscardNotifications)
                }
            }
        }
    }
    
    func openAppForDefaultAction(userInfo: [AnyHashable: Any]) {
        if let scheme = CastledCommonClass.getSchemeFromPlist() {
            castledLog("The scheme is \(scheme)")
            let url = URL(string: "\(scheme)://")!
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            processCastledPushEvents(userInfo: userInfo,isOpened: true)
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didDismissNotification notification: UNNotification) {
        // Retrieve the notification ID from the notification content
        let userInfo = notification.request.content.userInfo
        if let notificationId = CastledCommonClass.getCastledPushNotificationId(dict: userInfo) {
            // Perform any necessary processing based on the dismissed notification
            castledLog("Notification with ID \(notificationId) was dismissed by the user without being read.")
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didRemove: UNNotificationRequest) {
        // Retrieve the notification ID from the notification content
        let userInfo = didRemove.content.userInfo
        if let notificationId = CastledCommonClass.getCastledPushNotificationId(dict: userInfo) {
            // Perform any necessary processing based on the dismissed notification
            castledLog("Notification with ID \(notificationId) was dismissed by the user without being read.")
        }
    }
    
    func checkAppIsLaunchedViaPush(launchOptions : [UIApplication.LaunchOptionsKey: Any]?){
        let notificationOption = launchOptions?[.remoteNotification]
        if let notification = notificationOption as? [String: AnyObject],
           let _ = notification["aps"] as? [String: AnyObject] {
            
            processCastledPushEvents(userInfo: notification,isOpened: true)
            
        }
    }
    
    func processCastledPushEvents(userInfo : [AnyHashable : Any],isForeGround: Bool? = false , isOpened : Bool? = false, isDismissed : Bool? = false, isDiscardedRich: Bool? = false, isAcceptRich: Bool? = false, actionLabel: String? = "", actionType: String? = ""){
        castledNotificationQueue.async{
            if let customCasledDict = userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary{
                castledLog("Castled PushEvents \(customCasledDict)")
                if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String{
                    let sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String
                    let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String
                    
                    var event = CastledConstants.CastledEventTypes.received.rawValue
                    
                    if isOpened == true{
                        event = CastledConstants.CastledEventTypes.cliked.rawValue
                    }
                    else if isDismissed == true{
                        event = CastledConstants.CastledEventTypes.discarded.rawValue
                    }
                    
                    if isDiscardedRich == true{
                        event = CastledConstants.CastledEventTypes.discarded.rawValue
                    }
                    else if isAcceptRich == true{
                        event = CastledConstants.CastledEventTypes.cliked.rawValue
                    }
                    
                    if isForeGround == true {
                        event = CastledConstants.CastledEventTypes.foreground.rawValue
                    }
                    
                    
                    let params = self.getPushPayload(event: event, teamID: teamID ?? "", sourceContext: sourceContext ?? "",actionLabel: actionLabel,actionType: actionType)
                    
                    var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingPushEvents) as? [[String:String]]) ?? [[String:String]]()
                    let existingEvents = savedEventTypes.filter { $0["eventType"] == event &&
                        $0["sourceContext"] == sourceContext}
                    
                    if existingEvents.count == 0
                    {
                        savedEventTypes.append(params)
                    }
                    CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingPushEvents, savedEventTypes)
                    
                    Castled.registerEvents(params: savedEventTypes) { response in
                        
                    }
                    
                }
            }
        }
    }
    
    func processAllDeliveredNotifications(shouldClear : Bool){
        castledNotificationQueue.async {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.getDeliveredNotifications { (receivedNotifications) in
                    var castledPushEvents = [[String : String]]()
                    
                    for notification in receivedNotifications {
                        let content = notification.request.content
                        if let customCasledDict = content.userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary{
                            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String{
                                let  sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
                                let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String ?? ""
                                let params = self.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, teamID: teamID , sourceContext: sourceContext )
                                castledPushEvents.append(params)
                            }
                        }
                    }
                    
                    if(castledPushEvents.count > 0){
                        var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingPushEvents) as? [[String:String]]) ?? [[String:String]]()
                        savedEventTypes.append(contentsOf: castledPushEvents)
                        CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingPushEvents, savedEventTypes)
                        Castled.registerEvents(params: savedEventTypes) { response in
                            
                        }
                    }
                    
                    if shouldClear == true{
                        DispatchQueue.main.async {
                            center.removeAllDeliveredNotifications()
                        }
                    }
                }
            }
        }
    }
    
    func getPushPayload(event : String, teamID : String, sourceContext : String, actionLabel : String? = "",actionType : String? = "") -> [String : String]{
        let timezone = TimeZone.current
        let abbreviation = timezone.abbreviation(for: Date()) ?? "GMT"
        
        var params =  ["eventType" : event,"appInBg" : String(false),"ts":"\(Int(Date().timeIntervalSince1970))","tz":abbreviation, "teamId": teamID , "sourceContext": sourceContext ] as [String : String]
        
        if actionLabel?.count ?? 0 > 0{
            params["actionLabel"] = actionLabel
        }
        if actionType?.count ?? 0 > 0{
            params["actionType"] = actionType
        }
        return params
    } 
}
