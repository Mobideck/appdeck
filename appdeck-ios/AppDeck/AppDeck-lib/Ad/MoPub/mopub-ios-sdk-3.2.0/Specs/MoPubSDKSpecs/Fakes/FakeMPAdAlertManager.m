//
//  FakeMPAdAlertManager.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdAlertManager.h"
#import "FakeMPAdAlertGestureRecognizer.h"

@interface FakeMPAdAlertManager ()

@property (nonatomic, assign) BOOL processedAlert;
@property (nonatomic, strong) FakeMPAdAlertGestureRecognizer *adAlertGestureRecognizer;

@end

@implementation FakeMPAdAlertManager

- (void)simulateGestureRecognized
{
    [self.adAlertGestureRecognizer simulateGestureRecognized];
}

- (void)processAdAlert
{
    if([self.delegate respondsToSelector:@selector(adAlertManagerDidProcessAlert:)])
    {
        [self.delegate adAlertManagerDidProcessAlert:self];
    }
}

@end
