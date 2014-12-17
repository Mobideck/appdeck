//
//  FakeMPURLResolverDelegate.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPURLResolverDelegate.h"

@implementation FakeMPURLResolverDelegate

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    self.HTMLString = HTMLString;
    self.webViewURL = URL;
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    self.storeKitParameter = parameter;
    self.storeFallbackURL = URL;
}

- (void)openURLInApplication:(NSURL *)URL
{
    self.applicationURL = URL;
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    self.error = error;
}

@end
