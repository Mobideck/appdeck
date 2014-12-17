//
//  FakeMPAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdView.h"

@implementation FakeMPAdView

- (void)loadAd
{
    self.wasLoaded = YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    self.orientation = newOrientation;
}

@end
