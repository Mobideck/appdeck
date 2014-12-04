//
//  KIFTestScenario+StoreKitScenario.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+StoreKitScenario.h"
#import "KIFTestStep.h"
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

@implementation KIFTestScenario (StoreKitScenario)

+ (id)scenarioForBannerAdWithStoreKitLink
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad with a StoreKit link works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Valid StoreKit Link" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"LinkMaker"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[SKStoreProductViewController class]]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForBannerAdWithInvalidStoreKitLink
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad with a StoreKit link to an invalid item does not explode."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Invalid StoreKit Link" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Invalid iTunes Item"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[SKStoreProductViewController class]]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(160, 290)]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForInterstitialAdWithStoreKitLink
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an interstitial ad with a StoreKit link works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Valid StoreKit Link" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"LinkMaker"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[SKStoreProductViewController class]]];
    [scenario addStep:[KIFTestStep stepToDismissStoreKit]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
