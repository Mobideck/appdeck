//
//  UIApplication+KIF.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+KIF.h"
#import "objc/runtime.h"

static char LAST_OPENED_URL_KEY;

@implementation UIApplication (KIF)

- (void)resetLastOpenedURL
{
    [self setLastOpenedURL:nil];
}

- (NSURL *)lastOpenedURL
{
    return objc_getAssociatedObject(self, &LAST_OPENED_URL_KEY);
}

- (void)setLastOpenedURL:(NSURL *)url
{
    objc_setAssociatedObject(self, &LAST_OPENED_URL_KEY, url, OBJC_ASSOCIATION_RETAIN);
}

- (void)openURL:(NSURL *)url
{
    self.lastOpenedURL = url;
    NSLog(@"================> Application tried to open: %@", url);
}

@end
