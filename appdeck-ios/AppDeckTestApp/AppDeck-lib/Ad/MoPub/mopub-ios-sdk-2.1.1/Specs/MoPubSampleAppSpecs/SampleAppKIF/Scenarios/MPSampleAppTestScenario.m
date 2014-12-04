//
//  MPSampleAppTestScenario.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppTestScenario.h"
#import "KIFTestStep.h"
#import "KIFTestStep+MoPubSampleApp.h"
#import "MPAdInfo.h"
#import "MPAdSection+KIF.h"
#import "InMobi.h"

@implementation MPSampleAppTestScenario

- (void)addStep:(KIFTestStep *)step
{
    [super addStep:step];
    if (getenv("KIF_SLOW_TESTS")) {
        [super addStep:[KIFTestStep stepToWaitForTimeInterval:0.5 description:@"Waiting for half a second."]];
    }
}

+ (id)scenarioToWarmUpAdUnits
{
    [InMobi initialize:@"5d6694314fbe4ddb804eab8eb4ad6693"];
    
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Warm up all ad units"];
    
    NSArray *bannerAds = [MPAdInfo bannerAds];
    for (MPAdInfo *bannerInfo in bannerAds) {
        NSIndexPath *indexPath = [MPAdSection indexPathForAd:bannerInfo.title inSection:@"Banner Ads"];
        [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                                 atIndexPath:indexPath]];
        [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
        [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    }
    
    return scenario;
}

@end
