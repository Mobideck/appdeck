//
//  KIFTestScenario+Native.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "KIFTestScenario+Native.h"
#import "KIFTestStep.h"
#import "UIApplication+KIF.h"
#import "MPNativeAdDetailViewController.h"
#import "MPNativeAdTableViewController.h"


@implementation KIFTestScenario (Native)

+ (KIFTestScenario *)scenarioForNativeAd
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a native ad's default action URL is usable."];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Native Ad" inSection:@"Native Ads"];
    NSLog(@"indexPath: %d, %d", indexPath.section, indexPath.row);
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:kNativeAdDefaultActionViewKey]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"MPAdBrowserController")]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPNativeAdDetailViewController class]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForNativeAdInTableView
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a native ad's default action URL is usable when presented in a Table View "];

    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Native Ad (TableView Example)" inSection:@"Native Ads"];
    NSLog(@"indexPath: %d, %d", indexPath.section, indexPath.row);
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitUntilNetworkActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];

    NSIndexPath *pathToAd = [NSIndexPath indexPathForRow:1 inSection:0];
    NSLog(@"pathToAd: %d, %d", pathToAd.section, pathToAd.row);

    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:kNativeAdTableViewAccessibilityLabel atIndexPath:pathToAd]];



    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"MPAdBrowserController")]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPNativeAdTableViewController class]]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;

}

@end
