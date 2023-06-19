//
//  AppDelegate.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

#import <Castled_iOS_SDK/Castled_iOS_SDK-Swift.h>

@interface AppDelegate ()<UIApplicationDelegate,UNUserNotificationCenterDelegate,CastledNotificationDelegate>
{

}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CastledConfigs *config = [CastledConfigs sharedInstance];
    config.permittedBGIdentifier = @"";
    config.enablePush = TRUE;
    config.enableInApp = TRUE;
    config.disableLog = FALSE;
    config.location = CastledLocationUS;


    [Castled configureWithRegisterIn:application launchOptions:launchOptions instanceId:@"829c38e2e359d94372a2e0d35e1f74df" delegate:(id)self];


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


    
    return YES;
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

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"failed to register for remote notifications: %@ %@", self.description, error.localizedDescription);
}
/*************************************************************IMPPORTANT*************************************************************/
//If you disabled the swizzling in plist you should call the required functions in the delegate methods

-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@ %@", self.description, deviceToken.debugDescription);
    [[Castled sharedInstance] setDeviceTokenWithDeviceToken:deviceToken];
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{

    NSLog(@"didReceiveNotificationResponse: %@ %@", self.description, response.notification.request.content.userInfo);
    [[Castled sharedInstance] handleNotificationActionWithResponse:response];

    completionHandler();
}

-(void) userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"willPresentNotification: %@ %@", self.description, notification.request.content.userInfo);
    [[Castled sharedInstance] handleNotificationInForegroundWithNotification:notification];

    completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    NSLog(@"didReceiveRemoteNotification with completionHandler: %@ %@", self.description, userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - CastledNotification Delegate Methods


- (void)castled_userNotificationCenter:(UNUserNotificationCenter *)center
               willPresentNotification:(UNNotification *)notification
                 withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    NSLog(@"will present notification: %@ %@ %@", self.description,NSStringFromSelector(_cmd),notification.request.content.userInfo);

    completionHandler(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);


}

- (void)castled_userNotificationCenter:(UNUserNotificationCenter *)center
        didReceiveNotificationResponse:(UNNotificationResponse *)response
                 withCompletionHandler:(void (^)(void))completionHandler{
    NSLog(@"didReceive: %@ %@", self.description,NSStringFromSelector(_cmd));

    completionHandler();

}

- (void)castled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@ %@ %@", self.description,NSStringFromSelector(_cmd),error.localizedDescription);

}

- (void)castled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@ %@ %@", self.description,NSStringFromSelector(_cmd),deviceToken.debugDescription);

}

- (void)navigateToScreenWithScheme:(NSString *)scheme viewControllerName:(NSString *)viewControllerName{
    NSLog(@"navigateToScreenWithScheme: %@ %@ %@", self.description,NSStringFromSelector(_cmd),viewControllerName);


}

- (void)handleDeepLinkWithURL:(NSURL *)url useWebview:(BOOL)useWebview additionalData:(NSDictionary<NSString *, id> *)additionalData{
    NSLog(@"handleDeepLinkWithURL: %@ %@ %@", self.description,NSStringFromSelector(_cmd),additionalData);


}

- (void)handleNavigateToScreenWithScreenName:(NSString *)screenName useWebview:(BOOL)useWebview additionalData:(NSDictionary<NSString *, id> *)additionalData{
    NSLog(@"handleNavigateToScreenWithScreenName: %@ %@ %@", self.description,NSStringFromSelector(_cmd),additionalData);

}

- (void)handleRichLandingWithScreenName:(NSString *)screenName useWebview:(BOOL)useWebview additionalData:(NSDictionary<NSString *, id> *)additionalData{
    NSLog(@"handleRichLandingWithScreenName: %@ %@ %@", self.description,NSStringFromSelector(_cmd),additionalData);


}


@end
