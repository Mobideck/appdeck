//
//  FakeUITouch.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeUITouch.h"

@implementation FakeUITouch

- (void)dealloc
{
    self.view = nil;
    [super dealloc];
}

@end
