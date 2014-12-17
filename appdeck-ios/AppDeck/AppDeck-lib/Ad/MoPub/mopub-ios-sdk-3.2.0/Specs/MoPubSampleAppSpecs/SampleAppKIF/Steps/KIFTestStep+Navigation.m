//
//  KIFTestStep+Navigation.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+Navigation.h"
#import "MPManualAdViewController.h"

@implementation KIFTestStep (Navigation)

+ (id)stepToReturnToBannerAds
{
    return [KIFTestStep stepWithDescription:@"Return to Banner Ads" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        UIViewController *topViewController = [KIFHelper topMostViewController];
        UINavigationController *navigationController = [topViewController navigationController];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < MP_IOS_7_0
        [navigationController popToRootViewControllerAnimated:YES];
#else
        [navigationController popToRootViewControllerAnimated:NO];
#endif
        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToDismissModalViewController
{
    return [KIFTestStep stepWithDescription:@"Dismiss modal view controller" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        UIViewController *topViewController = [KIFHelper topMostViewController];
        
        [topViewController dismissViewControllerAnimated:YES completion:nil];
        
        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        
        return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToPushManualAdViewController
{
    return [KIFTestStep stepWithDescription:@"Push MPManualAdViewController" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        UIViewController *topViewController = [KIFHelper topMostViewController];
        
        MPManualAdViewController *manualVC = [[MPManualAdViewController alloc] init];
        
        [topViewController.navigationController pushViewController:manualVC animated:YES];
        
        return KIFTestStepResultSuccess;
    }];
}

@end
