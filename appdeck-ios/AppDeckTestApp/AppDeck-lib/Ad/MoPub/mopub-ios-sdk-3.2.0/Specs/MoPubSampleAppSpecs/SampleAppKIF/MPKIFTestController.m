//
//  MPKIFTestController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPKIFTestController.h"
#import "KIFTestScenario+StoreKitScenario.h"
#import "KIFTestScenario+Millennial.h"
#import "KIFTestScenario+GAD.h"
#import "KIFTestScenario+Chartboost.h"
#import "KIFTestScenario+Greystripe.h"
#import "KIFTestScenario+InMobi.h"
#import "KIFTestScenario+HTML.h"
#import "KIFTestScenario+MRAID.h"
#import "KIFTestScenario+Vungle.h"
#import "KIFTestScenario+AdColony.h"
#import "KIFTestScenario+iAd.h"
#import "KIFTestScenario+Native.h"
#import "KIFTestScenario+Facebook.h"
#import "MPSampleAppTestScenario.h"
#import "InMobi.h"

@implementation MPKIFTestController

- (BOOL)flakyTestMode
{
    return getenv("KIF_FLAKY_TESTS") ? YES : NO;
}

- (void)initializeScenarios
{
//    [self addScenario:[MPSampleAppTestScenario scenarioToWarmUpAdUnits]];
    [KIFTestStep setDefaultTimeout:20];

    // banners
    [self addScenario:[KIFTestScenario scenarioForCreativeThatTriesToOpenJavaScriptDialogs]];
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithInvalidStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForClickToSafariBannerAd]];
    [self addScenario:[KIFTestScenario scenarioForClickToSafariMRAIDAd]];
    [self addScenario:[KIFTestScenario scenarioForMillennialBanner]];
    [self addScenario:[KIFTestScenario scenarioForGADBanner]];
    [self addScenario:[KIFTestScenario scenarioForGreystripeBanner]];
    [self addScenario:[KIFTestScenario scenarioForInMobiBanner]];
    [self addScenario:[KIFTestScenario scenarioForHTMLMRectBanner]];
    [self addScenario:[KIFTestScenario scenarioForMRAIDAdThatTriesToStoreAPictureWithoutUserInteraction]];
    [self addScenario:[KIFTestScenario scenarioForMRAIDAdThatTriesToPlayAVideoWithoutUserInteraction]];
    [self addScenario:[KIFTestScenario scenarioForIAdBanner]];

    // native
    [self addScenario:[KIFTestScenario scenarioForNativeAd]];
    [self addScenario:[KIFTestScenario scenarioForInMobiNativeAd]];
    [self addScenario:[KIFTestScenario scenarioForFacebookNativeAd]];

    //automated tap on ad tableviewcell not working
//    [self addScenario:[KIFTestScenario scenarioForNativeAdInTableView]];

    // interstitials
    [self addScenario:[KIFTestScenario scenarioForInterstitialAdWithStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForMillennialInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForGADInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForGreystripeInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForInMobiInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForChartboostInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForMultipleChartboostInterstitials]];
    [self addScenario:[KIFTestScenario scenarioForVungleInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForAdColonyInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForMultipleAdColonyInterstitials]];
    [self addScenario:[KIFTestScenario scenarioForMRAIDInterstitialWithAutoPlayVideo]];

    // this test currently REQUIRES manual action to dismiss the iAd interstitial...uncomment to test
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [self addScenario:[KIFTestScenario scenarioForIADInterstitial]];
//    }
}



@end
