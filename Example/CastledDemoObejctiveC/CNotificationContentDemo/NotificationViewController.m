//
//  NotificationViewController.m
//  CNotificationContentDemo
//
//  Created by antony on 15/06/2023.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appGroupId = @"group.com.castled.CastledPushDemo.Castled";
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    if([self isCastledPushNotification:notification]){
        [super didReceiveNotification:notification];
    }
}

@end
