//
//  KIFTestScenario+Facebook.m
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "KIFTestScenario+Facebook.h"
#import "KIFTestStep.h"
#import "KIFTestScenario+HTML.h"
#import "MPNativeAdDetailViewController.h"
#import <StoreKit/StoreKit.h>
#import "KIFTestStep+StoreKitScenario.h"

@implementation KIFTestScenario (Facebook)

+ (KIFTestScenario *)scenarioForFacebookBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Facebook Banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Facebook Banner" inSection:@"Banner Ads"];

    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"FBAdView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Safari"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForFacebookInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Facebook interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Facebook Interstitial" inSection:@"Interstitial Ads"];

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

+ (KIFTestScenario *)scenarioForFacebookNativeAd
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a facebook native ad works."];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Facebook Native Ad" inSection:@"Native Ads"];
    NSLog(@"indexPath: %d, %d", indexPath.section, indexPath.row);

    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:kNativeAdDefaultActionViewKey]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[SKStoreProductViewController class]]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    // FB seems to dismiss the store product view controller automatically with the test ad.  So we won't explicitly do it here.
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPNativeAdDetailViewController class]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
