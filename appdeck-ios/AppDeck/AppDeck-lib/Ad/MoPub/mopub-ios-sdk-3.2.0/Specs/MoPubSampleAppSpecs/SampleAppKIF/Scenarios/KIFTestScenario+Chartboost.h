//
//  KIFTestScenario+Chartboost.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario.h"

@interface KIFTestScenario (Chartboost)

+ (KIFTestScenario *)scenarioForChartboostInterstitial;
+ (KIFTestScenario *)scenarioForMultipleChartboostInterstitials;

@end
