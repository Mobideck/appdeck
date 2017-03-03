//
//  FakeMRBridge.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FakeMRBridge.h"
#import "MRProperty.h"

@implementation FakeMRBridge

- (id)initWithWebView:(MPWebView *)webView
{
    self = [super initWithWebView:webView];
    if (self) {
        self.changedProperties = [NSMutableSet set];
        self.errorEvents = [NSMutableArray array];
    }
    return self;
}

- (void)fireChangeEventForProperty:(MRProperty *)property
{
    [self.changedProperties addObject:[property description]];
}

- (void)fireChangeEventsForProperties:(NSArray *)properties
{
    for (MRProperty *property in properties) {
        [self.changedProperties addObject:[property description]];
    }
}

- (void)fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message
{
    [self.errorEvents addObject:action];
}

- (void)fireNativeCommandCompleteEvent:(NSString *)command
{
    self.lastCompletedCommand = command;
}

- (void)fireReadyEvent
{
    self.didFireReadyEvent = YES;
}

- (BOOL)containsProperty:(MRProperty *)property
{
    return [self.changedProperties containsObject:[property description]];
}

@end
