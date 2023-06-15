//
//  AppDelegate.m
//  CastledDemoObejctiveC
//
//  Created by antony on 15/06/2023.
//

#import "AppDelegate.h"
#import <Castled_iOS_SDK/Castled_iOS_SDK-Swift.h>

@interface AppDelegate ()

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


    [Castled configureWithRegisterIn:application launchOptions:launchOptions instanceId:@"829c38e2e359d94372a2e0d35e1f74df" delegate:self clearNotifications:[NSNumber numberWithInt:1]];
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


@end
