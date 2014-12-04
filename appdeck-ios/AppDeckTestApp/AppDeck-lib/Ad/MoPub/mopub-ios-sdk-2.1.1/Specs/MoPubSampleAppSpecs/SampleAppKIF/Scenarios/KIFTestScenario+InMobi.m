//
//  KIFTestScenario+InMobi.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+InMobi.h"

@implementation KIFTestScenario (InMobi)

+ (KIFTestScenario *)scenarioForInMobiBanner
{
    [InMobi initialize:@"5d6694314fbe4ddb804eab8eb4ad6693"];
    
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an InMobi Banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"InMobi Banner" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"IMAdView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForInMobiInterstitial
{
    [InMobi initialize:@"5d6694314fbe4ddb804eab8eb4ad6693"];
    
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an InMobi interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"InMobi Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"UIWebView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(295, 25)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"UIWebView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
