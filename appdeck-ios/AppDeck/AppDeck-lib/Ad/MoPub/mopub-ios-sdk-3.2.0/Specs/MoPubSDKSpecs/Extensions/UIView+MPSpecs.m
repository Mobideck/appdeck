//
//  UIView+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UIView+MPSpecs.h"
#import "MPGlobal.h"

@implementation UIView (MPSpecs)

- (BOOL)mp_viewIntersectsParentWindowWithPercent:(CGFloat)percentVisible
{
    return MPViewIntersectsParentWindowWithPercent(self, percentVisible);
}

- (BOOL)mp_viewIsVisible
{
    return MPViewIsVisible(self);
}

@end
