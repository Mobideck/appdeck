//
//  KIFTestScenario+InMobi.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+InMobi.h"
#import "MPNativeAdDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "KIFTestStep+StoreKitScenario.h"


@implementation KIFTestScenario (InMobi)

+ (KIFTestScenario *)scenarioForInMobiBanner
{
    [InMobi initialize:@"c8e9d75780cd439cad91d5def5200d25"];

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
    [InMobi initialize:@"c8e9d75780cd439cad91d5def5200d25"];

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

+ (KIFTestScenario *)scenarioForInMobiNativeAd
{
    [InMobi initialize:@"b15abe4c93a84f59a65faceca30c9591"];

    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an inmobi native ad's default action URL is usable."];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"InMobi Native Ad" inSection:@"Native Ads"];
    NSLog(@"indexPath: %d, %d", indexPath.section, indexPath.row);
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:kNativeAdDefaultActionViewKey]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[SKStoreProductViewController class]]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPNativeAdDetailViewController class]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
