//
//  UIView+alignChild.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 17/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIView+align.h"

@implementation UIView (align)

-(void)align:(UIViewAlign)align
{
    if (self.superview == nil)
        return;
    CGRect bounds = self.superview.bounds;
    CGRect frame = self.frame;
    
    if (align & UIViewAlignFullWidth)
        frame.size.width = bounds.size.width;
    if (align & UIViewAlignFullHeight)
        frame.size.height = bounds.size.height;

    if (align & UIViewAlignTop)
        frame.origin.y = 0;
    if (align & UIViewAlignMiddle)
        frame.origin.y = bounds.size.height / 2 - frame.size.height / 2;
    if (align & UIViewAlignBottom)
        frame.origin.y = bounds.size.height - frame.size.height;
    
    if (align & UIViewAlignLeft)
        frame.origin.x = 0;
    if (align & UIViewAlignCenter)
        frame.origin.x = bounds.size.width / 2 - frame.size.width / 2;
    if (align & UIViewAlignRight)
        frame.origin.x = bounds.size.width - frame.size.width;
    
    self.frame = frame;
}

@end
