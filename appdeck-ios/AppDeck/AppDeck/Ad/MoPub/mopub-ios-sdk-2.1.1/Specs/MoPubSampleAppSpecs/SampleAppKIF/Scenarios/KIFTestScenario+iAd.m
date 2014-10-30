//
//  KIFTestScenario+iAd.m
//  MoPubSampleApp
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+iAd.h"
#import "UIView-KIFAdditions.h"
#import "MPInterstitialAdDetailViewController.h"

@implementation KIFTestStep (iAdInterstitial)

+ (KIFTestStep *)stepToVerifyCallbacksAreInvoked {
    return [KIFTestStep stepWithDescription:@"Verify callbacks are invoked" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        MPInterstitialAdDetailViewController *detailVC = (MPInterstitialAdDetailViewController *)[KIFHelper topMostViewController];
        
        BOOL callbacksInvoked = detailVC.willAppearLabel.alpha == 1.0 && detailVC.didAppearLabel.alpha == 1.0 && detailVC.willDisappearLabel.alpha == 1.0 && detailVC.didDisappearLabel.alpha == 1.0;
        
        KIFTestCondition(callbacksInvoked, error, @"Not all callbacks were invoked");
        
        return KIFTestStepResultSuccess;
    }];
}

@end

@implementation KIFTestScenario (iAd)

+ (KIFTestScenario *)scenarioForIADInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an iAD interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"iAd Interstitial (iPad-only)" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"_ADRemoteViewController")]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    
    // XXX jren: no way to fake a click of the X, requires manual click. This test exists because Apple changed which callbacks were invoked on dismiss in iOS 7
    
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPInterstitialAdDetailViewController class]]];
   
    [scenario addStep:[KIFTestStep stepToVerifyCallbacksAreInvoked]];
    
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

+ (KIFTestScenario *)scenarioForIAdBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an iAD banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"iAd Banner" inSection:@"Banner Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"ADBannerView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:NSClassFromString(@"_ADRemoteViewController")]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    
    [scenario addStep:[KIFTestStep stepToDismissModalViewController]];
    
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    
    return scenario;
}

@end
