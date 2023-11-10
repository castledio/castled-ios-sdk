//
//  NotificationService.m
//  CNotificationServiceDemo
//
//  Created by antony on 15/06/2023.
//

#import "NotificationService.h"

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler{

    [super didReceiveNotificationRequest:request withContentHandler:contentHandler];
}

- (void)serviceExtensionTimeWillExpire {

    [super serviceExtensionTimeWillExpire];

}

@end
