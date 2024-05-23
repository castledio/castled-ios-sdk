//
//  CastledInboxLoader.m
//  Castled
//
//  Created by antony on 24/05/2024.
//

#import "CastledInboxLoader.h"

#if __has_include("CastledInbox-Swift.h")
#import "CastledInbox-Swift.h"
#elif __has_include(<CastledInbox/CastledInbox-Swift.h>)
#import <CastledInbox/CastledInbox-Swift.h>
#elif SWIFT_PACKAGE
@import CastledInbox;
#endif

@implementation CastledInboxLoader

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[CastledInboxSetupLoader shared] startWithSourceClass:[self class]];
      });
}

@end
