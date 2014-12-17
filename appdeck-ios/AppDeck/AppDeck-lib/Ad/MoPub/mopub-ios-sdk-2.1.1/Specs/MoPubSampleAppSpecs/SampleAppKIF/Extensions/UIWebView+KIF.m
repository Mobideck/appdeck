//
//  UIWebView+link.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIWebView+KIF.h"

@implementation UIWebView (KIF)

- (NSString *)html
{
    return [self stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML;"];
}


- (NSString *)allLinks
{
    NSString *JS = [NSString stringWithFormat:
                    @"(function() {var anchors = Array.prototype.slice.call(document.querySelectorAll('a'));"
                    @"var anchorStrings = '';"
                    @"anchors.forEach(function(a) {anchorStrings += a.outerHTML + ', ';});"
                    @"return anchorStrings;})()"];

    return [self stringByEvaluatingJavaScriptFromString:JS];
}

- (void)tapCSSSelector:(NSString *)CSSSelector
{
    NSString *JS = [NSString stringWithFormat:
                    @"(function() {var elements = Array.prototype.slice.call(document.querySelectorAll('%@'));"
                    @"elements.forEach(function(el) {el.click()});"
                    @"})()", CSSSelector];

    [self stringByEvaluatingJavaScriptFromString:JS];
}

@end
