//
//  FakeMPAdAlertGestureRecognizer.h
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdAlertGestureRecognizer.h"

@interface FakeMPAdAlertGestureRecognizer : MPAdAlertGestureRecognizer

@property (nonatomic, retain) id fakeTarget;
@property (nonatomic, assign) SEL fakeTargetAction;

- (void)simulateGestureRecognized;

@end
