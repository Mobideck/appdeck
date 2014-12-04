//
//  KIFTestStep+ViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+ViewController.h"

@implementation KIFTestStep (ViewController)

+ (id)stepToVerifyPresentationOfViewControllerClass:(Class)klass
{
    NSString *description = [NSString stringWithFormat:@"Verify %@ is on-screen", NSStringFromClass(klass)];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topViewController = [KIFHelper topMostViewController];
        KIFTestWaitCondition([topViewController isKindOfClass:klass], error, @"Failed to find %@", NSStringFromClass(klass));

        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToVerifyAbsenceOfViewControllerClass:(Class)klass
{
    NSString *description = [NSString stringWithFormat:@"Verify %@ is not on-screen", NSStringFromClass(klass)];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        
        UIViewController *topViewController = [KIFHelper topMostViewController];
        
        if ([topViewController isKindOfClass:klass]) {
            KIFTestCondition(NO, error, @"%@ is on screen", NSStringFromClass(klass));
        }
        
        return KIFTestStepResultSuccess;
    }];
}

@end
