//
//  KIFTestScenario+MRAID.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+MRAID.h"
#import "KIFTestStep.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPInterstitialAdDetailViewController.h"

@implementation KIFTestScenario (MRAID)

+ (id)scenarioForMRAIDInterstitialWithVideo
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID interstitial can play video"];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"MRAID Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                            atIndexPath:indexPath]];

    // Load and display the MRAID interstitial.
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    
    // When it appears on-screen, tap the "Video" link.
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Video" webViewClassName:@"UIWebView"]];
    
    // Check that a video player is displayed, and then dismiss it.
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPMoviePlayerViewController class]]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    
    // Then, dismiss the interstitial itself.
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    
    // Return to the main table view.
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (id)scenarioForMRAIDInterstitialWithAutoPlayVideo
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID interstitial can auto playVideo"];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"MRAID Interstitial auto playVideo" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    
    // Load and display the MRAID interstitial.
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    
    // wait for the javascript timer to hit
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:3 description:@"Give mraid viewable time to fire"]];
    
    // Check that a video player is displayed, and then dismiss it.
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPMoviePlayerViewController class]]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    
    // Then, dismiss the interstitial itself.
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    
    // Return to the main table view.
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

+ (id)scenarioForMRAIDAdThatTriesToStoreAPictureWithoutUserInteraction
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID banner ad cannot store a picture without user interaction"];
    
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Malicious MRAID Banner Ad storePicture" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:2 description:@"Give mraid viewable time to fire"]];
    // make sure store picture alert view doesn't show up
    [scenario addStep:[KIFTestStep stepToEnsureAbsenceOfUIAlertView]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

+ (id)scenarioForMRAIDAdThatTriesToPlayAVideoWithoutUserInteraction
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID banner ad cannot play a video without user interaction"];
    
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Malicious MRAID Banner Ad playVideo" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View" atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:2 description:@"Give mraid viewable time to fire"]];
    // make sure the video player doesn't show up
    [scenario addStep:[KIFTestStep stepToVerifyAbsenceOfViewControllerClass:NSClassFromString(@"MPMoviePlayerViewController")]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

@end
