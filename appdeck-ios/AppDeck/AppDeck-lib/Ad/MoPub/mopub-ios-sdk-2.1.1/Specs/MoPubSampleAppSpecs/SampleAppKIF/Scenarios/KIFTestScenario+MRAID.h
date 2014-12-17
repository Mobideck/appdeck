//
//  KIFTestScenario+MRAID.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"

@interface KIFTestScenario (MRAID)

+ (id)scenarioForMRAIDInterstitialWithVideo;
+ (id)scenarioForMRAIDInterstitialWithAutoPlayVideo;
+ (id)scenarioForMRAIDAdThatTriesToStoreAPictureWithoutUserInteraction;
+ (id)scenarioForMRAIDAdThatTriesToPlayAVideoWithoutUserInteraction;

@end
