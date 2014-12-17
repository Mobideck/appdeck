//
//  KIFTestScenario+Millennial.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Millennial.h"
#import "UIView-KIFAdditions.h"
#import "MPBannerAdDetailViewController.h"

@implementation KIFTestStep (MillennialScenario)

+ (KIFTestStep *)stepToDismissMillennialInterstitial {
    return [KIFTestStep stepWithDescription:@"Dismiss millennial interstitial" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        UIViewController *topMostViewController = [KIFHelper topMostViewController];
        [topMostViewController.view tapAtPoint:CGPointMake(5, 5)]; //tap the page curl to hide

        return KIFTestStepResultSuccess;
    }];
}

@end


@implementation KIFTestScenario (Millennial)

+ (KIFTestScenario *)scenarioForMillennialInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Millennial interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Millennial Phone Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"MMWebView"]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(300, 40)]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToDismissMillennialInterstitial]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"expired"]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForMillennialBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Millennial banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Millennial Banner" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];

    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"MMBannerAdView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    //give Millennial a secod
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1 description:@"Waiting for Millennial banner to become tappable"]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitForTappableViewWithAccessibilityLabel:@"Stop"]];

    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Stop"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPBannerAdDetailViewController class]]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
