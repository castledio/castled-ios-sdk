//
//  CastledTestInitializer.m
//  CastledTests
//
//  Created by antony on 15/07/2024.
//

#import "CastledTestInitializer.h"
#import "CastledTests-Swift.h"

@implementation CastledTestInitializer
+ (void)load {
    [CastledTestCoreDataStack initializeTestStack];
}
@end
