//
//  KIFTestScenario+AdColony.h
//  MoPubSampleApp
//
//  Created by Yuan Ren on 10/23/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"

@interface KIFTestScenario (AdColony)

+ (KIFTestScenario *)scenarioForAdColonyInterstitial;
+ (KIFTestScenario *)scenarioForMultipleAdColonyInterstitials;

@end
