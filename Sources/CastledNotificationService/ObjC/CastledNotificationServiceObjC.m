//
//  CastledNotificationServiceWrapper.m
//  CastledNotificationService
//
//  Created by antony on 19/06/2023.
//

#import <Foundation/Foundation.h>
#import "CastledNotificationServiceObjC.h"

#if __has_include("CastledNotificationService-Swift.h")
#import "CastledNotificationService-Swift.h"
#else
#import <CastledNotificationService/CastledNotificationService-Swift.h>
#endif
@interface CastledNotificationServiceObjC()
{
    
    
}
@property (nonatomic,retain) CastledNotificationServiceExtension  *serviceExtension;
@end

@implementation CastledNotificationServiceObjC
@synthesize appGroupId;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serviceExtension = [[CastledNotificationServiceExtension alloc] init];
        self.serviceExtension.appGroupId = appGroupId;

    }
    return self;
}
- (void)setAppGroupId:(NSString *)appGroupId{
    self.serviceExtension.appGroupId = appGroupId;

}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler{
    [_serviceExtension didReceiveNotificationRequest:request withContentHandler:contentHandler];
    self.contentHandler = _serviceExtension.contentHandler;
    self.bestAttemptContent = _serviceExtension.bestAttemptContent;
}

- (void)serviceExtensionTimeWillExpire {
    [_serviceExtension serviceExtensionTimeWillExpire];
}

@end
