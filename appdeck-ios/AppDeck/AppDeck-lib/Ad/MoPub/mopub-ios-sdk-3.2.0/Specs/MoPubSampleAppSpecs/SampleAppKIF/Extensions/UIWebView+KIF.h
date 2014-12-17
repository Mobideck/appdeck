//
//  UIWebView+link.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (KIF)

- (NSString *)html;
- (NSString *)allLinks;
- (void)tapCSSSelector:(NSString *)CSSSelector;

@end
