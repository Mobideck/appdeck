//
//  KIFTestStep+ActivityIndicator.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+ActivityIndicator.h"

@implementation KIFTestStep (ActivityIndicator)

+ (id)stepToWaitUntilActivityIndicatorIsNotAnimating
{
    return [KIFTestStep stepWithDescription:@"Verify Spinner has stopped spinning." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        NSArray *indicators = [KIFHelper findViewsOfClass:[UIActivityIndicatorView class]];
        if (indicators.count == 0) {
            KIFTestWaitCondition(NO, error, @"No spinners found");
        }
        for (UIActivityIndicatorView *indicator in indicators) {
            if (indicator.isAnimating) {
                KIFTestWaitCondition(NO, error, @"Spinner is still animating");
            }
        }
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToWaitUntilNetworkActivityIndicatorIsNotAnimating
{
    return [KIFTestStep stepWithDescription:@"Verify Status Bar Network Activity Indicator has stopped spinning." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        BOOL isSpinning = [UIApplication sharedApplication].networkActivityIndicatorVisible;
        if (isSpinning) {
            KIFTestWaitCondition(NO, error, @"Spinner is still animating");
        }
        return KIFTestStepResultSuccess;
    }];
    
}

@end
