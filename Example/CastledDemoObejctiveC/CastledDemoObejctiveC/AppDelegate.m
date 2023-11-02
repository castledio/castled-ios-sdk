//
//  AppDelegate.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <Castled/Castled-Swift.h>

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate,CastledNotificationDelegate>
{

}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    CastledConfigs *config = [CastledConfigs initializeWithAppId:@"e8a4f68bfb6a58b40a77a0e6150eca0b"];
//    config.permittedBGIdentifier = @"";
    config.enablePush = TRUE;
    config.enableAppInbox = TRUE;
//    config.enableTracking = TRUE;
    config.enableInApp = TRUE;
    config.appGroupId = @"group.com.castled.CastledPushDemo.Castled";
    config.logLevel = CastledLogLevelDebug;
    config.location = CastledLocationTEST;
    NSSet<UNNotificationCategory *> *notificationCategories = [self getNotificationCategories];
    [Castled initializeWithConfig:config delegate:(id)self andNotificationCategories:nil];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navBarAppearance = [[UINavigationBarAppearance alloc] init];
        [navBarAppearance configureWithOpaqueBackground];
        navBarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        navBarAppearance.backgroundColor = [UIColor linkColor];
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];

        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setStandardAppearance:navBarAppearance];
        [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[UINavigationController class]]] setScrollEdgeAppearance:navBarAppearance];
    }
    [self registerForPush];

    
    return YES;
}

- (NSSet<UNNotificationCategory *> *)getNotificationCategories {
    // Create the custom actions
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"ACCEPT" title:@"Accept" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"DECLINE" title:@"Decline" options:0];

    // Create the category with the custom actions
    UNNotificationCategory *customCategory1 = [UNNotificationCategory categoryWithIdentifier:@"ACCEPT_DECLINE" actions:@[action1, action2] intentIdentifiers:@[] options:0];

    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"YES" title:@"Yes" options:UNNotificationActionOptionForeground];
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"NO" title:@"No" options:0];

    // Create the category with the custom actions
    UNNotificationCategory *customCategory2 = [UNNotificationCategory categoryWithIdentifier:@"YES_NO" actions:@[action3, action4] intentIdentifiers:@[] options:0];

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

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@ %@", self.description, deviceToken.debugDescription);
    [[Castled sharedInstance] setPushToken:deviceToken.debugDescription];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification with completionHandler: %@ %@", self.description, userInfo);
    [[Castled sharedInstance] didReceiveRemoteNotificationInApplication:application withInfo:userInfo fetchCompletionHandler:^(UIBackgroundFetchResult) {
        completionHandler(UIBackgroundFetchResultNewData);

    }];
}


#pragma mark - CastledNotification Delegate Methods


- (void)castled_userNotificationCenter:(UNUserNotificationCenter *)center willPresent:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    ///notification.request.content.userInfo
    NSLog(@"will present notification: %@ %@", self.description,NSStringFromSelector(_cmd));

    completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);


}
- (void)castled_userNotificationCenter:(UNUserNotificationCenter *)center didReceive:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog(@"didReceive: %@ %@", self.description,NSStringFromSelector(_cmd));

    completionHandler();

}
- (void)castled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification: %@ %@", self.description,NSStringFromSelector(_cmd));
    completionHandler(UIBackgroundFetchResultNewData);

}

- (void)castled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@ %@ %@", self.description,NSStringFromSelector(_cmd),error.localizedDescription);

}


- (void)castled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@ %@ %@", self.description,NSStringFromSelector(_cmd),deviceToken.debugDescription);

}


- (void)notificationClickedWithNotificationType:(CastledNotificationType)type
                                         action:(CastledClickActionType)action
                                        kvPairs:(NSDictionary<id, id> * _Nullable)kvPairs
                                       userInfo:(NSDictionary<id, id> *)userInfo {
    NSLog(@"type %ld action %ld", (long)type, (long)action);

    switch (action) {
        case CastledClickActionTypeDeepLink:
            if (kvPairs) {
                NSString *value = kvPairs[@"clickActionUrl"];
                NSURL *url = [NSURL URLWithString:value];
                if (url) {
                    [self handleDeepLinkWithURL:url];
                }
            }
            break;

        case CastledClickActionTypeNavigateToScreen:
            if (kvPairs) {
                NSString *screenName = kvPairs[@"clickActionUrl"];
                [self handleNavigateToScreenWithScreenName:screenName];
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
