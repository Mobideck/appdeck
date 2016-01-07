//
//  UIColor+blur.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 05/01/2016.
//  Copyright © 2016 Mathieu De Kermadec. All rights reserved.
//

#import "UIColor+blur.h"

@implementation UIColor (blur)

- (UIColor *)blur
{
    CGFloat red, green, blue, alpha;
    
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha] == NO)
        return self;
    
    red = (red*255.0 - 40.0) / (1.0 - 40.0 / 255.0);
    green = (green*255.0 - 40.0) / (1.0 - 40.0 / 255.0);
    blue = (blue*255.0 - 40.0) / (1.0 - 40.0 / 255.0);
    if (red < 0)
        red = 0;
    if (green < 0)
        green = 0;
    if (blue < 0)
        blue = 0;
    if (red > 255)
        red = 255;
    if (green > 255)
        green = 255;
    if (blue > 255)
        blue = 255;
    
    red = red /255.0;
    green = green/255.0;
    blue = blue/255.0;
    
//    [UIColor color
//    return [UIColor colorWithRed:185.0/255.0 green:52.0/255.0 blue:51.0/255.0 alpha:1.0];
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
