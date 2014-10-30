//
//  KIFTestScenario+Vungle.m
//  MoPubSampleApp
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Vungle.h"
#import "UIViewController+MPAdditions.h"

@implementation KIFTestScenario (Vungle)

+ (KIFTestScenario *)scenarioForVungleInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Vungle interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Vungle Interstitial" inSection:@"Interstitial Ads"];
    
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    
    KIFTestStep *waitForLoadStep = [KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating];
    waitForLoadStep.timeout = 60; // set a 60 second timeout since Vungle might take a while to load, especially on a fresh test run.
    [scenario addStep:waitForLoadStep];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"VGBackgroundView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToPerformBlock:^{
        // We must watch X seconds of video before the close button disappears, so instead, we grab the view and tell it to go away
        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviews];
        for(UIView *view in views)
        {
            if([view isMemberOfClass:NSClassFromString(@"VGBackgroundView")])
            {
                [view removeFromSuperview];
                break;
            }
        }
    }]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"VGBackgroundView"]];
    
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

@end
