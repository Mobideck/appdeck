//
//  UIScrollView+ScrollsToTop.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 02/12/2013.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIScrollView+ScrollsToTop.h"

@implementation UIScrollView (ScrollsToTop)

- (id)altInitWithFrame:(CGRect)frame
{
    [self altInitWithFrame:frame];
    self.scrollsToTop = NO;
    return self;
}

@end
