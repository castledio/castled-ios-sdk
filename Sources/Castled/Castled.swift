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
    
    @objc optional func castled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    
    @objc optional func notificationClicked(withNotificationType type: CastledNotificationType,action: CastledClickActionType , kvPairs: [AnyHashable : Any]?,userInfo: [AnyHashable : Any])
}

@objc public class Castled : NSObject
{
    @objc public static var sharedInstance: Castled?



    //private var appDelegate: UIApplicationDelegate
    //private var application: UIApplication
    private var shouldClearDeliveredNotifications = true
    internal var inboxItemsArray = [CastledInboxItem]()
    internal var inboxUnreadCountCallback: ((Int) -> Void)?
    internal var inboxUnreadCount: Int = 0 {
        didSet {
            // Call the callback when the unreadCount changes
            inboxUnreadCountCallback?(inboxUnreadCount)
        }
    }
    
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
    
    @objc static public func initialize(withConfig config: CastledConfigs,delegate: CastledNotificationDelegate, andNotificationCategories categories: Set<UNNotificationCategory>? = Set<UNNotificationCategory>()){
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = Castled.init(instanceId: config.instanceId, delegate: delegate,categories: categories ?? Set<UNNotificationCategory>())
        }
        
        
    }

    private init(instanceId: String,delegate: CastledNotificationDelegate,categories: Set<UNNotificationCategory>){
        
        if instanceId.count == 0{
            fatalError("'instanceId' has not been initialized. Call CastledConfigs.initialize(instanceId:) with a valid instanceId.")
        }
        self.instanceId  = instanceId
        self.delegate    = delegate
        
        super.init()
        
        if Castled.sharedInstance == nil {
            Castled.sharedInstance = self
        }
        
        CastledSwizzler.enableSwizzlingForNotifications()
        setNotificationCategories(withItems: categories)
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
    
    
    
    /**
     Function that allows users to set the badge on the app icon manually.
     */
    public func setBadge(to count: Int) {
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    /**
     InApps : Function that allows to display page view inapp
     */
    @objc public func logPageViewedEventIfAny(context : UIViewController) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        else if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.userNotRegistered.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: CIEventType.page_viewed.rawValue, params: ["name" : String(describing: type(of: context))],showLog: false)
    }
   
    /**
     InApps : Function that allows to display custom inapp
     */
    @objc public func logCustomAppEvent(context : UIViewController,eventName : String,params : [String : Any]) {
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: context, eventName: eventName, params: params,showLog: false)
    }
    
    
    
    @objc public  func swizzled_application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        castledLog("didRegisterForRemoteNotificationsWithDeviceToken swizzled \(deviceToken.debugDescription)")
        
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
        Castled.sharedInstance?.userNotificationCenter(center, willPresent: notification)
        guard ((Castled.sharedInstance?.delegate.castled_userNotificationCenter?(center, willPresent: notification, withCompletionHandler: { options in
            completionHandler(options)
        })) != nil)
        else{
            completionHandler( [[.alert, .badge, .sound]])
            return
        }
        
    }
    @objc public func swizzled_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Castled.sharedInstance?.didReceiveRemoteNotification(inApplication: application, withInfo: userInfo, fetchCompletionHandler: { _ in
            guard ((Castled.sharedInstance?.delegate.castled_application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: { result in
                completionHandler(result)
            })) != nil) else{
                completionHandler(.newData)
                return;
            }
        })
    }
    @objc public func swizzled_userNotificationCenter(_ center: UNUserNotificationCenter,
                                                      didReceiveNotificationResponse response: UNNotificationResponse,
                                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        //        castledLog("didReceive swizzled")
        
        Castled.sharedInstance?.handleNotificationAction(response: response)
        guard ((Castled.sharedInstance?.delegate.castled_userNotificationCenter?(center, didReceive: response, withCompletionHandler: {
            completionHandler()
            
        })) != nil) else{
            castledLog("castled_userNotificationCenter didReceive  not implemented")
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
    
    @objc public func didReceiveRemoteNotification(inApplication application:UIApplication, withInfo userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let customCasledDict = userInfo[CastledConstants.PushNotification.customKey] as? NSDictionary{
            if customCasledDict[CastledConstants.PushNotification.CustomProperties.notificationId] is String{
                let  sourceContext = customCasledDict[CastledConstants.PushNotification.CustomProperties.sourceContext] as? String ?? ""
                let teamID = customCasledDict[CastledConstants.PushNotification.CustomProperties.teamId] as? String ?? ""
                let params = self.getPushPayload(event: CastledConstants.CastledEventTypes.received.rawValue, teamID: teamID , sourceContext: sourceContext )
                
                var savedEventTypes = (CastledUserDefaults.getObjectFor(CastledUserDefaults.kCastledSendingPushEvents) as? [[String:String]]) ?? [[String:String]]()
                savedEventTypes.append(params)
                CastledUserDefaults.setObjectFor(CastledUserDefaults.kCastledSendingPushEvents, savedEventTypes)
                Castled.registerEvents(params: savedEventTypes) { response in
                    completionHandler(.newData)
                }
                
            }
            else{
                completionHandler(.newData)
            }
        }
        else{
            completionHandler(.newData)
            
        }
    }
    
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) {
        processCastledPushEvents(userInfo: notification.request.content.userInfo, isForeGround: true)
    }
    // The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
    @objc public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
        handleNotificationAction(response: response)
    }
    
    func handleNotificationAction(response: UNNotificationResponse){
        // Returning the same options we've requested
        var pushActionType = CastledClickActionType.custom
        let userInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier{
            if let defaultActionDetails : [String : Any] = CastledCommonClass.getDefaultActionDetails(dict: userInfo,index: CastledUserDefaults.userDefaults.value(forKey: CastledUserDefaults.kCastledClickedNotiContentIndx) as? Int ?? 0),
               let defaultAction = defaultActionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction] as? String{
                
                if defaultAction == CastledConstants.PushNotification.ClickActionType.deepLink.rawValue{
                    
                    pushActionType = CastledClickActionType.deepLink
                }
                //Navigate to screen
                else if defaultAction == CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue{
                    pushActionType = CastledClickActionType.navigateToScreen
                    
                }
                else if defaultAction == CastledConstants.PushNotification.ClickActionType.richLanding.rawValue{
                    pushActionType = CastledClickActionType.richLanding
                    
                }
                else if defaultAction == CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue{
                    pushActionType = CastledClickActionType.dismiss
                    
                    
                }
                Castled.sharedInstance?.delegate.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: defaultActionDetails, userInfo: userInfo)
                
                CastledUserDefaults.removeFor(CastledUserDefaults.kCastledClickedNotiContentIndx)
            }
            else{
                // handle other actions
                Castled.sharedInstance?.delegate.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
                
            }
            
            processCastledPushEvents(userInfo: userInfo,isOpened: true)
            
        }
        else if response.actionIdentifier == UNNotificationDismissActionIdentifier{
            Castled.sharedInstance?.delegate.notificationClicked?(withNotificationType: .push, action: .dismiss, kvPairs: nil, userInfo: userInfo)
            processCastledPushEvents(userInfo: userInfo,isDismissed: true)
        }
        else {
            if let actionDetails : [String: Any] = CastledCommonClass.getActionDetails(dict: userInfo, actionType: response.actionIdentifier),
               let clickAction = actionDetails[CastledConstants.PushNotification.CustomProperties.Category.Action.clickAction]   as? String{
                
                //Deeplink
                if clickAction == CastledConstants.PushNotification.ClickActionType.deepLink.rawValue{
                    pushActionType = CastledClickActionType.deepLink
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.deepLink.rawValue)
                }
                //Navigate to screen
                else if clickAction == CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue{
                    pushActionType = CastledClickActionType.navigateToScreen
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.navigateToScreen.rawValue)
                }
                //Richlanding
                else if clickAction == CastledConstants.PushNotification.ClickActionType.richLanding.rawValue{
                    pushActionType = CastledClickActionType.richLanding
                    processCastledPushEvents(userInfo: userInfo,isAcceptRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.richLanding.rawValue)
                }
                //Discard
                else if clickAction == CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue{
                    pushActionType = CastledClickActionType.dismiss
                    processCastledPushEvents(userInfo: userInfo,isDiscardedRich: true, actionLabel: response.actionIdentifier, actionType: CastledConstants.PushNotification.ClickActionType.discardNotification.rawValue)
                }
                Castled.sharedInstance?.delegate.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: actionDetails, userInfo: userInfo)
                
                
            }
            else{
                Castled.sharedInstance?.delegate.notificationClicked?(withNotificationType: .push, action: pushActionType, kvPairs: nil, userInfo: userInfo)
                
            }
            
        }
    }
    

    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didDismissNotification notification: UNNotification) {
        // Retrieve the notification ID from the notification content
        let userInfo = notification.request.content.userInfo
        if let notificationId = CastledCommonClass.getCastledPushNotificationId(dict: userInfo) {
            // Perform any necessary processing based on the dismissed notification
            castledLog("Notification with ID \(notificationId) was dismissed by the user without being read.")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didRemove: UNNotificationRequest) {
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
                //  castledLog("Castled PushEvents \(customCasledDict)")
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
                        event = CastledConstants.CastledEventTypes.received.rawValue
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
        if CastledConfigs.sharedInstance.enablePush == false{
            return
        }
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
    private func setNotificationCategories(withItems items:Set<UNNotificationCategory>){
        var categorySet = items
        categorySet.insert(getCastledCategory())
        UNUserNotificationCenter.current().setNotificationCategories(categorySet)
        
    }
    private func getCastledCategory() -> UNNotificationCategory{
        let castledCategory = UNNotificationCategory.init(identifier: "CASTLED_PUSH_TEMPLATE", actions: [], intentIdentifiers: [], options: .customDismissAction)
        return castledCategory
        
    }
    internal func fetchInApps(completion: @escaping () -> Void) {

    }
    @objc internal func executeBGTaskWithDelay(){
        
        CastledBGManager.sharedInstance.executeBackgroundTask {
            Castled.sharedInstance?.getInboxItems(completion: { success, items, errorMessage in
            })
        }
    }
    @objc internal func appBecomeActive() {
        Castled.sharedInstance?.processAllDeliveredNotifications(shouldClear: false)
        if CastledUserDefaults.getString(CastledUserDefaults.kCastledUserIdKey) != nil {
            Castled.sharedInstance?.logAppOpenedEventIfAny()
            perform(#selector(executeBGTaskWithDelay), with: nil, afterDelay: 2.0)
        }
    }
    
    internal func registerForPushNotifications() {
        CastledUserDefaults.setBoolean(CastledUserDefaults.kCastledEnablePushNotificationKey, true)
        Castled.sharedInstance?.delegate.registerForPush?()
    }
    private func logAppOpenedEventIfAny(showLog : Bool? = false) {
        if CastledConfigs.sharedInstance.enableInApp == false{
            return;
        }
        if Castled.sharedInstance == nil {
            castledLog("Error: ❌❌❌ \(CastledExceptionMessages.notInitialised.rawValue)")
            return
        }
        CastledInApps.sharedInstance.logAppEvent(context: nil, eventName: CIEventType.app_opened.rawValue, params: nil,showLog: showLog)
    }
}
