//
//  CastledGeoFenceLoader.m
//  CastledGeoFencer
//
//  Created by antony on 08/08/2024.
//

#import "CastledGeoFenceLoader.h"

#if __has_include("CastledGeoFencer-Swift.h")
#import "CastledGeoFencer-Swift.h"
#elif __has_include(<CastledGeoFencer/CastledGeoFencer-Swift.h>)
#import <CastledGeoFencer/CastledGeoFencer-Swift.h>
#elif SWIFT_PACKAGE
@import CastledGeoFencer;
#endif

@implementation CastledGeoFenceLoader

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[CastledGeoFencerSetupLoader shared] startWithSourceClass:[self class]];
      });
}

@end
