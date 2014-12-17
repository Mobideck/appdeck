//
//  KIFTestStep+Logging.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+Logging.h"

@implementation KIFTestStep (Logging)

+ (id)stepToLogImpressionForAdUnit:(NSString *)adUnitId
{
    NSString *description = [NSString stringWithFormat:@"Logging impression for %@", adUnitId];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSLog(@"~~~ EXPECT IMPRESSION FOR AD UNIT ID: %@", adUnitId);
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToLogClickForAdUnit:(NSString *)adUnitId
{
    NSString *description = [NSString stringWithFormat:@"Logging click for %@", adUnitId];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSLog(@"~~~ EXPECT CLICK FOR AD UNIT ID: %@", adUnitId);
        return KIFTestStepResultSuccess;
    }];
}

@end
