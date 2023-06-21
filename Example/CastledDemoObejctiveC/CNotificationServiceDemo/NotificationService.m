//
//  NotificationService.m
//  CNotificationServiceDemo
//
//  Created by antony on 15/06/2023.
//

#import "NotificationService.h"

@interface NotificationService ()
{
   // CastledNotificationServiceObjC *castledService;
}

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService


- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler{

    [super didReceiveNotificationRequest:request withContentHandler:contentHandler];

}


- (void)serviceExtensionTimeWillExpire {

    [super serviceExtensionTimeWillExpire];

    //self.contentHandler(self.bestAttemptContent);
}

@end
