//
//  AppDelegate.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "AppDelegate.h"
#import <Castled/Castled-Swift.h>
//#import <Castled-Swift.h>

#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate,CastledNotificationDelegate>
{

}
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //1. Configure config
    CastledConfigs *config = [CastledConfigs initializeWithAppId:@"718c38e2e359d94367a2e0d35e1fd4df"];
    config.enablePush = TRUE;
    config.enableInApp = TRUE;
    config.enableAppInbox = TRUE;
    config.enableTracking  = TRUE;
    config.enableSessionTracking = TRUE;
    config.sessionTimeOutSec = 60;
    config.skipUrlHandling = FALSE;
    config.appGroupId = @"group.com.castled.CastledPushDemo.Castled";
    //2. Call Castled.initialize method
   [Castled initializeWithConfig:config andDelegate:self];
    [[Castled sharedInstance] setNotificationCategoriesWithItems:[self getNotificationCategories]];
    //3. Register Push
    [self registerForPush];

    
    return YES;
}

- (NSSet<UNNotificationCategory *> *)getNotificationCategories {
    // Create the custom actions
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"ACCEPT" title:@"Accept" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"DECLINE" title:@"Decline" options:0];

    // Create the category with the custom actions
    UNNotificationCategory *customCategory1 = [UNNotificationCategory categoryWithIdentifier:@"ACCEPT_DECLINE" actions:@[action1, action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];

    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"YES" title:@"Yes" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"NO" title:@"No" options:0];

    // Create the category with the custom actions
    UNNotificationCategory *customCategory2 = [UNNotificationCategory categoryWithIdentifier:@"YES_NO"
                                                                                       actions:@[action3, action4]
                                                                             intentIdentifiers:@[]
                                                                                       options:UNNotificationCategoryOptionCustomDismissAction];
    NSSet<UNNotificationCategory *> *categoriesSet = [NSSet setWithObjects:customCategory1, customCategory2, nil];

    return categoriesSet;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - UNUserNotificationCenter Delegate Methods

- (void)registerForPush {

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = (id)self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
        if( !error ){
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
}


/*************************************************************IMPPORTANT*************************************************************/
//If you disabled the swizzling in plist you should call the required functions in the delegate methods

/// Called when the application successfully registers with the Apple Push Notification service (APNs).
/// If method swizzling is disabled, manually set the device token through the Castled SDK.
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSMutableString *deviceTokenString =[NSMutableString string];
    if (@available(iOS 13.0, *)) {
        deviceTokenString = [NSMutableString string];
        const unsigned char *bytes = (const unsigned char *)[deviceToken bytes];
        NSInteger count = deviceToken.length;
        for (int i = 0; i < count; i++) {
            [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
        }
    } else {
        NSString *deviceToken1 =  [[[[deviceToken description]
                                     stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
        deviceTokenString = [[NSMutableString alloc] initWithString:deviceToken1];
    }
     [[Castled sharedInstance] setPushToken:deviceTokenString type:CastledPushTokenTypeApns];

}


-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"failed to register for remote notifications: %@ %@", self.description, error.localizedDescription);
}
-(void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    //response.notification.request.content.userInfo
    NSLog(@"didReceiveNotificationResponse: %@", self.description);
    [[Castled sharedInstance] userNotificationCenter:center didReceive:response];

    completionHandler();
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    //notification.request.content.userInfo
    NSLog(@"willPresentNotification: %@", self.description);
    [[Castled sharedInstance] userNotificationCenter:center willPresent:notification];

    completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
   
    [[Castled sharedInstance] didReceiveRemoteNotification:userInfo];
    
    // Implement your logic here...
    
    completionHandler(UIBackgroundFetchResultNoData);
     
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    // Your implementation goes here

    return YES; // Return YES if the URL was handled successfully, or NO if not.
}
#pragma mark - CastledNotification Delegate Methods
- (void)notificationClickedWithNotificationType:(CastledNotificationType)type buttonAction:(CastledButtonAction *)buttonAction userInfo:(NSDictionary *)userInfo{
        /*
         CastledNotificationType
            0 .push
            1 .inapp
         */
        NSLog(@"CastledNotificationType: %ld\nbuttonTitle: %@\nactionUri:%@\nkeyVals: %@\ninboxCopyEnabled: %@\nButtonActionType: %ld",
          (long)type,
          buttonAction.buttonTitle ?: @"",
          buttonAction.actionUri ?: @"",
          buttonAction.keyVals ?: @{},
          buttonAction.inboxCopyEnabled ? @"YES" : @"NO",
          (long)buttonAction.actionType);
    
        switch (buttonAction.actionType) {
            case CastledClickActionTypeDeepLink:
                {
                    NSString *value = buttonAction.actionUri;
                    NSURL *url = [NSURL URLWithString:value];
                    if (url) {
                       // [self handleDeepLinkWithURL:url];
                    }
                }
                break;
                
            case CastledClickActionTypeNavigateToScreen:
                    {
                        NSString *screenName = buttonAction.actionUri;
                        //[self handleNavigateToScreenWithScreenName:screenName];
                    }
                    break;

            case CastledClickActionTypeRichLanding:
                    // TODO:
                    break;

            case CastledClickActionTypeRequestForPush:
                    // TODO:
                    break;

            case CastledClickActionTypeDismiss:
                    // TODO:
                    break;

            case CastledClickActionTypeCustom:
                    // TODO:
                    break;

            default:
                    break;
    }
    
}

- (void)handleDeepLinkWithURL:(NSURL *)url {
    if (!url) {
        return;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *scheme = components.scheme;
    NSString *path = components.path;
    NSString *host = components.host;
    NSLog(@"Path %@", path);

    if ([scheme isEqualToString:@"com.castled"] && ([path isEqualToString:@"/deeplinkvc"] || [host isEqualToString:@"deeplinkvc"])) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DeeplinkViewController"];
        if (vc) {
            // implement presentation logic using vc
        }
    }
}

- (void)handleNavigateToScreenWithScreenName:(NSString *)screenName {
    if (!screenName) {
        return;
    }

    // implement presentation logic with screen name
}



@end
