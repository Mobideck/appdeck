//
//  UIColor+gradient.h
//  AppDeck
//
//  Created by Mathieu De Kermadec on 09/05/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (gradient)

+ (UIColor *)colorWithGradientHeight:(CGFloat)height startColor:(UIColor *)color1 endColor:(UIColor *)color2;

@end
