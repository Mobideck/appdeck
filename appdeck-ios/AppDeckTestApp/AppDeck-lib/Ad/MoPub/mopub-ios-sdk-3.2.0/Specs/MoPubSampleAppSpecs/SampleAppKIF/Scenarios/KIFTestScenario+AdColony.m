//
//  KIFTestScenario+AdColony.m
//  MoPubSampleApp
//
//  Created by Yuan Ren on 10/23/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+AdColony.h"
#import "UIView-KIFAdditions.h"
#import <AdColony/AdColony.h>

@implementation KIFTestScenario (AdColony)

+ (void)addStepToShowAndDismissAdColonyToScenario:(KIFTestScenario *)scenario adUnitId:(NSString *)adUnitId
{
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"ADCAVPlayerPlaybackView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:adUnitId]];
    [scenario addStep:[KIFTestStep stepToWaitForTimeInterval:1 description:@"Allow video to display"]];
    [scenario addStep:[KIFTestStep stepToPerformBlock:^{
        [AdColony cancelAd];
    }]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"ADCAVPlayerPlaybackView"]];
}

+ (KIFTestScenario *)scenarioForAdColonyInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a AdColony interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"AdColony Interstitial" inSection:@"Interstitial Ads"];
    
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    
    KIFTestStep *waitForLoadStep = [KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating];
    waitForLoadStep.timeout = 60; // set a 60 second timeout since AdColony might take a while to load, especially on a fresh test run.
    [scenario addStep:waitForLoadStep];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [self addStepToShowAndDismissAdColonyToScenario:scenario adUnitId:[MPAdSection adInfoAtIndexPath:indexPath].ID];
    
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

+ (KIFTestScenario *)scenarioForMultipleAdColonyInterstitials
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that simultaneously loading multiple AdColony interstitials works."];
    
    [scenario addStep:[KIFTestStep stepToPushManualAdViewController]];
    
    NSString *aLocationAdUnit = @"e4b75cdda0544e59b668afe6b764c0a1";
    NSString *somewhereLocationAdUnit = @"c7ddfa7d91804c20a833d2a84016973d";
    
    [scenario addStep:[KIFTestStep stepToEnterText:aLocationAdUnit intoViewWithAccessibilityLabel:@"Interstitial ID 1"]];
    [scenario addStep:[KIFTestStep stepToEnterText:somewhereLocationAdUnit intoViewWithAccessibilityLabel:@"Interstitial ID 2"]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"return"]]; //hide the keyboard
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 1"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 2"]];
    
    KIFTestStep *waitForLoadStep = [KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating];
    waitForLoadStep.timeout = 60; // set a 60 second timeout since AdColony might take a while to load, especially on a fresh test run.
    [scenario addStep:waitForLoadStep];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 1"]];
    [self addStepToShowAndDismissAdColonyToScenario:scenario adUnitId:aLocationAdUnit];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 2"]];
    [self addStepToShowAndDismissAdColonyToScenario:scenario adUnitId:somewhereLocationAdUnit];
    
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

@end
