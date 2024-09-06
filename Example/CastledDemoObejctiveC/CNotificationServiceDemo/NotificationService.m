//
//  NotificationService.m
//  CNotificationServiceDemo
//
//  Created by antony on 15/06/2023.
//

#import "NotificationService.h"

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler{
    self.appGroupId = @"group.com.castled.CastledPushDemo.Castled";
    [super didReceiveNotificationRequest:request withContentHandler:contentHandler];
    if([self isCastledPushNotificationRequest:request]){
        NSLog(@"Castled notfiication received %@",self.description);
    }
 }

- (void)serviceExtensionTimeWillExpire {

    [super serviceExtensionTimeWillExpire];

}

@end
