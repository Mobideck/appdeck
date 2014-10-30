//
//  UIView+alignChild.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 17/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UIViewAlignNone         = 0,
    UIViewAlignLeft         = 1 << 0,
    UIViewAlignCenter       = 1 << 1,
    UIViewAlignRight        = 1 << 2,
    UIViewAlignTop          = 1 << 3,
    UIViewAlignMiddle       = 1 << 4,
    UIViewAlignBottom       = 1 << 5,
    UIViewAlignFullWidth    = 1 << 6,
    UIViewAlignFullHeight   = 1 << 7
} UIViewAlign;

@interface UIView (align)

-(void)align:(UIViewAlign)align;

@end
