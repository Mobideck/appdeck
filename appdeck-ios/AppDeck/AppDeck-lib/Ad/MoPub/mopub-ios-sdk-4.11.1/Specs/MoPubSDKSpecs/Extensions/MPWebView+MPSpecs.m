//
//  MPWebView+MPSpecs.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import "MPWebView+MPSpecs.h"

@interface MPWebView ()

- (void)setUpStepsForceUIWebView:(BOOL)forceUIWebView;

@end

@implementation MPWebView (MPSpecs)

// Hack to allow dependency injection in MPAdWebViewAgent
- (instancetype)initWithFrame:(CGRect)frame forceUIWebView:(BOOL)forceUIWebView {
    return [[FakeMPInstanceProvider sharedProvider] buildMPWebViewWithFrame:frame];
}

// Force UIWebView if using Cedar. WKWebView causes a lot of crashes (MPWebView's dealloc isn't always being
// respected; sometimes WKWebViews stay living & their delegates don't get unset). Also, the Specs target doesn't
// have a window, so undefined behavior will likely occur.
- (instancetype)init {
    if (self = [super init]) {
        [self setUpStepsForceUIWebView:YES];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUpStepsForceUIWebView:YES];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpStepsForceUIWebView:YES];
    }

    return self;
}

@end
