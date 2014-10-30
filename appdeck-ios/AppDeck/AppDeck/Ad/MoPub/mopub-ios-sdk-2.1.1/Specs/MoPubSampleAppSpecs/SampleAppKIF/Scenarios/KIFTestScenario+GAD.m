//
//  KIFTestScenario+GAD.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+GAD.h"
#import "UIView-KIFAdditions.h"
#import "MPBannerAdDetailViewController.h"

@implementation KIFTestStep (GADScenario)

+ (KIFTestStep *)stepToDismissGADInterstitial {
    return [KIFTestStep stepWithDescription:@"Dismiss GAD interstitial" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topMostViewController = [KIFHelper topMostViewController];

        UIButton *closeButton = [[KIFHelper findViewsOfClass:[UIButton class]] lastObject];
        [closeButton tap];

        [KIFHelper waitForViewControllerToStopAnimating:topMostViewController];
        return KIFTestStepResultSuccess;
    }];
}

@end


@implementation KIFTestScenario (GAD)

+ (KIFTestScenario *)scenarioForGADInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a GAD interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Google AdMob Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"GADWebAppViewController")]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToDismissGADInterstitial]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForGADBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a GAD banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Google AdMob Banner" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"GADBannerView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"GADBrowserController")]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPBannerAdDetailViewController class]]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
