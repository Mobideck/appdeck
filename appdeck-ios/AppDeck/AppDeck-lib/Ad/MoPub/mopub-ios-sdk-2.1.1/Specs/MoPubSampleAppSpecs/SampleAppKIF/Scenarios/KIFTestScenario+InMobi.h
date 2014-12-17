//
//  KIFTestScenario+InMobi.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"
#import "InMobi.h"

@interface KIFTestScenario (InMobi)

+ (KIFTestScenario *)scenarioForInMobiBanner;
+ (KIFTestScenario *)scenarioForInMobiInterstitial;

@end
