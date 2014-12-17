//
//  KIFTestStep+StoreKitScenario.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "KIFTestStep+StoreKitScenario.h"
#import <StoreKit/StoreKit.h>

@implementation KIFTestStep (StoreKitScenario)

+ (id)stepToDismissStoreKit
{
    return [KIFTestStep stepWithDescription:@"Dismiss StoreKit." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        SKStoreProductViewController *topViewController = (SKStoreProductViewController *)[KIFHelper topMostViewController];
        [topViewController.delegate productViewControllerDidFinish:topViewController];
        [KIFHelper waitForViewControllerToStopAnimating:topViewController];

        return KIFTestStepResultSuccess;
    }];
}

@end
