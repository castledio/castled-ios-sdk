//
//  CastledApplicationLoader.m
//  Castled
//
//  Created by antony on 28/03/2024.
//

#import "CastledApplicationLoader.h"
#if __has_include("Castled-Swift.h")
#import "Castled-Swift.h"
#else
#import <Castled/Castled-Swift.h>
#endif
 @implementation CastledApplicationLoader
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       [[CastledAppDelegate shared] setApplicationDelegatesWithSourceClass:[self class]];
     });
}

@end
