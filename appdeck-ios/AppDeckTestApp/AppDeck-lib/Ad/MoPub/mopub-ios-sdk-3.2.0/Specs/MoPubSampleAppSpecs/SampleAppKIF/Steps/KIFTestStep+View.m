//
//  KIFTestStep+View.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+View.h"
#import "UIView-KIFAdditions.h"
#import "MPGlobal.h"

#import <objc/runtime.h>

@implementation KIFTestStep (View)

+ (KIFTestStep *)stepToWaitForPresenceOfViewWithClassName:(NSString *)className
{
    NSString *description = [NSString stringWithFormat:@"Looking for view with class name %@", className];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviewsWithClassNamePrefix:className];

        KIFTestWaitCondition(views.count > 0, error, @"Waiting for view with classname %@ to appear", className);

        return KIFTestStepResultSuccess;
    }];
}

+ (KIFTestStep *)stepToWaitForAbsenceOfViewWithClassName:(NSString *)className
{
    NSString *description = [NSString stringWithFormat:@"Waiting for view with class name %@ to disappear", className];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviewsWithClassNamePrefix:className];

        KIFTestWaitCondition(views.count == 0, error, @"Waiting for view with classname %@ to disappear", className);

        return KIFTestStepResultSuccess;
    }];
}

+ (KIFTestStep *)stepToEnsureAbsenceOfViewWithClassName:(NSString *)className
{
    NSString *description = [NSString stringWithFormat:@"Ensuring view with class name %@ doesn't exist", className];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviewsWithClassNamePrefix:className];
        
        if(views.count != 0) {
            KIFTestCondition(NO, error, @"View with classname %@ currently shown", className);
        }

        return KIFTestStepResultSuccess;
    }];
}

+ (KIFTestStep *)stepToEnsureAbsenceOfUIAlertView
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < MP_IOS_7_0
    return [self stepToEnsureAbsenceOfViewWithClassName:@"UIAlertView"];
#else
    NSString *description = [NSString stringWithFormat:@"Ensuring UIAlertView doesn't exist"];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        Class UIAlertManager = objc_getClass("_UIAlertManager");
        UIAlertView *topMostAlert = [UIAlertManager performSelector:@selector(topMostAlert)];
        
        if(topMostAlert != nil) {
            KIFTestCondition(NO, error, @"UIAlertView currently shown");
            [topMostAlert dismissWithClickedButtonIndex:0 animated:MP_ANIMATED];
        }
        return KIFTestStepResultSuccess;
    }];
#endif
}

@end
