//
//  KIFTestScenario+HTML.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+HTML.h"
#import "KIFTestStep.h"
#import "UIApplication+KIF.h"
#import "MPBannerAdDetailViewController.h"

@implementation KIFTestStep (HTML)

+ (id)stepToVerifyThatApplicationOpenedURL:(NSURL *)URL
{
    NSString *description = [NSString stringWithFormat:@"Verify that the application opened the URL: %@", [URL absoluteString]];
    return [KIFTestStep stepWithDescription:description
                             executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
                                 KIFTestWaitCondition([[[UIApplication sharedApplication] lastOpenedURL] isEqual:URL], error, @"Failed to open desired URL.");
                                 return KIFTestStepResultSuccess;
    }];
}

+ (id)stepToResetApplicationLastOpenedURL
{
    return [KIFTestStep stepWithDescription:@"Reset the application's last opened URL." executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        [[UIApplication sharedApplication] resetLastOpenedURL];
        return KIFTestStepResultSuccess;
    }];
}

@end

@implementation KIFTestScenario (HTML)

+ (id)scenarioForClickToSafariBannerAd
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad can click out to Safari"];
    scenario.stepsToTearDown = @[[KIFTestStep stepToResetApplicationLastOpenedURL]];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Click-to-Safari Link" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Safari"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToVerifyThatApplicationOpenedURL:[NSURL URLWithString:@"https://www.mopub.com"]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForClickToSafariMRAIDAd
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID ad can click out to Safari"];
    scenario.stepsToTearDown = @[[KIFTestStep stepToResetApplicationLastOpenedURL]];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Click-to-Safari Link MRAID" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]]; // tap the banner to pass MRAdView's user interaction check
    [scenario addStep:[KIFTestStep stepToTapLink:@"MRAID open" webViewClassName:@"UIWebView"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToVerifyThatApplicationOpenedURL:[NSURL URLWithString:@"https://www.mopub.com"]]];

    // Note: We don't expect another click-tracking ping, because they're limited to one per ad.
    [scenario addStep:[KIFTestStep stepToTapLink:@"Normal Link" webViewClassName:@"UIWebView"]];
    [scenario addStep:[KIFTestStep stepToVerifyThatApplicationOpenedURL:[NSURL URLWithString:@"http://www.apple.com"]]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForHTMLMRectBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRECT banner ad can click out to Safari"];
    scenario.stepsToTearDown = @[[KIFTestStep stepToResetApplicationLastOpenedURL]];
    
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"HTML MRECT Banner Ad" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"mrect_banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"mrect_banner"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"MPAdBrowserController")]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPBannerAdDetailViewController class]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

+ (id)scenarioForCreativeThatTriesToOpenJavaScriptDialogs
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a banner ad cannot open any JavaScript dialogs"];
    
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"JS Popups" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    // If this creative did pop up a dialog, this step will not complete and the test will fail due to the step timeout.
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

@end
