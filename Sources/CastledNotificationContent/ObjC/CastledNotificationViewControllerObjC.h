//
//  CastledNotificationViewControllerObjC.h
//  CastledNotificationContent
//
//  Created by antony on 20/06/2023.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface CastledNotificationViewControllerObjC : UIViewController <UNNotificationContentExtension>

- (void)didReceiveNotification:(UNNotification *)notification;

@end

NS_ASSUME_NONNULL_END
