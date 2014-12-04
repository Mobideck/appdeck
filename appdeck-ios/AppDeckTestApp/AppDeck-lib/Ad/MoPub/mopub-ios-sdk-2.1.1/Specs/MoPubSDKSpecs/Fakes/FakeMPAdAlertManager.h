//
//  FakeMPAdAlertManager.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdAlertManager.h"

@interface FakeMPAdAlertManager : MPAdAlertManager <UIGestureRecognizerDelegate>

- (void)simulateGestureRecognized;

@end
