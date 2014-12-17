//
//  KIFTestStep+Navigation.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (Navigation)

+ (id)stepToReturnToBannerAds;
+ (id)stepToDismissModalViewController;
+ (id)stepToPushManualAdViewController;

@end
