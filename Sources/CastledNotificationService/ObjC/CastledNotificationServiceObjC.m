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
static CastledNotificationServiceObjC *sharedInstance = nil;
@interface CastledNotificationServiceObjC()
{
    
    
}
@property (nonatomic,retain) CastledNotificationServiceExtension  *serviceExtension;
@end

@implementation CastledNotificationServiceObjC
@synthesize appGroupId;
 
+ (CastledNotificationServiceObjC *)extensionInstance {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initializeExtensionObjects];

    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeExtensionObjects];
        
    }
    return self;
}

-(void)initializeExtensionObjects{
    self.serviceExtension = [CastledNotificationServiceExtension extensionInstance];
    self.serviceExtension.appGroupId = appGroupId;
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

- (BOOL)isCastledPushNotificationRequest:(UNNotificationRequest *)request{
    return  [self.serviceExtension isCastledPushNotificationRequest:request];
}
@end
