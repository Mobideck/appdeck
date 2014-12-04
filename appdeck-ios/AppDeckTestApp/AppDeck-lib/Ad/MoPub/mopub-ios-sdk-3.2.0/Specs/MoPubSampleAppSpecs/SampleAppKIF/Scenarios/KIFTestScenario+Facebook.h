//
//  KIFTestScenario+Facebook.h
//  MoPubSampleApp
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"

@interface KIFTestScenario (Facebook)

+ (KIFTestScenario *)scenarioForFacebookBanner;
+ (KIFTestScenario *)scenarioForFacebookInterstitial;
+ (KIFTestScenario *)scenarioForFacebookNativeAd;

@end
