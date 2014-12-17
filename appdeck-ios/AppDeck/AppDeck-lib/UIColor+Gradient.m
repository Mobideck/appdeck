//
//  UIColor+gradient.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "UIColor+Gradient.h"

@implementation UIColor (gradient)

- (BOOL)isEqualToColor:(UIColor *)otherColor
{
    CGColorSpaceRef colorSpaceRGB = CGColorSpaceCreateDeviceRGB();
    
    UIColor *(^convertColorToRGBSpace)(UIColor*) = ^(UIColor *color) {
        if(CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) == kCGColorSpaceModelMonochrome) {
            const CGFloat *oldComponents = CGColorGetComponents(color.CGColor);
            CGFloat components[4] = {oldComponents[0], oldComponents[0], oldComponents[0], oldComponents[1]};
            CGColorRef colorRef = CGColorCreate(colorSpaceRGB, components);
            UIColor *color = [UIColor colorWithCGColor:colorRef];
            CGColorRelease(colorRef);
            return color;
        } else
            return color;
    };
    
    UIColor *selfColor = convertColorToRGBSpace(self);
    otherColor = convertColorToRGBSpace(otherColor);
    CGColorSpaceRelease(colorSpaceRGB);
    
    return [selfColor isEqual:otherColor];
}

+ (UIColor *)colorWithGradientHeight:(CGFloat)height startColor:(UIColor *)color1 endColor:(UIColor *)color2
{
    if ([color1 isEqualToColor:color2])
        return color1;
    
    UIGraphicsBeginImageContext(CGSizeMake(1, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    NSArray *colors = [NSArray arrayWithObjects:(id)color1.CGColor, (id)color2.CGColor, nil];
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors, NULL);
    
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(1, height), 0);
    
    UIGraphicsPopContext();
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    
    return [UIColor colorWithPatternImage:gradientImage];
}
@end
