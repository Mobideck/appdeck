//
//  KIFTestScenario+Chartboost.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Chartboost.h"

@implementation KIFTestScenario (Chartboost)

+ (KIFTestScenario *)scenarioForChartboostInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Chartboost interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Chartboost Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(160, 240)]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"CBLoadingView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForMultipleChartboostInterstitials
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that simultaneously loading multiple Chartboost interstitials works."];

    [scenario addStep:[KIFTestStep stepToPushManualAdViewController]];

    NSString *noLocationAdUnit = @"a425ff78959911e295fa123138070049";
    NSString *somewhereLocationAdUnit = @"201597ec97e811e295fa123138070049";

    [scenario addStep:[KIFTestStep stepToEnterText:noLocationAdUnit intoViewWithAccessibilityLabel:@"Interstitial ID 1"]];
    [scenario addStep:[KIFTestStep stepToEnterText:somewhereLocationAdUnit intoViewWithAccessibilityLabel:@"Interstitial ID 2"]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"return"]]; //hide the keyboard

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 1"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 2"]];

    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 1"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:noLocationAdUnit]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(260, 80)]]; // Closes the ad
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"CBNativeInterstitialView"]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 2"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:somewhereLocationAdUnit]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(160, 240)]]; // Clicks the ad
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:somewhereLocationAdUnit]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"CBLoadingView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
