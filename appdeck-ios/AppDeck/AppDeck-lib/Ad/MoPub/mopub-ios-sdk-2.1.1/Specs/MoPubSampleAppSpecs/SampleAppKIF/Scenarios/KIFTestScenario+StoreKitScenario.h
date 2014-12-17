//
//  KIFTestScenario+StoreKitScenario.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"

@interface KIFTestScenario (StoreKitScenario)

+ (id)scenarioForBannerAdWithStoreKitLink;
+ (id)scenarioForBannerAdWithInvalidStoreKitLink;
+ (id)scenarioForInterstitialAdWithStoreKitLink;

@end
