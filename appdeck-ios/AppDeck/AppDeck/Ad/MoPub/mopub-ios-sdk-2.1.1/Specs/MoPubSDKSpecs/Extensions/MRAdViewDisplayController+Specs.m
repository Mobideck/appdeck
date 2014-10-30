//
//  MRAdViewDisplayController+Specs.m
//  MoPubSDK
//
//  Created by Yuan Ren on 10/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MRAdViewDisplayController+Specs.h"

@interface MRAdViewDisplayController ()

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished
                 context:(void *)context;

@end

@implementation MRAdViewDisplayController (Specs)

- (void)animateFromExpandedStateToDefaultState
{
    [self animationDidStop:@"closeExpanded" finished:[NSNumber numberWithBool:YES] context:nil];
}

- (void)animateViewFromDefaultStateToExpandedState:(UIView *)view
{
    [self animationDidStop:@"expand" finished:[NSNumber numberWithBool:YES] context:nil];
}

@end
