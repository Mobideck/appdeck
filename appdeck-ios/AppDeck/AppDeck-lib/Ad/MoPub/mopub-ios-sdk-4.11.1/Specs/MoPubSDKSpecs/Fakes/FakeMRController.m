//
//  FakeMRController.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMRController.h"

@implementation FakeMRController

- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.loadedHTMLString = [configuration adResponseHTMLString];

    [super loadAdWithConfiguration:configuration];
}

- (BOOL)hasUserInteractedWithWebViewForBridge:(MRBridge *)bridge
{
    return self.userInteractedWithWebViewOverride;
}

@end
