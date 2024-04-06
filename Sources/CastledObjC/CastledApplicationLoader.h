//
//  CastledApplicationLoader.h
//  Castled
//
//  Created by antony on 05/04/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
#ifdef SWIFT_PACKAGE
@import Castled;
#endif

@interface CastledApplicationLoader : NSObject
- (instancetype)init NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
