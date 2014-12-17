//
//  UIView+SubViewsWalk.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 10/06/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIView+SubViewsWalk.h"

@implementation UIView (SubViewsWalk)

-(void)subViewsWalk:(UIViewCallback)callback
{
    for (UIView *subView in [self subviews])
    {
        callback(subView);
        [subView subViewsWalk:callback];
    }
}

@end
