//
//  CastledNotificationServiceWrapper.h
//  CastledNotificationService
//
//  Created by antony on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface CastledNotificationServiceObjC : UNNotificationServiceExtension

@property (nonatomic,retain) NSString *appGroupId;
@property (nonatomic, copy) void (^contentHandler)(UNNotificationContent *);
@property (nonatomic,retain) UNMutableNotificationContent *bestAttemptContent;

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *contentToDeliver))contentHandler;
- (void)serviceExtensionTimeWillExpire;

@end

NS_ASSUME_NONNULL_END
