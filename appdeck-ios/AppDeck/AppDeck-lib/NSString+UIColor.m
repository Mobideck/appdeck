//
//  NSString+UIColor.m
//  AppDeck
//
//  Created by Mathieu De Kermadec on 19/01/13.
//  Copyright (c) 2013 Mathieu De Kermadec. All rights reserved.
//

#import "NSString+UIColor.h"

@implementation NSString (UIColor)

- (UIColor *)toUIColor
{
    unsigned int c;
    
    if ([self length] == 7 && [self characterAtIndex:0] == '#') {
        [[NSScanner scannerWithString:[self substringFromIndex:1]] scanHexInt:&c];
    } else if ([self length] == 6) {
        [[NSScanner scannerWithString:self] scanHexInt:&c];
    } else {
        return nil;
        return [UIColor clearColor];
    }
    return [UIColor colorWithRed:((c & 0xff0000) >> 16)/255.0 green:((c & 0xff00) >> 8)/255.0 blue:(c & 0xff)/255.0 alpha:1.0];
}

@end
